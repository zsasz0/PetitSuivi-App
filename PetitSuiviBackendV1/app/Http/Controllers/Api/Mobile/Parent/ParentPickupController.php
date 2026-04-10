<?php

namespace App\Http\Controllers\Api\Mobile\Parent;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/**
 * @group Mobile - Parent Pickup
 *
 * APIs for sending pickup arrival notifications to the child's assigned teachers.
 */
class ParentPickupController extends Controller
{
    /**
     * Send Pickup Notification
     *
     * Creates a pickup notification and links it to all teachers of the child's current class(es).
     *
     * @authenticated
     * @bodyParam child_id int required The ID of the child being picked up. Example: 45
     * @bodyParam duration_minutes int The estimated arrival time in minutes. Example: 15
     *
     * @response 201 {
     *   "success": true,
     *   "message": "Pickup notification sent to teachers."
     * }
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'child_id'         => 'required|integer',
            'duration_minutes' => 'nullable|integer|min:1|max:120',
        ]);

        $childId  = $validated['child_id'];
        $duration = $validated['duration_minutes'] ?? 15;

        // Verify child exists
        $child = DB::table('Child')->where('ChildID', $childId)->first();
        if (!$child) {
            return response()->json(['success' => false, 'message' => 'Child not found.'], 404);
        }

        // Get parent ID
        $parentId = $child->ParentID;

        // Find all teachers assigned to the child's current classes
        $teacherIds = DB::table('ChildClass')
            ->join('TeacherClass', 'ChildClass.ClassID', '=', 'TeacherClass.ClassID')
            ->where('ChildClass.ChildID', $childId)
            ->pluck('TeacherClass.TeacherID')
            ->unique();

        if ($teacherIds->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => 'Aucun enseignant n\'est actuellement assigne a cet enfant.',
            ], 422);
        }

        // Resolve unread status from the lookup table.
        $pendingStatus = DB::table('Pickupnotificationsstatus')
            ->where('Name', 'unread')
            ->first();

        if (!$pendingStatus) {
            return response()->json([
                'success' => false,
                'message' => 'Le statut de notification "unread" est introuvable.',
            ], 500);
        }

        $pickupPayload = [
            'Duration' => $duration,
            'ParentID' => $parentId,
            'PickupnotificationsstatusID' => $pendingStatus->PickupnotificationsstatusID,
        ];

        // Create pickup notification
        $pickupId = DB::table('Pickupnotifications')->insertGetId($pickupPayload);

        // Link teachers to the notification via pivot
        foreach ($teacherIds as $teacherId) {
            DB::table('PickupNotificationsTeacher')->insert([
                'TeacherID'              => $teacherId,
                'PickupnotificationsID'  => $pickupId,
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Pickup notification sent to teachers.',
            'data'    => ['id' => $pickupId],
        ], 201);
    }
}
