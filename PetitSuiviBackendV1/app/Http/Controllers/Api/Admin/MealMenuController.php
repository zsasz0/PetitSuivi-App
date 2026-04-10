<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use RuntimeException;

/**
 * @group Admin - Meals
 *
 * APIs for managing the master catalog of food items and their exceptions.
 */
class MealMenuController extends Controller
{
    /**
     * Get All Meals
     *
     * Retrieves all available food items (lunch and snack) configured in the master catalog.
     *
     * @authenticated
     * @response {
     *   "success": true,
     *   "message": "Meals retrieved.",
     *   "data": [
     *     {
     *       "id": 1,
     *       "name": "Couscous",
     *       "category": { "name": "Lunch" }
     *     }
     *   ]
     * }
     */
    public function index(Request $request): JsonResponse
    {
        $meals = DB::table('Meals')
            ->join('Mealscategory', 'Meals.MealscategoryID', '=', 'Mealscategory.MealscategoryID')
            ->select('Meals.MealsID as id', 'Meals.Name as name', 'Mealscategory.Name as category_name')
            ->get()
            ->map(function ($m) {
                return [
                    'id' => $m->id,
                    'name' => $m->name,
                    'category' => ['name' => $m->category_name],
                ];
            });

        return response()->json([
            'success' => true,
            'message' => 'Meals retrieved.',
            'data' => $meals,
        ]);
    }

    /**
     * Store Meal
     *
     * Creates a new meal/food item and optionally maps confirmed exceptions to it.
     *
     * @authenticated
     * @bodyParam name string required The name of the meal. Example: Couscous
     * @bodyParam category string required The category type (lunch or snack). Example: lunch
     * @bodyParam exceptions array[] optional The array of confirmed diet exceptions.
     * @bodyParam exceptions[].child_id int The ID of the child. Example: 15
     * @bodyParam exceptions[].reason string The restriction reason. Example: Allergie aux arachides
     *
     * @response 201 {
     *   "success": true,
     *   "message": "Meal created successfully.",
     *   "data": {
     *       "id": 2,
     *       "name": "Couscous",
     *       "category": { "name": "Lunch" }
     *   }
     * }
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'name' => 'required|string|max:255|unique:Meals,Name',
            'category' => 'required|string|max:255',
            'exceptions' => 'nullable|array',
            'exceptions.*.child_id' => 'required|integer',
            'exceptions.*.reason' => 'required|string'
        ]);

        $catName = strtolower($request->input('category'));
        $categoryId = DB::table('Mealscategory')->whereRaw('LOWER(Name) = ?', [$catName])->value('MealscategoryID');
        if (!$categoryId) {
            $categoryId = DB::table('Mealscategory')->insertGetId(['Name' => ucfirst($catName)], 'MealscategoryID');
        }

        DB::beginTransaction();
        try {
            $mealId = DB::table('Meals')->insertGetId([
                'Name' => $request->input('name'),
                'MealscategoryID' => $categoryId
            ], 'MealsID');

            $exceptions = $request->input('exceptions', []);
            foreach ($exceptions as $exc) {
                $excId = DB::table('Childfoodexception')->insertGetId([
                    'ChildID' => $exc['child_id'],
                    'Reason' => $exc['reason']
                ], 'ChildfoodexceptionID');

                DB::table('ChildFoodExceptionMeals')->insert([
                    'ChildfoodexceptionID' => $excId,
                    'MealsID' => $mealId
                ]);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Meal created successfully.',
                'data' => [
                    'id' => $mealId,
                    'name' => $request->input('name'),
                    'category' => ['name' => ucfirst($catName)],
                ]
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * Check Exceptions via AI
     *
     * Requests the AI Copilot to scan a given meal against known child dietary restrictions.
     *
     * @authenticated
     * @bodyParam meal_name string required The name of the meal to scan. Example: Gâteau au Chocolat
     * @bodyParam ingredients array[] optional The list of extra ingredients.
     *
     * @response {
     *   "success": true,
     *   "exceptions": [
     *     {
     *       "child_id": 1,
     *       "child_name": "Jean Dupont",
     *       "reason": "Allergie aux arachides",
     *       "parent_phone": "0600000000"
     *     }
     *   ]
     * }
     */
    public function checkExceptions(Request $request): JsonResponse
    {
        $request->validate([
            'meal_name' => 'required|string',
            'ingredients' => 'nullable|array'
        ]);

        if (!$this->isAiEnabled()) {
            return response()->json([
                'success' => false,
                'message' => 'AI module disabled. Please disable ai_enabled in Parameters to bypass AI checking.',
            ], 422);
        }

        $mealName = $request->input('meal_name');

        // Fetch current un-archived Planning
        $planning = DB::table('Planning')
            ->where('Isarchived', 0)
            ->orderByDesc('PlanningID')
            ->first();

        $query = DB::table('Child')
            ->join('Payment', 'Child.ChildID', '=', 'Payment.ChildID')
            ->join('Inscription', 'Payment.InscriptionID', '=', 'Inscription.InscriptionID')
            ->join('Inscriptionstatus', 'Inscription.InscriptionstatusID', '=', 'Inscriptionstatus.InscriptionstatusID')
            ->leftJoin('Account', function($join) {
                $join->on('Child.ParentID', '=', 'Account.PersonID')
                     ->where('Account.RoleID', 3);
            })
            ->where('Inscriptionstatus.Name', 'approved');

        // Restrict scan to children enrolled in the current active planning timeframe
        if ($planning) {
            $startYear = date('Y', strtotime($planning->Startdate ?? date('Y-09-01')));
            $endYear = date('Y', strtotime($planning->Enddate ?? date('Y-06-30', strtotime('+1 year'))));
            $query->whereYear('Inscription.Date', '>=', $startYear)
                  ->whereYear('Inscription.Date', '<=', $endYear)
                  ->where('Inscription.Isarchived', 0);
        }

        $childrenData = $query->select(
                'Child.ChildID as child_id',
                'Child.Firstname as child_first',
                'Child.Lastname as child_last',
                'Account.Phone as parent_phone'
            )
            ->get()
            ->unique('child_id')
            ->values()
            ->map(function ($child) {
                $restrictionContext = $this->resolveRestrictionContextForChild((int) $child->child_id);

                if ($restrictionContext === null) {
                    return null;
                }

                $child->restriction_context = $restrictionContext;
                return $child;
            })
            ->filter()
            ->values();

        if ($childrenData->isEmpty()) {
            return response()->json(['success' => true, 'exceptions' => []]);
        }
        
        $childrenJson = $childrenData->map(fn($c) => [
            'id' => $c->child_id,
            'name' => trim($c->child_first . ' ' . $c->child_last),
            'parent_phone' => $c->parent_phone,
            'restriction_context' => $c->restriction_context,
        ])->toJson(JSON_UNESCAPED_UNICODE);

        $prompt = "Given this meal name: \"{$mealName}\"\n\nAnd these children with food-related restrictions or health notes that may affect meals:\n{$childrenJson}\n\nReturn ONLY a JSON array of children who CANNOT or should NOT eat this meal because of their restriction context. Consider allergies, intolerances, mandatory diets, ingredient restrictions, and any health note that implies a concrete meal precaution. Use exactly this format: [{\"child_id\": <id>, \"child_name\": \"<name>\", \"parent_phone\": \"<phone>\", \"reason\": \"<brief explanation in French>\"}]. If no issues, return [].";

        try {
            $rawOutput = $this->callCopilotProxy($prompt);
            if (!preg_match('/\[.*\]/s', $rawOutput, $matches)) {
                throw new RuntimeException('AI returned an unexpected format while checking food exceptions.');
            }

            $parsed = json_decode($matches[0], true);
            if (!is_array($parsed)) {
                throw new RuntimeException('AI returned invalid JSON while checking food exceptions.');
            }

            $exceptions = $parsed;

            return response()->json([
                'success' => true,
                'exceptions' => $exceptions
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'AI module error: ' . $e->getMessage() . ' Please disable ai_enabled in Parameters if you want to bypass this step.',
            ], 500);
        }
    }

    private function callCopilotProxy(string $prompt): string
    {
        $copilotUrl = rtrim((string) config('services.copilot.url', 'http://localhost:4141'), '/') . '/v1/chat/completions';

        $response = Http::timeout(60)
            ->acceptJson()
            ->post($copilotUrl, [
                'model' => 'gpt-4.1',
                'messages' => [
                    [
                        'role' => 'user',
                        'content' => $prompt,
                    ],
                ],
            ]);

        if ($response->failed()) {
            throw new RuntimeException('Could not connect to the AI server.');
        }

        $data = $response->json();
        $content = trim((string) data_get($data, 'choices.0.message.content', ''));

        if ($content === '') {
            throw new RuntimeException('AI returned an empty response.');
        }

        return $content;
    }

    private function isAiEnabled(): bool
    {
        $value = DB::table('Parameter')
            ->where('Name', 'ai_enabled')
            ->value('Value');

        return in_array(strtolower((string) $value), ['true', '1'], true);
    }

    private function buildMealRestrictionContext(?string $dietaryComment, ?string $healthComment): ?string
    {
        $parts = [];

        $dietary = $this->normalizeMealRelevantComment($dietaryComment);
        if ($dietary !== '') {
            $parts[] = 'Résumé alimentaire: ' . $dietary;
        }

        $health = $this->normalizeMealRelevantComment($healthComment);
        if ($health !== '') {
            $parts[] = 'Notes de santé pouvant affecter les repas: ' . $health;
        }

        return $parts === [] ? null : implode("\n", $parts);
    }

    private function resolveRestrictionContextForChild(int $childId): ?string
    {
        $originalMedicalForm = DB::table('Medicalform')
            ->join('Payment', 'Medicalform.InscriptionID', '=', 'Payment.InscriptionID')
            ->leftJoin('Dietarycomment', 'Medicalform.DietarycommentID', '=', 'Dietarycomment.DietarycommentID')
            ->leftJoin('Healthcomment', 'Medicalform.HealthcommentID', '=', 'Healthcomment.HealthcommentID')
            ->where('Payment.ChildID', $childId)
            ->orderBy('Medicalform.MedicalformID')
            ->select(
                'Dietarycomment.Dietarycomment as dietary_comment',
                'Healthcomment.Healthcomment as health_comment'
            )
            ->first();

        if (!$originalMedicalForm) {
            return null;
        }

        return $this->buildMealRestrictionContext(
            $originalMedicalForm->dietary_comment,
            $originalMedicalForm->health_comment,
        );
    }

    private function normalizeMealRelevantComment(?string $text): string
    {
        $text = trim((string) $text);
        if ($text === '') {
            return '';
        }

        $lower = mb_strtolower($text, 'UTF-8');
        if (
            str_starts_with($text, '✅') ||
            str_contains($lower, 'aucune restriction alimentaire détectée') ||
            str_contains($lower, 'aucun problème de santé notable détecté')
        ) {
            return '';
        }

        return $text;
    }

    /**
     * Save Exceptions for Meal
     *
     * Saves manually scanned/confirmed AI exceptions for an existing meal.
     *
     * @authenticated
     * @bodyParam meal_name string required The name of the meal. Example: Gâteau au Chocolat
     * @bodyParam exceptions array[] required The array of exceptions to map.
     * @bodyParam exceptions[].child_id int The ID of the child. Example: 1
     * @bodyParam exceptions[].reason string The restriction reason. Example: Allergie au chocolat
     *
     * @response {
     *   "success": true,
     *   "message": "Exceptions saved successfully."
     * }
     */
    public function saveExceptions(Request $request): JsonResponse
    {
        $request->validate([
            'meal_name' => 'required|string',
            'exceptions' => 'required|array',
            'exceptions.*.child_id' => 'required|integer',
            'exceptions.*.reason' => 'required|string'
        ]);

        $mealId = DB::table('Meals')->where('Name', $request->input('meal_name'))->value('MealsID');
        if (!$mealId) {
            return response()->json(['success' => false, 'message' => 'Meal not found.'], 404);
        }

        DB::beginTransaction();
        try {
            $existingExcIds = DB::table('ChildFoodExceptionMeals')->where('MealsID', $mealId)->pluck('ChildfoodexceptionID');
            if ($existingExcIds->isNotEmpty()) {
                DB::table('ChildFoodExceptionMeals')->where('MealsID', $mealId)->delete();
                DB::table('Childfoodexception')->whereIn('ChildfoodexceptionID', $existingExcIds)->delete();
            }

            foreach ($request->input('exceptions') as $exc) {
                $excId = DB::table('Childfoodexception')->insertGetId([
                    'ChildID' => $exc['child_id'],
                    'Reason' => $exc['reason']
                ], 'ChildfoodexceptionID');

                DB::table('ChildFoodExceptionMeals')->insert([
                    'ChildfoodexceptionID' => $excId,
                    'MealsID' => $mealId
                ]);
            }

            DB::commit();

            return response()->json(['success' => true, 'message' => 'Exceptions saved successfully.']);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * Delete Meal
     *
     * Deletes a food item from the system and cascades to exceptions if necessary.
     *
     * @authenticated
     * @urlParam id int required The MealsID to delete. Example: 1
     *
     * @response {
     *   "success": true,
     *   "message": "Meal deleted."
     * }
     */
    public function destroy(int $id): JsonResponse
    {
        DB::beginTransaction();
        try {
            $excIds = DB::table('ChildFoodExceptionMeals')->where('MealsID', $id)->pluck('ChildfoodexceptionID');
            if ($excIds->isNotEmpty()) {
                DB::table('ChildFoodExceptionMeals')->where('MealsID', $id)->delete();
                DB::table('Childfoodexception')->whereIn('ChildfoodexceptionID', $excIds)->delete();
            }

            DB::table('Meals')->where('MealsID', $id)->delete();

            DB::commit();

            return response()->json(['success' => true, 'message' => 'Meal deleted.']);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * Get All Food Exceptions
     *
     * Fetches all children's configured food exceptions mapped to their respective meal IDs.
     *
     * @authenticated
     * @response {
     *   "success": true,
     *   "data": [
     *     {
     *       "child_id": 1,
     *       "child_name": "Jean Dupont",
     *       "exceptions": [
     *         {
     *           "meal_id": 5,
     *           "reason": "Intolérance au lactose"
     *         }
     *       ]
     *     }
     *   ]
     * }
     */
    public function getFoodExceptions(Request $request): JsonResponse
    {
        $exceptions = DB::table('Child')
            ->join('Childfoodexception', 'Child.ChildID', '=', 'Childfoodexception.ChildID')
            ->join('ChildFoodExceptionMeals', 'Childfoodexception.ChildfoodexceptionID', '=', 'ChildFoodExceptionMeals.ChildfoodexceptionID')
            ->select(
                'Child.ChildID',
                'Child.Firstname',
                'Child.Lastname',
                'Childfoodexception.Reason',
                'ChildFoodExceptionMeals.MealsID'
            )
            ->get();

        $grouped = [];
        foreach ($exceptions as $exc) {
            $childId = $exc->ChildID;
            if (!isset($grouped[$childId])) {
                $grouped[$childId] = [
                    'child_id' => $childId,
                    'child_name' => trim($exc->Firstname . ' ' . $exc->Lastname),
                    'exceptions' => []
                ];
            }
            $grouped[$childId]['exceptions'][] = [
                'meal_id' => $exc->MealsID,
                'reason' => $exc->Reason
            ];
        }

        return response()->json([
            'success' => true,
            'data' => array_values($grouped)
        ]);
    }

    /**
     * Get Meals By Week
     *
     * Retrieves the full weekly meal plan grid for the week containing
     * the given date. Returns an array of day objects, each with its
     * date and nested plans → meals structure.
     *
     * @authenticated
     * @urlParam date string required A date within the target week (YYYY-MM-DD). Example: 2026-04-06
     *
     * @response {
     *   "success": true,
     *   "data": [
     *     {
     *       "date": "2026-04-06",
     *       "plans": [
     *         {
     *           "meals": [
     *             { "name": "Couscous", "category": { "name": "Lunch" } },
     *             { "name": "Yaourt", "category": { "name": "Snack" } }
     *           ]
     *         }
     *       ]
     *     }
     *   ]
     * }
     */
    public function getByWeek(string $date): JsonResponse
    {
        // Compute the Monday of the week containing $date
        $dt = new \DateTime($date);
        $dow = (int) $dt->format('N'); // 1=Mon … 7=Sun
        $monday = (clone $dt)->modify('-' . ($dow - 1) . ' days');
        $friday = (clone $monday)->modify('+4 days');

        $monStr = $monday->format('Y-m-d');
        $friStr = $friday->format('Y-m-d');

        // Fetch all dailyplan rows for this week with their meals
        $rows = DB::table('Dailyplan')
            ->join('DailyPlanMeals', 'Dailyplan.DailyplanID', '=', 'DailyPlanMeals.DailyplanID')
            ->join('Meals', 'DailyPlanMeals.MealsID', '=', 'Meals.MealsID')
            ->join('Mealscategory', 'Meals.MealscategoryID', '=', 'Mealscategory.MealscategoryID')
            ->whereBetween('Dailyplan.Date', [$monStr, $friStr])
            ->select(
                'Dailyplan.Date as date',
                'Meals.MealsID as meal_id',
                'Meals.Name as meal_name',
                'Mealscategory.Name as category_name'
            )
            ->get();

        // Group by date → single plan object → meals array
        $grouped = [];
        foreach ($rows as $row) {
            $d = $row->date;
            if (!isset($grouped[$d])) {
                $grouped[$d] = [
                    'date' => $d,
                    'plans' => [['meals' => []]],
                ];
            }
            $grouped[$d]['plans'][0]['meals'][] = [
                'name' => $row->meal_name,
                'category' => ['name' => $row->category_name],
            ];
        }

        // Fill in missing weekdays so the frontend always gets 5 entries
        for ($i = 0; $i < 5; $i++) {
            $dayStr = (clone $monday)->modify("+{$i} days")->format('Y-m-d');
            if (!isset($grouped[$dayStr])) {
                $grouped[$dayStr] = [
                    'date' => $dayStr,
                    'plans' => [],
                ];
            }
        }

        ksort($grouped);

        return response()->json([
            'success' => true,
            'data' => array_values($grouped),
        ]);
    }
}
