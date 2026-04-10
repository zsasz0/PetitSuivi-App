<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/**
 * @group Admin - Child Food Exception Overrides
 *
 * APIs for managing per-child meal replacement overrides. When the AI detects
 * a dietary conflict between a child and a scheduled meal, the admin can
 * assign an alternative meal (or remove the meal entirely). These overrides
 * are scoped to a specific week and day index.
 *
 * Database tables:
 *   - Childfoodexceptionoverride (PK: ChildfoodexceptionoverrideID, cols: Dayindex, Weekstartdate, replacement_meal FK→Meals)
 *   - ChildFoodExceptionOverrideMeals (cols: original_meal FK→Meals, ChildfoodexceptionoverrideID FK)
 *   - MealsChildFoodExceptionOverride (cols: ChildfoodexceptionoverrideID FK, replacement_meal FK→Meals)
 *
 * The frontend reads overrides via GET and expects:
 *   { child_id, original_meal_id, replacement_meal_id, day_index, week_start }
 *
 * Note: The Childfoodexceptionoverride table does NOT have a ChildID column directly.
 * The child link goes through Childfoodexception → ChildFoodExceptionMeals → meal,
 * so we store the child_id contextually in the override's original_meal association.
 */
class ChildFoodExceptionOverrideController extends Controller
{
    /**
     * List Overrides for a Week
     *
     * Retrieves all child food exception overrides for the specified week.
     * Joins through Childfoodexceptionoverride → ChildFoodExceptionOverrideMeals
     * (original meal) and MealsChildFoodExceptionOverride (replacement meal)
     * to build the flat response the frontend expects.
     *
     * @authenticated
     * @queryParam week_start string required The Monday date (YYYY-MM-DD). Example: 2026-04-06
     *
     * @response {
     *   "success": true,
     *   "data": [
     *     {
     *       "child_id": 10,
     *       "original_meal_id": 3,
     *       "replacement_meal_id": 7,
     *       "day_index": 0,
     *       "week_start": "2026-04-06"
     *     }
     *   ]
     * }
     */
    public function index(Request $request): JsonResponse
    {
        $weekStart = $request->query('week_start');

        $query = DB::table('Childfoodexceptionoverride as cfo')
            ->leftJoin('ChildFoodExceptionOverrideMeals as cfoem', 'cfo.ChildfoodexceptionoverrideID', '=', 'cfoem.ChildfoodexceptionoverrideID')
            ->leftJoin('MealsChildFoodExceptionOverride as mcfeo', 'cfo.ChildfoodexceptionoverrideID', '=', 'mcfeo.ChildfoodexceptionoverrideID')
            ->select(
                'cfo.ChildfoodexceptionoverrideID',
                'cfo.Dayindex as day_index',
                'cfo.Weekstartdate as week_start',
                'cfo.replacement_meal as cfo_replacement_meal',
                'cfo.ChildID',
                'cfoem.original_meal as original_meal_id',
                'mcfeo.replacement_meal as replacement_meal_id'
            );

        if ($weekStart) {
            $query->where('cfo.Weekstartdate', $weekStart);
        }

        $rows = $query->get();

        $result = [];
        foreach ($rows as $row) {
            $originalMealId = $row->original_meal_id;
            $replacementMealId = $row->replacement_meal_id ?? $row->cfo_replacement_meal;

            $result[] = [
                'child_id' => $row->ChildID ? (int)$row->ChildID : null,
                'original_meal_id' => $originalMealId ? (int) $originalMealId : null,
                'replacement_meal_id' => $replacementMealId ? (int) $replacementMealId : null,
                'day_index' => (int) $row->day_index,
                'week_start' => $row->week_start,
            ];
        }

        return response()->json([
            'success' => true,
            'data' => $result,
        ]);
    }

    /**
     * Save Override(s)
     *
     * Creates or updates meal replacement overrides for a child on a
     * specific day and week. Supports both single override and batch
     * (via `overrides` array) payloads.
     */
    public function store(Request $request): JsonResponse
    {
        DB::beginTransaction();
        try {
            if ($request->has('overrides') && is_array($request->input('overrides'))) {
                foreach ($request->input('overrides') as $ov) {
                    $this->upsertOverride(
                        $ov['child_id'] ?? null,
                        $ov['original_meal_id'] ?? null,
                        $ov['replacement_meal_id'] ?? null,
                        $ov['day_index'] ?? 0,
                        $ov['week_start'] ?? null
                    );
                }
            } else {
                $childId = $request->input('child_id');
                $originalMealId = $request->input('original_meal_id');
                $dayIndex = $request->input('day_index', 0);
                $weekStartDate = $request->input('week_start');
                $replacementMealIds = $request->input('replacement_meal_ids', []);

                // Delete existing for this specific child + meal + day
                $this->deleteExistingOverrides($childId, $originalMealId, $dayIndex, $weekStartDate);

                foreach ($replacementMealIds as $replacementId) {
                    $this->upsertOverride(
                        $childId,
                        $originalMealId,
                        $replacementId,
                        $dayIndex,
                        $weekStartDate
                    );
                }
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Override(s) saved.',
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    private function deleteExistingOverrides(?int $childId, ?int $originalMealId, int $dayIndex, ?string $weekStart): void
    {
        if (!$originalMealId || !$weekStart || !$childId) return;

        $existingIds = DB::table('Childfoodexceptionoverride as cfo')
            ->join('ChildFoodExceptionOverrideMeals as cfoem', 'cfo.ChildfoodexceptionoverrideID', '=', 'cfoem.ChildfoodexceptionoverrideID')
            ->where('cfo.ChildID', $childId)
            ->where('cfoem.original_meal', $originalMealId)
            ->where('cfo.Dayindex', $dayIndex)
            ->where('cfo.Weekstartdate', $weekStart)
            ->pluck('cfo.ChildfoodexceptionoverrideID')
            ->toArray();

        if (!empty($existingIds)) {
            DB::table('ChildFoodExceptionOverrideMeals')->whereIn('ChildfoodexceptionoverrideID', $existingIds)->delete();
            DB::table('MealsChildFoodExceptionOverride')->whereIn('ChildfoodexceptionoverrideID', $existingIds)->delete();
            DB::table('Childfoodexceptionoverride')->whereIn('ChildfoodexceptionoverrideID', $existingIds)->delete();
        }
    }

    private function upsertOverride(?int $childId, ?int $originalMealId, ?int $replacementMealId, int $dayIndex, ?string $weekStart): void
    {
        $overrideId = DB::table('Childfoodexceptionoverride')->insertGetId([
            'ChildID' => $childId,
            'Dayindex' => $dayIndex,
            'Weekstartdate' => $weekStart,
            'replacement_meal' => $replacementMealId,
        ], 'ChildfoodexceptionoverrideID');

        if ($originalMealId) {
            DB::table('ChildFoodExceptionOverrideMeals')->insert([
                'original_meal' => $originalMealId,
                'ChildfoodexceptionoverrideID' => $overrideId,
            ]);
        }

        if ($replacementMealId !== null) {
            DB::table('MealsChildFoodExceptionOverride')->insert([
                'ChildfoodexceptionoverrideID' => $overrideId,
                'replacement_meal' => $replacementMealId,
            ]);
        }
    }
}
