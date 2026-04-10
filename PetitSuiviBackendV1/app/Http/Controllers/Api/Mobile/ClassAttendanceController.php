<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/**
 * @group Mobile - Attendance
 *
 * APIs for managing classroom attendance (presences) within the mobile application.
 */
class ClassAttendanceController extends Controller
{
    /**
     * List Monthly Presences
     *
     * Retrieves the attendance records for a specific class within a specific month and year.
     *
     * @authenticated
     * @urlParam classId int required The ID of the class (ClassID). Example: 1
     * @queryParam month int required The month (1-12). Example: 4
     * @queryParam year int required The year. Example: 2026
     * 
     * @response 200 {
     *   "data": [
     *     {
     *       "id": 100,
     *       "date": "2026-04-06",
     *       "child_id": 45,
     *       "status": {
     *         "name": "present"
     *       }
     *     }
     *   ]
     * }
     */
    public function index(Request $request, $classId)
    {
        $month = $request->query('month', date('n'));
        $year = $request->query('year', date('Y'));

        $presences = DB::table('Presence')
            ->join('Presencestatus', 'Presence.PresencestatusID', '=', 'Presencestatus.PresencestatusID')
            ->join('ChildClass', 'Presence.ChildID', '=', 'ChildClass.ChildID')
            ->where('ChildClass.ClassID', $classId)
            ->whereMonth('Presence.Date', $month)
            ->whereYear('Presence.Date', $year)
            ->select('Presence.PresenceID as id', 'Presence.Date as date', 'Presence.ChildID as child_id', 'Presencestatus.Name as status_name')
            ->get();

        $data = $presences->map(function ($p) {
            return [
                'id' => $p->id,
                'date' => $p->date,
                'child_id' => $p->child_id,
                'status' => [
                    'name' => strtolower($p->status_name)
                ]
            ];
        });

        return response()->json([
            'data' => $data
        ]);
    }

    /**
     * Record Presence
     *
     * Creates a new presence record for a child on a specific date.
     *
     * @authenticated
     * @urlParam classId int required The ID of the class (ClassID). Example: 1
     * @bodyParam child_id int required The ID of the child (ChildID). Example: 45
     * @bodyParam date string required The date of presence (YYYY-MM-DD). Example: "2026-04-06"
     * @bodyParam status string required The presence status ("present" or "absent"). Example: "present"
     * 
     * @response 201 {
     *   "data": {
     *     "id": 101,
     *     "child_id": 45,
     *     "date": "2026-04-06",
     *     "status": "present"
     *   }
     * }
     */
    public function store(Request $request, $classId)
    {
        $validated = $request->validate([
            'child_id' => 'required|integer',
            'date' => 'required|date',
            'status' => 'required|string'
        ]);

        $statusName = strtolower($validated['status']);
        $statusRecord = DB::table('Presencestatus')->where('Name', $statusName)->first();
        $statusId = $statusRecord ? $statusRecord->PresencestatusID : 1;

        $presenceId = DB::table('Presence')->insertGetId([
            'ChildID' => $validated['child_id'],
            'Date' => $validated['date'],
            'PresencestatusID' => $statusId
        ]);

        return response()->json([
            'data' => [
                'id' => $presenceId,
                'child_id' => $validated['child_id'],
                'date' => $validated['date'],
                'status' => $statusName
            ]
        ], 201);
    }

    /**
     * Update Presence
     *
     * Updates an existing presence record.
     *
     * @authenticated
     * @urlParam classId int required The ID of the class (ClassID). Example: 1
     * @urlParam presenceId int required The ID of the presence (PresenceID). Example: 100
     * @bodyParam date string required The date of presence (YYYY-MM-DD). Example: "2026-04-06"
     * @bodyParam status string required The presence status ("present" or "absent"). Example: "absent"
     * 
     * @response 200 {
     *   "data": {
     *     "id": 100,
     *     "date": "2026-04-06",
     *     "status": "absent"
     *   }
     * }
     */
    public function update(Request $request, $classId, $presenceId)
    {
        $validated = $request->validate([
            'date' => 'required|date',
            'status' => 'required|string'
        ]);

        $statusName = strtolower($validated['status']);
        $statusRecord = DB::table('Presencestatus')->where('Name', $statusName)->first();
        $statusId = $statusRecord ? $statusRecord->PresencestatusID : 1;

        DB::table('Presence')
            ->where('PresenceID', $presenceId)
            ->update([
                'Date' => $validated['date'],
                'PresencestatusID' => $statusId
            ]);

        return response()->json([
            'data' => [
                'id' => (int) $presenceId,
                'date' => $validated['date'],
                'status' => $statusName
            ]
        ]);
    }
}
