<?php

namespace App\Http\Controllers\Api\Mobile\Parent;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/**
 * @group Mobile - Parent Presence
 *
 * APIs for retrieving a child's attendance (presence) data for the parent view.
 */
class ParentPresenceController extends Controller
{
    /**
     * Get Child Monthly Presences
     *
     * Retrieves attendance records for a specific child within a given month and year.
     *
     * @authenticated
     * @urlParam childId int required The ID of the child (ChildID). Example: 45
     * @queryParam month int required The month (1-12). Example: 4
     * @queryParam year int required The year. Example: 2026
     *
     * @response 200 {
     *   "data": [
     *     {
     *       "id": 100,
     *       "date": "2026-04-06",
     *       "child_id": 45,
     *       "status": { "name": "present" }
     *     }
     *   ]
     * }
     */
    public function index(Request $request, $childId): JsonResponse
    {
        $month = $request->query('month', date('n'));
        $year  = $request->query('year', date('Y'));

        $presences = DB::table('Presence')
            ->join('Presencestatus', 'Presence.PresencestatusID', '=', 'Presencestatus.PresencestatusID')
            ->where('Presence.ChildID', $childId)
            ->whereMonth('Presence.Date', $month)
            ->whereYear('Presence.Date', $year)
            ->select(
                'Presence.PresenceID as id',
                'Presence.Date as date',
                'Presence.ChildID as child_id',
                'Presencestatus.Name as status_name'
            )
            ->get();

        $data = $presences->map(fn($p) => [
            'id'       => $p->id,
            'date'     => $p->date,
            'child_id' => $p->child_id,
            'status'   => ['name' => strtolower($p->status_name)],
        ]);

        return response()->json(['data' => $data]);
    }
}
