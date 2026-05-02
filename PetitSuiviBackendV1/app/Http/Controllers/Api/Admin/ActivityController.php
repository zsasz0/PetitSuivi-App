<?php
namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ActivityController extends Controller
{
    /**
     * @group Admin - Activities
     * @authenticated
     * @response { "success": true, "data": [] }
     */
    public function index(Request $request): JsonResponse
    {
        $activities = \App\Models\Activity::all();
        $planningUsageCounts = \App\Models\Plandayactivity::selectRaw('ActivityID, COUNT(*) as usage_count')
            ->groupBy('ActivityID')
            ->pluck('usage_count', 'ActivityID');
        
        $criteriaPivots = \App\Models\CriteriaActivity::join('Criteria', 'CriteriaActivity.CriteriaID', '=', 'Criteria.CriteriaID')
            ->select('CriteriaActivity.ActivityID', 'Criteria.CriteriaID as id', 'Criteria.Name as name')
            ->get()
            ->groupBy('ActivityID');

        $data = $activities->map(function ($activity) use ($criteriaPivots, $planningUsageCounts) {
            $planningUsageCount = (int) ($planningUsageCounts[$activity->ActivityID] ?? 0);

            return [
                'id' => $activity->ActivityID,
                'title' => $activity->Title,
                'description' => $activity->Description,
                'is_used_in_planning' => $planningUsageCount > 0,
                'planning_usage_count' => $planningUsageCount,
                'criteria' => $criteriaPivots->get($activity->ActivityID, collect())->map(function ($p) {
                    return ['id' => $p->id, 'name' => $p->name];
                })->values()
            ];
        });

        return response()->json(['success' => true, 'data' => $data]);
    }

    /**
     * @group Admin - Activities
     * @authenticated
     * @bodyParam title string required Format: string
     * @bodyParam description string optional Format: string
     * @bodyParam criteria_ids int[] optional Format: array
     * @response { "success": true, "data": {} }
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'title' => 'required|string',
            'description' => 'nullable|string',
            'criteria_ids' => 'nullable|array',
            'criteria_ids.*' => 'integer|exists:Criteria,CriteriaID'
        ]);

        \Illuminate\Support\Facades\DB::beginTransaction();
        try {
            $activity = \App\Models\Activity::create([
                'Title' => $request->title,
                'Description' => $request->description
            ]);

            $criteriaRes = [];
            if ($request->filled('criteria_ids')) {
                foreach ($request->criteria_ids as $cid) {
                    \App\Models\CriteriaActivity::create([
                        'ActivityID' => $activity->ActivityID,
                        'CriteriaID' => $cid
                    ]);
                }
                
                $criteriaRes = \App\Models\Criteria::whereIn('CriteriaID', $request->criteria_ids)
                    ->get(['CriteriaID as id', 'Name as name']);
            }

            \Illuminate\Support\Facades\DB::commit();

            return response()->json([
                'success' => true,
                'data' => [
                    'id' => $activity->ActivityID,
                    'title' => $activity->Title,
                    'description' => $activity->Description,
                    'criteria' => $criteriaRes
                ]
            ], 201);
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\DB::rollBack();
            return response()->json(['success' => false, 'message' => 'Error creating activity.'], 500);
        }
    }

    /**
     * @group Admin - Activities
     * @authenticated
     * @bodyParam title string required Format: string
     * @bodyParam description string optional Format: string
     * @bodyParam criteria_ids int[] optional Format: array
     * @response { "success": true, "data": {} }
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $request->validate([
            'title' => 'required|string',
            'description' => 'nullable|string',
            'criteria_ids' => 'nullable|array',
            'criteria_ids.*' => 'integer|exists:Criteria,CriteriaID'
        ]);

        $activity = \App\Models\Activity::find($id);
        if (!$activity) return response()->json(['success' => false, 'message' => 'Not found'], 404);

        \Illuminate\Support\Facades\DB::beginTransaction();
        try {
            $activity->update([
                'Title' => $request->title,
                'Description' => $request->description
            ]);

            if ($request->has('criteria_ids')) {
                \App\Models\CriteriaActivity::where('ActivityID', $id)->delete();
                foreach ($request->criteria_ids as $cid) {
                    \App\Models\CriteriaActivity::create([
                        'ActivityID' => $id,
                        'CriteriaID' => $cid
                    ]);
                }
            }

            $criteriaRes = \App\Models\CriteriaActivity::join('Criteria', 'CriteriaActivity.CriteriaID', '=', 'Criteria.CriteriaID')
                ->where('CriteriaActivity.ActivityID', $id)
                ->get(['Criteria.CriteriaID as id', 'Criteria.Name as name']);

            \Illuminate\Support\Facades\DB::commit();

            return response()->json([
                'success' => true,
                'data' => [
                    'id' => $activity->ActivityID,
                    'title' => $activity->Title,
                    'description' => $activity->Description,
                    'criteria' => $criteriaRes
                ]
            ]);
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\DB::rollBack();
            return response()->json(['success' => false, 'message' => 'Error updating activity.'], 500);
        }
    }

    /**
     * @group Admin - Activities
     * @authenticated
     * @response { "success": true, "message": "Activity removed." }
     */
    public function destroy(int $id): JsonResponse
    {
        $activity = \App\Models\Activity::find($id);
        if (!$activity) return response()->json(['success' => false, 'message' => 'Not found'], 404);

        $planningUsageCount = \App\Models\Plandayactivity::where('ActivityID', $id)->count();
        if ($planningUsageCount > 0) {
            return response()->json([
                'success' => false,
                'message' => 'Impossible de supprimer cette activité car elle est utilisée dans un ou plusieurs plannings.'
            ], 409);
        }
        
        \Illuminate\Support\Facades\DB::beginTransaction();
        try {
            \App\Models\CriteriaActivity::where('ActivityID', $id)->delete();
            $activity->delete();
            \Illuminate\Support\Facades\DB::commit();
            return response()->json(['success' => true, 'message' => 'Activity removed.']);
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\DB::rollBack();
            return response()->json(['success' => false, 'message' => 'Error deleting activity.'], 500);
        }
    }
}
