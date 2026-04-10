<?php

namespace App\Http\Controllers\Api\Teacher;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

/**
 * @group Teacher — Daily Plan & Activities
 *
 * Endpoints for viewing and managing scheduled daily activities
 * within the teacher's assigned classes.
 */
class DailyPlanController extends Controller
{
    /**
     * List daily plan activities.
     *
     * Returns the scheduled activities for the teacher's class on a given date.
     * If no `date` query parameter is provided, defaults to today.
     *
     * @queryParam date string Optional ISO date (YYYY-MM-DD). Defaults to today. Example: 2026-03-05
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Daily plan retrieved.",
     *   "data": [
     *     {
     *       "id": 10,
     *       "plan_day_id": 5,
     *       "title": "Atelier peinture",
     *       "description": "Session de peinture libre",
     *       "date": "2026-03-05",
     *       "start_time": "09:00",
     *       "end_time": "10:00",
     *       "status": "en_cours",
     *       "teacher_name": "Fatma Mrad"
     *     }
     *   ]
     * }
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user || $user->RoleID !== 1) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $date = $request->query('date', \Carbon\Carbon::today()->toDateString());
        $teacherId = $user->PersonID;

        $activities = \Illuminate\Support\Facades\DB::table('Planday')
            ->join('Plandayactivity', 'Planday.PlandayID', '=', 'Plandayactivity.PlandayID')
            ->join('Activity', 'Plandayactivity.ActivityID', '=', 'Activity.ActivityID')
            ->join('TeacherClass', 'Planday.ClassID', '=', 'TeacherClass.ClassID')
            ->leftJoin('Account', 'Account.PersonID', '=', 'TeacherClass.TeacherID')
            ->where('TeacherClass.TeacherID', $teacherId)
            ->where('Account.RoleID', 1)
            ->where('Planday.Date', $date)
            ->select(
                'Plandayactivity.PlandayactivityID as id',
                'Planday.PlandayID as plan_day_id',
                'Activity.Title as title',
                'Activity.Description as description',
                'Planday.Date as date',
                'Plandayactivity.Starttime as start_time',
                'Plandayactivity.Endtime as end_time',
                'Plandayactivity.Status as status',
                \Illuminate\Support\Facades\DB::raw("CONCAT(Account.Firstname, ' ', Account.Lastname) as teacher_name")
            )
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Daily plan retrieved.',
            'data' => $activities
        ]);
    }

    /**
     * Show a specific plan activity.
     *
     * Returns full details for a single scheduled activity, including
     * its parent Activity metadata and time slot information.
     *
     * @urlParam id integer required The PlandayactivityID. Example: 10
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Plan activity details.",
     *   "data": {
     *     "id": 10,
     *     "plan_day_id": 5,
     *     "title": "Atelier peinture",
     *     "description": "Session de peinture libre",
     *     "date": "2026-03-05",
     *     "start_time": "09:00",
     *     "end_time": "10:00",
     *     "status": "en_cours"
     *   }
     * }
     *
     * @response 404 {
     *   "success": false,
     *   "message": "Activity not found."
     * }
     */
    public function show(int $id): JsonResponse
    {
        $activity = \Illuminate\Support\Facades\DB::table('Plandayactivity')
            ->join('Planday', 'Plandayactivity.PlandayID', '=', 'Planday.PlandayID')
            ->join('Activity', 'Plandayactivity.ActivityID', '=', 'Activity.ActivityID')
            ->where('Plandayactivity.PlandayactivityID', $id)
            ->select(
                'Plandayactivity.PlandayactivityID as id',
                'Planday.PlandayID as plan_day_id',
                'Activity.Title as title',
                'Activity.Description as description',
                'Planday.Date as date',
                'Plandayactivity.Starttime as start_time',
                'Plandayactivity.Endtime as end_time',
                'Plandayactivity.Status as status'
            )
            ->first();

        if (!$activity) {
            return response()->json([
                'success' => false,
                'message' => 'Activity not found.'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Plan activity details.',
            'data' => $activity
        ]);
    }

    /**
     * Update activity execution status.
     *
     * Allows the teacher to mark an activity as executed or not_executed.
     * The frontend sends a PATCH with the new status value.
     *
     * @urlParam id integer required The PlandayactivityID. Example: 10
     *
     * @bodyParam status string required The new status. Allowed: executed, not_executed. Example: executed
     * @bodyParam plan_day_id integer optional The PlandayID for validation. Example: 5
     * @bodyParam planning_label string optional Current planning label. Example: 2025/2026
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Status updated."
     * }
     *
     * @response 422 {
     *   "success": false,
     *   "message": "Invalid status value."
     * }
     */
    public function updateStatus(Request $request, int $id): JsonResponse
    {
        $validated = $request->validate([
            'status' => 'required|string|in:executed,not_executed,en_cours'
        ]);

        $updated = \Illuminate\Support\Facades\DB::table('Plandayactivity')
            ->where('PlandayactivityID', $id)
            ->update(['Status' => $validated['status']]);

        if (!$updated) {
            return response()->json([
                'success' => false,
                'message' => 'Activity not found.'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Status updated.'
        ]);
    }

    public function activitiesByClass(Request $request, string $cin, int $classId): JsonResponse
    {
        $activities = \Illuminate\Support\Facades\DB::table('Planday')
            ->join('Plandayactivity', 'Planday.PlandayID', '=', 'Plandayactivity.PlandayID')
            ->join('Activity', 'Plandayactivity.ActivityID', '=', 'Activity.ActivityID')
            ->where('Planday.ClassID', $classId)
            ->select(
                'Plandayactivity.PlandayactivityID as id',
                'Planday.PlandayID as plan_day_id',
                'Activity.Title as title',
                'Activity.Description as description',
                'Planday.Date as date',
                'Plandayactivity.Starttime as start_time',
                'Plandayactivity.Endtime as end_time',
                'Plandayactivity.Status as status'
            )
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Class activities retrieved.',
            'data' => $activities
        ]);
    }
}
