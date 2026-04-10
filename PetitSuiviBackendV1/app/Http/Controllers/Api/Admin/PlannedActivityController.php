<?php
namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PlannedActivityController extends Controller
{
    /**
     * @group Admin - Activities
     * @authenticated
     * @response { "success": true, "data": [] }
     */
    public function index(Request $request, int $planningId): JsonResponse
    {
        $plandays = \App\Models\Planday::with('schoolClass')->where('PlanningID', $planningId)->get();
        if ($plandays->isEmpty()) {
            return response()->json(['success' => true, 'data' => []]);
        }
        $plandayIds = $plandays->pluck('PlandayID');

        $activities = \App\Models\Plandayactivity::whereIn('Plandayactivity.PlandayID', $plandayIds)
            ->join('Activity', 'Plandayactivity.ActivityID', '=', 'Activity.ActivityID')
            ->join('Planday', 'Plandayactivity.PlandayID', '=', 'Planday.PlandayID')
            ->select(
                'Plandayactivity.PlandayactivityID as id',
                'Activity.ActivityID as activity_id',
                'Activity.Title as title',
                'Activity.Description as description',
                'Planday.Date as date',
                'Planday.ClassID',
                'Plandayactivity.Starttime as start_time',
                'Plandayactivity.Endtime as end_time',
                'Plandayactivity.Status as status'
            )
            ->get();

        // Group by Date, Start Time and Activity to aggregate classes together for UI convenience
        // React UI groups them via 'classes' array mapped to identical occurrences
        $grouped = [];
        foreach ($activities as $act) {
            $classModel = $plandays->firstWhere('ClassID', $act->ClassID)?->schoolClass;
            
            $groupKey = $act->date . '_' . $act->start_time . '_' . $act->activity_id;
            
            if (!isset($grouped[$groupKey])) {
                $grouped[$groupKey] = [
                    'id' => $act->id,
                    'title' => $act->title,
                    'description' => $act->description,
                    'date' => $act->date,
                    'start_time' => $act->start_time,
                    'end_time' => $act->end_time,
                    'status' => $act->status,
                    'classes' => [],
                    'classIds' => [],
                    'teacher' => null
                ];
            }
            
            if ($classModel) {
                $grouped[$groupKey]['classes'][] = [
                    'id' => $classModel->ClassID,
                    'name' => $classModel->Name
                ];
                $grouped[$groupKey]['classIds'][] = $classModel->ClassID;
            }
        }

        return response()->json(['success' => true, 'data' => array_values($grouped)]);

        return response()->json(['success' => true, 'data' => $data]);
    }

    /**
     * @group Admin - Activities
     * @authenticated
     * @bodyParam title string required
     * @bodyParam description string optional
     * @bodyParam date string required
     * @bodyParam start_time string optional
     * @bodyParam end_time string optional
     * @bodyParam class_ids int[] required
     * @bodyParam criteria_ids int[] optional
     * @bodyParam status string required
     * @bodyParam template_id int optional
     * @response { "success": true, "message": "Activity planned." }
     */
    public function store(Request $request, int $planningId): JsonResponse
    {
        $request->validate([
            'title' => 'required_without:template_id|string',
            'description' => 'nullable|string',
            'date' => 'required|date',
            'start_time' => 'nullable|string',
            'end_time' => 'nullable|string',
            'status' => 'required|string',
            'template_id' => 'nullable|integer|exists:Activity,ActivityID',
            'class_ids' => 'required|array',
            'class_ids.*' => 'integer|exists:Class,ClassID'
        ]);

        $dayOfWeek = \Carbon\Carbon::parse($request->date)->dayOfWeek;
        if ($dayOfWeek === \Carbon\Carbon::SATURDAY || $dayOfWeek === \Carbon\Carbon::SUNDAY) {
            return response()->json([
                'success' => false,
                'message' => 'Les activités ne peuvent être planifiées que du lundi au vendredi.'
            ], 422);
        }

        // Early check for time overlaps if times are provided
        if ($request->start_time && $request->end_time) {
            foreach ($request->class_ids as $classId) {
                $overlap = \Illuminate\Support\Facades\DB::table('Plandayactivity')
                    ->join('Planday', 'Plandayactivity.PlandayID', '=', 'Planday.PlandayID')
                    ->join('Class', 'Planday.ClassID', '=', 'Class.ClassID')
                    ->join('Activity', 'Plandayactivity.ActivityID', '=', 'Activity.ActivityID')
                    ->where('Planday.Date', $request->date)
                    ->where('Planday.ClassID', $classId)
                    ->whereNotNull('Plandayactivity.Starttime')
                    ->whereNotNull('Plandayactivity.Endtime')
                    ->where('Plandayactivity.Starttime', '<', $request->end_time)
                    ->where('Plandayactivity.Endtime', '>', $request->start_time)
                    ->first();

                if ($overlap) {
                    return response()->json([
                        'success' => false,
                        'message' => 'L\'activité chevauche une autre activité ("' . $overlap->Title . '") pour la classe ' . $overlap->Name . '.'
                    ], 409);
                }
            }
        }

        \Illuminate\Support\Facades\DB::beginTransaction();
        try {
            $activityId = $request->template_id;
            if (!$activityId) {
                $newActivity = \App\Models\Activity::create([
                    'Title' => $request->title,
                    'Description' => $request->description
                ]);
                $activityId = $newActivity->ActivityID;
                if ($request->has('criteria_ids')) {
                    foreach ((array)$request->criteria_ids as $cid) {
                        \App\Models\CriteriaActivity::create([
                            'ActivityID' => $activityId,
                            'CriteriaID' => $cid
                        ]);
                    }
                }
            }

            foreach ($request->class_ids as $classId) {
                $planday = \App\Models\Planday::firstOrCreate([
                    'Date' => $request->date,
                    'PlanningID' => $planningId,
                    'ClassID' => $classId
                ]);

                \App\Models\Plandayactivity::create([
                    'Starttime' => $request->start_time,
                    'Endtime' => $request->end_time,
                    'Status' => $request->status,
                    'ActivityID' => $activityId,
                    'PlandayID' => $planday->PlandayID
                ]);
            }

            \Illuminate\Support\Facades\DB::commit();
            return response()->json(['success' => true, 'message' => 'Activity planned.'], 201);
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\DB::rollBack();
            return response()->json(['success' => false, 'message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    /**
     * @group Admin - Activities
     * @authenticated
     * @response { "success": true, "message": "Planned activity deleted." }
     */
    public function destroy(int $planningId, int $activityId): JsonResponse
    {
        $plannedActivity = \App\Models\Plandayactivity::find($activityId);
        if (!$plannedActivity) {
            return response()->json(['success' => false, 'message' => 'Not found'], 404);
        }
        $plannedActivity->delete();
        return response()->json(['success' => true, 'message' => 'Planned activity deleted.']);
    }

    /**
     * Get all planned activities for a specific date.
     *
     * @group Admin - Activities
     * @authenticated
     * @urlParam date string required The date in YYYY-MM-DD format.
     */
    public function getByDate(string $date): JsonResponse
    {
        $rows = \Illuminate\Support\Facades\DB::select("
            SELECT
                pa.PlandayactivityID as id,
                a.Title as title,
                a.Description as description,
                pd.Date as date,
                pa.Starttime as start_time,
                pa.Endtime as end_time,
                pa.Status as status,
                pd.ClassID as class_id,
                c.Name as class_name,
                ct.TeacherID as teacher_cin
            FROM Plandayactivity pa
            JOIN Planday pd ON pa.PlandayID = pd.PlandayID
            JOIN Activity a ON pa.ActivityID = a.ActivityID
            LEFT JOIN Class c ON pd.ClassID = c.ClassID
            LEFT JOIN TeacherClass ct ON c.ClassID = ct.ClassID
            WHERE pd.Date = ?
        ", [$date]);

        $activities = collect($rows)->map(fn($r) => [
            'id' => $r->id,
            'title' => $r->title,
            'description' => $r->description,
            'date' => $r->date,
            'start_time' => $r->start_time,
            'end_time' => $r->end_time,
            'status' => $r->status,
            'class' => $r->class_id ? ['id' => $r->class_id, 'name' => $r->class_name] : null,
            'teacher_id' => $r->teacher_cin,
        ]);

        return response()->json(['data' => $activities]);
    }
}
