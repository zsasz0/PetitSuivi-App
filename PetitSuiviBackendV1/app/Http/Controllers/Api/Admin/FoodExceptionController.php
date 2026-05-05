<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/**
 * @group Admin - Food Exceptions
 *
 * APIs for viewing AI-detected dietary restrictions and food exceptions
 * for enrolled children, scoped to a selected academic planning year.
 *
 * Food exceptions are created automatically by the AI analysis pipeline
 * during inscription approval or when a new food item is added to the
 * catalog. This controller provides read-only access to those records.
 *
 * Database relationships:
 *   Child               → has many → Childfoodexception    (via ChildID)
 *   Childfoodexception  → mapped   → Meals                 (via ChildFoodExceptionMeals pivot)
 *   Child               → enrolled → Class                 (via ChildClass pivot)
 *   Payment             → links    → Inscription           (via InscriptionID)
 *   Medicalform         → links    → Dietarycomment        (via DietarycommentID)
 *   Class               → scoped   → Planning              (via PlanningID)
 */
class FoodExceptionController extends Controller
{
    private function resolvePlanningInscriptionForChild(int $childId, ?object $planning): ?object
    {
        $inscriptions = DB::table('Payment')
            ->join('Inscription', 'Payment.InscriptionID', '=', 'Inscription.InscriptionID')
            ->where('Payment.ChildID', $childId)
            ->select(
                'Inscription.InscriptionID',
                'Inscription.Date as inscription_date',
                'Inscription.Isarchived as inscription_archived',
                'Inscription.MealplanID'
            )
            ->orderByDesc('Inscription.Date')
            ->orderByDesc('Inscription.InscriptionID')
            ->get();

        if ($inscriptions->isEmpty()) {
            return null;
        }

        if (!$planning) {
            return $inscriptions->first();
        }

        $planningStart = !empty($planning->Startdate) ? strtotime($planning->Startdate) : null;
        $planningEnd = !empty($planning->Enddate) ? strtotime($planning->Enddate) : null;
        $isArchivedPlanning = (bool) ($planning->Isarchived ?? false);

        $dateMatched = $inscriptions->first(function ($inscription) use ($planningStart, $planningEnd) {
            if (!$planningStart || !$planningEnd || empty($inscription->inscription_date)) {
                return false;
            }

            $inscriptionDate = strtotime($inscription->inscription_date);
            return $inscriptionDate >= $planningStart && $inscriptionDate <= $planningEnd;
        });

        if ($dateMatched) {
            return $dateMatched;
        }

        $archiveMatched = $inscriptions->first(function ($inscription) use ($isArchivedPlanning) {
            return (bool) ($inscription->inscription_archived ?? false) === $isArchivedPlanning;
        });

        return $archiveMatched ?: $inscriptions->first();
    }

    /**
     * Get Food Exceptions by Planning Year
     *
     * Retrieves all children who have at least one AI-detected food exception
     * (forbidden meal) for the specified academic planning year. Each child
     * entry includes their full name, assigned class name, a summary of their
     * dietary comment, the total count of forbidden meals, and the full list
     * of exception records with meal names and restriction reasons.
     *
     * The year scoping works through the following join chain:
     *   Child → ChildClass → Class (filtered by PlanningID)
     *
     * Only children who are both enrolled in a class for the given planning
     * year AND have at least one registered food exception are returned.
     *
     * @group Admin - Food Exceptions
     * @authenticated
     *
     * @queryParam planning_id int required
     *   The PlanningID to filter exceptions by academic year.
     *   Example: 2
     *
     * @response 200 {
     *   "success": true,
     *   "data": [
     *     {
     *       "child_id": 15,
     *       "child_name": "Youssef Mejri",
     *       "class_name": "Petite Section A",
     *       "exception_count": 2,
     *       "dietary_comment": "Allergique aux arachides. Intolérant au lactose.",
     *       "exceptions": [
     *         {
     *           "meal_id": 3,
     *           "meal_name": "Gâteau au Chocolat",
     *           "reason": "Allergie au chocolat et aux arachides"
     *         },
     *         {
     *           "meal_id": 7,
     *           "meal_name": "Yaourt Nature",
     *           "reason": "Intolérance au lactose"
     *         }
     *       ]
     *     }
     *   ]
     * }
     *
     * @response 422 {
     *   "success": false,
     *   "message": "The planning_id field is required."
     * }
     *
     * @response 500 {
     *   "success": false,
     *   "message": "An error occurred while retrieving food exceptions."
     * }
     */
    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'planning_id' => 'nullable|integer|exists:Planning,PlanningID',
        ]);

        $planningId = $request->query('planning_id') ? (int) $request->query('planning_id') : null;

        try {
            $planning = null;
            $mealType = $request->query('meal_type');
            if ($planningId) {
                $planning = DB::table('Planning')->where('PlanningID', $planningId)->first();
            }

            // ──────────────────────────────────────────────────────────
            // Step 1: Get all ChildIDs appropriately enrolled.
            // A child is deemed enrolled if they have a non-archived Class
            // in this Planning, AND their Inscription matches the planning's timeframe.
            // If the planning itself is archived, we load inscriptions falling in its start/end year.
            // ──────────────────────────────────────────────────────────
            if ($planning) {
                $childIdsInYear = DB::table('ChildClass')
                    ->join('Class', 'ChildClass.ClassID', '=', 'Class.ClassID')
                    ->where('Class.PlanningID', $planningId)
                    ->pluck('ChildClass.ChildID')
                    ->unique()
                    ->values()
                    ->toArray();

                $inscriptionByChild = collect($childIdsInYear)
                    ->mapWithKeys(function ($childId) use ($planning) {
                        return [$childId => $this->resolvePlanningInscriptionForChild((int) $childId, $planning)];
                    })
                    ->filter();

                // ──────────────────────────────────────────────────────────
                // Step 1b: Filter children by MealplanID vs requested meal_type.
                //   MealplanID mapping:
                //     NULL or 1 = Full (both meals)  → show in dejeuner AND gouter
                //     2         = Dejeuner only      → show ONLY in dejeuner
                //     3         = Gouter only        → show ONLY in gouter
                //     4         = Gratuit (free)      → exclude from both
                // ──────────────────────────────────────────────────────────
                if ($mealType) {
                    $inscriptionByChild = $inscriptionByChild->filter(function ($inscription) use ($mealType) {
                        $mealPlanId = $inscription->MealplanID ?? null;

                        // Gratuit (4) → never show in any exception list
                        if ((int) $mealPlanId === 4) {
                            return false;
                        }

                        // Dejeuner-only (2) → exclude from gouter exceptions
                        if ($mealType === 'gouter' && (int) $mealPlanId === 2) {
                            return false;
                        }

                        // Gouter-only (3) → exclude from dejeuner exceptions
                        if ($mealType === 'dejeuner' && (int) $mealPlanId === 3) {
                            return false;
                        }

                        return true;
                    });
                }

                $childIdsInYear = $inscriptionByChild->keys()->map(fn ($id) => (int) $id)->values()->toArray();

                if (empty($childIdsInYear)) {
                    return response()->json(['success' => true, 'data' => []]);
                }
            } else {
                $childIdsInYear = null; // null means "all children"
                $inscriptionByChild = collect();
            }

            // ──────────────────────────────────────────────────────────
            // Step 2: Get all food exceptions for children in that year.
            // JOIN: Child → Childfoodexception → ChildFoodExceptionMeals → Meals → Mealscategory
            // ──────────────────────────────────────────────────────────

            $rows = DB::table('Child')
                ->join('Childfoodexception', 'Child.ChildID', '=', 'Childfoodexception.ChildID')
                ->join('ChildFoodExceptionMeals', 'Childfoodexception.ChildfoodexceptionID', '=', 'ChildFoodExceptionMeals.ChildfoodexceptionID')
                ->join('Meals', 'ChildFoodExceptionMeals.MealsID', '=', 'Meals.MealsID')
                ->join('Mealscategory', 'Meals.MealscategoryID', '=', 'Mealscategory.MealscategoryID')
                ->leftJoin('ChildClass', function ($join) {
                    $join->on('Child.ChildID', '=', 'ChildClass.ChildID');
                })
                ->leftJoin('Class', function ($join) use ($planningId) {
                    $join->on('ChildClass.ClassID', '=', 'Class.ClassID');
                    if ($planningId) {
                        $join->where('Class.PlanningID', '=', $planningId);
                    }
                })
                ->when($childIdsInYear !== null, function ($q) use ($childIdsInYear) {
                    $q->whereIn('Child.ChildID', $childIdsInYear);
                })
                ->when($mealType, function ($q) use ($mealType) {
                    if ($mealType === 'dejeuner') {
                        $q->whereRaw('LOWER(Mealscategory.Name) = ?', ['lunch']);
                    } elseif ($mealType === 'gouter') {
                        $q->where(function ($sub) {
                            $sub->whereRaw('LOWER(Mealscategory.Name) IN (?, ?, ?, ?)', ['snack', 'snacks', 'goûter', 'gouter']);
                        });
                    }
                })
                ->select(
                    'Child.ChildID',
                    'Child.Firstname',
                    'Child.Lastname',
                    'Class.Name as class_name',
                    'Childfoodexception.ChildfoodexceptionID as exception_id',
                    'Childfoodexception.Reason',
                    'Meals.MealsID',
                    'Meals.Name as meal_name'
                )
                ->get();

            if ($rows->isEmpty()) {
                return response()->json(['success' => true, 'data' => []]);
            }

            // ──────────────────────────────────────────────────────────
            // Step 3: For each unique child, load their dietary comment
            // from the exact inscription matching the planning bounds.
            // ──────────────────────────────────────────────────────────
            $uniqueChildIds = $rows->pluck('ChildID')->unique()->values()->toArray();

            $dietaryComments = collect();
            if ($planning) {
                $inscriptionIds = $inscriptionByChild
                    ->filter(fn ($inscription, $childId) => in_array((int) $childId, $uniqueChildIds, true))
                    ->map(fn ($inscription) => $inscription->InscriptionID)
                    ->filter()
                    ->values();

                $dietaryRows = DB::table('Medicalform')
                    ->join('Dietarycomment', 'Medicalform.DietarycommentID', '=', 'Dietarycomment.DietarycommentID')
                    ->whereIn('Medicalform.InscriptionID', $inscriptionIds)
                    ->select('Medicalform.InscriptionID', 'Dietarycomment.Dietarycomment as dietary_comment')
                    ->get()
                    ->keyBy('InscriptionID');

                $dietaryComments = $inscriptionByChild
                    ->filter(fn ($inscription, $childId) => in_array((int) $childId, $uniqueChildIds, true))
                    ->map(function ($inscription) use ($dietaryRows) {
                        return $dietaryRows[$inscription->InscriptionID]->dietary_comment ?? null;
                    });
            } else {
                $dietaryComments = DB::table('Payment')
                    ->join('Inscription', 'Payment.InscriptionID', '=', 'Inscription.InscriptionID')
                    ->join('Medicalform', 'Inscription.InscriptionID', '=', 'Medicalform.InscriptionID')
                    ->join('Dietarycomment', 'Medicalform.DietarycommentID', '=', 'Dietarycomment.DietarycommentID')
                    ->whereIn('Payment.ChildID', $uniqueChildIds)
                    ->whereNotNull('Medicalform.DietarycommentID')
                    ->select(
                        'Payment.ChildID',
                        'Dietarycomment.Dietarycomment as dietary_comment'
                    )
                    ->get()
                    ->groupBy('ChildID')
                    ->map(function ($group) {
                        return $group->first()->dietary_comment ?? null;
                    });
            }

            // ──────────────────────────────────────────────────────────
            // Step 4: Group the flat rows by ChildID, building the
            // structured response array the frontend expects.
            // ──────────────────────────────────────────────────────────
            $grouped = [];
            foreach ($rows as $row) {
                $childId = $row->ChildID;

                if (!isset($grouped[$childId])) {
                    $childInscription = $inscriptionByChild[$childId] ?? null;
                    $grouped[$childId] = [
                        'child_id'        => $childId,
                        'child_name'      => trim($row->Firstname . ' ' . $row->Lastname),
                        'class_name'      => $row->class_name ?? 'Non assigné',
                        'exception_count' => 0,
                        'dietary_comment' => $dietaryComments[$childId] ?? null,
                        'meal_plan_id'    => $childInscription->MealplanID ?? null,
                        'exceptions'      => [],
                    ];
                }

                // Avoid duplicate meal entries for the same child
                $alreadyAdded = collect($grouped[$childId]['exceptions'])
                    ->contains('meal_id', $row->MealsID);

                if (!$alreadyAdded) {
                    $grouped[$childId]['exceptions'][] = [
                        'exception_id' => $row->exception_id,
                        'meal_id'   => $row->MealsID,
                        'meal_name' => $row->meal_name,
                        'reason'    => $row->Reason,
                    ];
                    $grouped[$childId]['exception_count']++;
                }
            }

            return response()->json([
                'success' => true,
                'data'    => array_values($grouped),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving food exceptions.',
            ], 500);
        }
    }

    /**
     * Add Food Exception
     *
     * Manually creates a food exception for a child, linking it to one or more meals.
     *
     * @authenticated
     *
     * @bodyParam child_id int required The ChildID. Example: 15
     * @bodyParam meal_ids int[] required Array of MealsIDs to forbid. Example: [8, 14]
     * @bodyParam reason string required Reason for the restriction. Example: Allergie aux arachides
     *
     * @response 201 {
     *   "success": true,
     *   "message": "Food exception added.",
     *   "data": { "id": 5 }
     * }
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'child_id' => 'required|integer|exists:Child,ChildID',
            'planning_id' => 'nullable|integer|exists:Planning,PlanningID',
            'meal_ids' => 'required|array|min:1',
            'meal_ids.*' => 'integer|exists:Meals,MealsID',
            'reason' => 'required|string|max:1000',
        ]);

        $planningId = $request->input('planning_id') ? (int) $request->input('planning_id') : null;

        if ($planningId) {
            $isChildInPlanning = DB::table('ChildClass')
                ->join('Class', 'ChildClass.ClassID', '=', 'Class.ClassID')
                ->where('ChildClass.ChildID', $request->child_id)
                ->where('Class.PlanningID', $planningId)
                ->exists();

            if (!$isChildInPlanning) {
                return response()->json([
                    'success' => false,
                    'message' => 'The selected child is not enrolled in the chosen planning year.',
                ], 422);
            }
        }

        try {
            DB::beginTransaction();

            $exceptionId = DB::table('Childfoodexception')->insertGetId([
                'ChildID' => $request->child_id,
                'Reason' => $request->reason,
            ]);

            foreach ($request->meal_ids as $mealId) {
                DB::table('ChildFoodExceptionMeals')->insert([
                    'ChildfoodexceptionID' => $exceptionId,
                    'MealsID' => $mealId,
                ]);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Food exception added.',
                'data' => ['id' => $exceptionId],
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to add food exception.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Remove Food Exception
     *
     * Deletes a food exception record and its meal pivot rows.
     *
     * @authenticated
     *
     * @urlParam id int required The ChildfoodexceptionID. Example: 5
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Food exception removed."
     * }
     */
    public function destroy(int $id): JsonResponse
    {
        $exception = DB::table('Childfoodexception')
            ->where('ChildfoodexceptionID', $id)
            ->first();

        if (!$exception) {
            return response()->json([
                'success' => false,
                'message' => 'Food exception not found.',
            ], 404);
        }

        try {
            DB::beginTransaction();
            DB::table('ChildFoodExceptionMeals')
                ->where('ChildfoodexceptionID', $id)
                ->delete();
            DB::table('Childfoodexception')
                ->where('ChildfoodexceptionID', $id)
                ->delete();
            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Food exception removed.',
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to remove food exception.',
            ], 500);
        }
    }
}
