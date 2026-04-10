<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/**
 * @group Admin - Menu Planning
 *
 * APIs for managing saved weekly meal plan presets (templates) and applying
 * them to specific calendar weeks. Works with the Menuplanning, Dailyplan,
 * and DailyPlanMeals tables.
 */
class MenuPlanningController extends Controller
{
    /**
     * List All Presets
     *
     * Retrieves every saved menu-planning preset (template) the admin has created.
     *
     * @authenticated
     * @response {
     *   "success": true,
     *   "data": [
     *     { "id": 1, "name": "Semaine Bio" }
     *   ]
     * }
     */
    public function index(): JsonResponse
    {
        // Manual presets have their Dailyplan.Date set to NULL.
        // Calendar weeks (Semaine YYYY-MM-DD) have their Dailyplan.Date populated.
        $presets = DB::table('Menuplanning')
            ->join('Dailyplan', 'Menuplanning.MenuplanningID', '=', 'Dailyplan.MenuplanningID')
            ->whereNull('Dailyplan.Date')
            ->select('Menuplanning.MenuplanningID as id', 'Menuplanning.Name as name')
            ->distinct()
            ->get();

        return response()->json([
            'success' => true,
            'data' => $presets,
        ]);
    }

    /**
     * Show Preset Details
     *
     * Retrieves a single preset with its per-day meal IDs and any saved
     * exception overrides so the admin can reload it onto a new week.
     *
     * @authenticated
     * @urlParam id int required The MenuplanningID. Example: 1
     *
     * @response {
     *   "success": true,
     *   "data": {
     *     "id": 1,
     *     "name": "Semaine Bio",
     *     "days": [
     *       { "id": 1, "meal_ids": [1, 3, 5] }
     *     ],
     *     "exception_overrides": []
     *   }
     * }
     */
    public function show(int $id): JsonResponse
    {
        $preset = DB::table('Menuplanning')
            ->where('MenuplanningID', $id)
            ->first();

        if (!$preset) {
            return response()->json(['success' => false, 'message' => 'Preset not found.'], 404);
        }

        // Get all daily plans for this preset
        $dailyPlans = DB::table('Dailyplan')
            ->where('MenuplanningID', $id)
            ->select('DailyplanID', 'Date')
            ->orderBy('Date')
            ->get();

        $days = [];
        $dayIndex = 1; // Sequential 1-based index expected by the frontend
        foreach ($dailyPlans as $dp) {
            $mealIds = DB::table('DailyPlanMeals')
                ->where('DailyplanID', $dp->DailyplanID)
                ->pluck('MealsID')
                ->toArray();

            $days[] = [
                'id' => $dayIndex++,
                'meal_ids' => $mealIds,
            ];
        }

        // Get exception overrides linked to this preset's daily plans
        $dailyPlanIds = $dailyPlans->pluck('DailyplanID')->toArray();
        $exceptionOverrides = [];

        if (!empty($dailyPlanIds)) {
            // Get overrides from ChildFoodExceptionOverrideMeals + MealsChildFoodExceptionOverride
            // that are linked to meals in this preset
            $overrides = DB::table('Childfoodexceptionoverride as cfo')
                ->join('ChildFoodExceptionOverrideMeals as cfoem', 'cfo.ChildfoodexceptionoverrideID', '=', 'cfoem.ChildfoodexceptionoverrideID')
                ->leftJoin('MealsChildFoodExceptionOverride as mcfeo', 'cfo.ChildfoodexceptionoverrideID', '=', 'mcfeo.ChildfoodexceptionoverrideID')
                ->select(
                    'cfoem.original_meal as original_meal_id',
                    'mcfeo.replacement_meal as replacement_meal_id',
                    'cfo.Dayindex as day_index',
                    'cfo.Weekstartdate as week_start'
                )
                ->get();

            foreach ($overrides as $ov) {
                $exceptionOverrides[] = [
                    'original_meal_id' => $ov->original_meal_id,
                    'replacement_meal_id' => $ov->replacement_meal_id,
                    'day_index' => $ov->day_index,
                ];
            }
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => (int) $preset->MenuplanningID,
                'name' => $preset->Name,
                'days' => $days,
                'exception_overrides' => $exceptionOverrides,
            ],
        ]);
    }

    /**
     * Save Preset
     *
     * Persists the current week layout as a named template (preset) for
     * future reuse, including optional exception overrides.
     *
     * @authenticated
     * @bodyParam name string required The preset name. Example: Semaine Bio
     * @bodyParam days array required Array of day objects.
     * @bodyParam days[].day_index int required The day index (0=Mon … 4=Fri). Example: 0
     * @bodyParam days[].meal_ids int[] required Array of MealsIDs for this day. Example: [1, 3, 5]
     * @bodyParam exception_overrides array optional Saved child exception overrides.
     *
     * @response 201 {
     *   "success": true,
     *   "message": "Menu preset saved."
     * }
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'days' => 'required|array',
            'days.*.day_index' => 'required|integer|min:0|max:4',
            'days.*.meal_ids' => 'present|array',
            'exception_overrides' => 'nullable|array',
        ]);

        DB::beginTransaction();
        try {
            // Create the Menuplanning record
            $menuPlanningId = DB::table('Menuplanning')->insertGetId([
                'Name' => $request->input('name'),
            ], 'MenuplanningID');

            // Create Dailyplan rows for each day and attach meals
            foreach ($request->input('days') as $day) {
                $mealIds = $day['meal_ids'] ?? [];
                if (empty($mealIds)) continue; // Skip empty days

                $dailyPlanId = DB::table('Dailyplan')->insertGetId([
                    'Date' => null, // Presets don't have calendar dates
                    'MenuplanningID' => $menuPlanningId,
                ], 'DailyplanID');

                foreach ($mealIds as $mealId) {
                    DB::table('DailyPlanMeals')->insert([
                        'MealsID' => $mealId,
                        'DailyplanID' => $dailyPlanId,
                    ]);
                }
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Menu preset saved.',
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * Apply Week
     *
     * Writes or overwrites the meal plan for a specific calendar week.
     * Creates or reuses a Menuplanning, then creates Dailyplan rows
     * (one per weekday) and attaches each day's MealsIDs via DailyPlanMeals.
     *
     * @authenticated
     * @bodyParam week_start string required The Monday date (YYYY-MM-DD). Example: 2026-04-06
     * @bodyParam days array required Array of day objects.
     * @bodyParam days[].day_index int required The day index (0=Mon … 4=Fri). Example: 0
     * @bodyParam days[].meal_ids int[] required Array of MealsIDs. Example: [1, 3, 5]
     *
     * @response {
     *   "success": true,
     *   "message": "Week plan saved."
     * }
     */
    public function applyWeek(Request $request): JsonResponse
    {
        $request->validate([
            'week_start' => 'required|date',
            'days' => 'required|array',
            'days.*.day_index' => 'required|integer|min:0|max:4',
            'days.*.meal_ids' => 'present|array',
        ]);

        $weekStart = new \DateTime($request->input('week_start'));

        DB::beginTransaction();
        try {
            // Compute all 5 weekday dates
            $weekDates = [];
            for ($i = 0; $i < 5; $i++) {
                $weekDates[$i] = (clone $weekStart)->modify("+{$i} days")->format('Y-m-d');
            }

            // Delete existing daily plans for this week range
            $existingPlanIds = DB::table('Dailyplan')
                ->whereBetween('Date', [$weekDates[0], $weekDates[4]])
                ->pluck('DailyplanID');

            if ($existingPlanIds->isNotEmpty()) {
                DB::table('DailyPlanMeals')
                    ->whereIn('DailyplanID', $existingPlanIds)
                    ->delete();
                DB::table('Dailyplan')
                    ->whereIn('DailyplanID', $existingPlanIds)
                    ->delete();
            }

            // Create or reuse a Menuplanning for this week
            $weekLabel = 'Semaine ' . $weekStart->format('Y-m-d');
            $menuPlanningId = DB::table('Menuplanning')
                ->where('Name', $weekLabel)
                ->value('MenuplanningID');

            if (!$menuPlanningId) {
                $menuPlanningId = DB::table('Menuplanning')->insertGetId([
                    'Name' => $weekLabel,
                ], 'MenuplanningID');
            }

            // Create Dailyplan rows for each day and attach meals
            foreach ($request->input('days') as $day) {
                $dayIndex = $day['day_index'];
                $dateStr = $weekDates[$dayIndex] ?? null;
                $mealIds = $day['meal_ids'] ?? [];
                if (!$dateStr || empty($mealIds)) continue; // Skip empty days

                $dailyPlanId = DB::table('Dailyplan')->insertGetId([
                    'Date' => $dateStr,
                    'MenuplanningID' => $menuPlanningId,
                ], 'DailyplanID');

                foreach ($mealIds as $mealId) {
                    DB::table('DailyPlanMeals')->insert([
                        'MealsID' => (int) $mealId,
                        'DailyplanID' => $dailyPlanId,
                    ]);
                }
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Week plan saved.',
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * Delete Preset
     *
     * Permanently removes a saved menu-planning preset and its associated
     * Dailyplan and DailyPlanMeals rows.
     *
     * @authenticated
     * @urlParam id int required The MenuplanningID. Example: 1
     *
     * @response {
     *   "success": true,
     *   "message": "Menu preset deleted."
     * }
     */
    public function destroy(int $id): JsonResponse
    {
        DB::beginTransaction();
        try {
            // Get all daily plan IDs linked to this preset
            $dailyPlanIds = DB::table('Dailyplan')
                ->where('MenuplanningID', $id)
                ->pluck('DailyplanID');

            // Delete meal links
            if ($dailyPlanIds->isNotEmpty()) {
                DB::table('DailyPlanMeals')
                    ->whereIn('DailyplanID', $dailyPlanIds)
                    ->delete();
            }

            // Delete daily plans
            DB::table('Dailyplan')
                ->where('MenuplanningID', $id)
                ->delete();

            // Delete the preset itself
            DB::table('Menuplanning')
                ->where('MenuplanningID', $id)
                ->delete();

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Menu preset deleted.',
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }
}
