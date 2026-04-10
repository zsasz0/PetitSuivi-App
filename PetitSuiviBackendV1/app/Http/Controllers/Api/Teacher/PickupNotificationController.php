<?php

namespace App\Http\Controllers\Api\Teacher;

use App\Http\Controllers\Controller;
use App\Models\Pickupnotifications;
use App\Models\PickupNotificationsTeacher;
use App\Models\Notification;
use App\Models\NotificationAccount;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * @group Teacher — Notifications
 *
 * Endpoints for retrieving pickup alerts and general system
 * notifications, plus mark-as-read batch operations.
 */
class PickupNotificationController extends Controller
{
    /**
     * List pickup notifications.
     *
     * Returns pending parent-arrival pickup notifications assigned to
     * this teacher via the PickupNotificationsTeacher pivot.
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Pickup notifications retrieved.",
     *   "data": [
     *     {
     *       "id": 1,
     *       "duration_minutes": 15,
     *       "created_at": "2026-03-05T14:30:00",
     *       "status": "pending",
     *       "child": { "firstName": "Sami", "lastName": "Ben Ali" },
     *       "parent": { "firstName": "Ahmed", "lastName": "Ben Ali" }
     *     }
     *   ]
     * }
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        $teacherId = $user->PersonID;

        // Note: Using GROUP BY or just taking first child per parent assuming 1 Pickup is per Parent
        $pickups = \Illuminate\Support\Facades\DB::table('PickupNotificationsTeacher')
            ->join('Pickupnotifications', 'PickupNotificationsTeacher.PickupnotificationsID', '=', 'Pickupnotifications.PickupnotificationsID')
            ->leftJoin('Pickupnotificationsstatus', 'Pickupnotifications.PickupnotificationsstatusID', '=', 'Pickupnotificationsstatus.PickupnotificationsstatusID')
            ->join('Account as ParentAccount', function($join) {
                $join->on('Pickupnotifications.ParentID', '=', 'ParentAccount.PersonID')
                     ->where('ParentAccount.RoleID', 3);
            })
            ->leftJoin('Child', 'Child.ParentID', '=', 'Pickupnotifications.ParentID')
            ->where('PickupNotificationsTeacher.TeacherID', $teacherId)
            ->where(function ($query) {
                $query->whereNull('Pickupnotificationsstatus.Name')
                    ->orWhere('Pickupnotificationsstatus.Name', '!=', 'read');
            })
            ->select(
                'Pickupnotifications.PickupnotificationsID as id',
                'Pickupnotifications.Duration as duration_minutes',
                'Pickupnotificationsstatus.Name as status_name',
                'ParentAccount.Firstname as parent_first',
                'ParentAccount.Lastname as parent_last',
                'Child.Firstname as child_first',
                'Child.Lastname as child_last'
            )
            ->get();

        // deduplicate children for same pickup
        $formatted = [];
        $seen = [];
        foreach ($pickups as $p) {
            if (!isset($seen[$p->id])) {
                $formatted[] = [
                    'id' => $p->id,
                    'duration_minutes' => $p->duration_minutes,
                    'created_at' => null,
                    'status' => strtolower($p->status_name ?? 'pending'),
                    'child' => [
                        'firstName' => $p->child_first,
                        'lastName' => $p->child_last
                    ],
                    'parent' => [
                        'firstName' => $p->parent_first,
                        'lastName' => $p->parent_last
                    ]
                ];
                $seen[$p->id] = true;
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Pickup notifications retrieved.',
            'data' => $formatted
        ]);
    }

    /**
     * Complete a pickup handover.
     *
     * Marks a pickup notification as completed, indicating the
     * child has been handed over to the parent.
     *
     * @urlParam id integer required The PickupnotificationsID. Example: 1
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Handover logged as completed."
     * }
     *
     * @response 404 {
     *   "success": false,
     *   "message": "Pickup notification not found."
     * }
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $status = \Illuminate\Support\Facades\DB::table('Pickupnotificationsstatus')
            ->where('Name', 'read')
            ->first();

        $exists = \Illuminate\Support\Facades\DB::table('Pickupnotifications')
            ->where('PickupnotificationsID', $id)
            ->exists();

        if (!$exists) {
            return response()->json([
                'success' => false,
                'message' => 'Pickup notification not found.'
            ], 404);
        }

        if (!$status) {
            return response()->json([
                'success' => false,
                'message' => 'Le statut de notification "read" est introuvable.'
            ], 500);
        }

        \Illuminate\Support\Facades\DB::table('Pickupnotifications')
            ->where('PickupnotificationsID', $id)
            ->update([
                'PickupnotificationsstatusID' => $status->PickupnotificationsstatusID,
            ]);

        return response()->json([
            'success' => true,
            'message' => 'Handover logged as completed.',
            'data' => null
        ]);
    }

    /**
     * List system notifications for teacher.
     *
     * Returns general notifications (events, alerts, announcements)
     * addressed to the authenticated teacher account.
     *
     * @queryParam unread_only boolean Optional. If true, returns only unread notifications. Example: true
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Notifications retrieved.",
     *   "data": [
     *     {
     *       "id": 5,
     *       "type": "event",
     *       "title": "Journée portes ouvertes",
     *       "message": "Événement prévu le 20 mars.",
     *       "is_read": false,
     *       "created_at": "2026-03-01T08:00:00",
     *       "data": null
     *     }
     *   ]
     * }
     */
    public function notifications(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        $unreadOnly = filter_var($request->query('unread_only', false), FILTER_VALIDATE_BOOLEAN);

        $query = \Illuminate\Support\Facades\DB::table('NotificationAccount')
            ->join('Notification', 'NotificationAccount.NotificationID', '=', 'Notification.NotificationID')
            ->where('NotificationAccount.AccountID', $user->AccountID);

        if ($unreadOnly) {
            $query->where('Notification.Isread', 0);
        }

        $notifications = $query->select(
            'Notification.NotificationID as id',
            'Notification.Type as type',
            'Notification.Title as title',
            'Notification.Message as message',
            'Notification.Isread as is_read',
            'Notification.Data as data'
        )->get();

        $formatted = [];
        foreach ($notifications as $n) {
            $formatted[] = [
                'id' => (int) $n->id,
                'type' => $n->type,
                'title' => $n->title,
                'message' => $n->message,
                'is_read' => (bool) $n->is_read,
                'created_at' => now()->toIso8601String(),
                'data' => $n->data ? json_decode($n->data, true) : null
            ];
        }

        return response()->json([
            'success' => true,
            'message' => 'Notifications retrieved.',
            'data' => $formatted
        ]);
    }

    /**
     * Mark all notifications as read.
     *
     * Batch-updates all unread notifications for the teacher to read status.
     *
     * @response 200 {
     *   "success": true,
     *   "message": "All notifications marked as read."
     * }
     */
    public function markAllRead(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        $notifIds = \Illuminate\Support\Facades\DB::table('NotificationAccount')
            ->where('AccountID', $user->AccountID)
            ->pluck('NotificationID');

        if ($notifIds->isNotEmpty()) {
            \Illuminate\Support\Facades\DB::table('Notification')
                ->whereIn('NotificationID', $notifIds)
                ->update(['Isread' => 1]);
        }

        return response()->json([
            'success' => true,
            'message' => 'All notifications marked as read.'
        ]);
    }

    public function markAsRead(Request $request, int $id): JsonResponse
    {
        $user = $request->user();
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        \Illuminate\Support\Facades\DB::table('Notification')
            ->where('NotificationID', $id)
            ->update(['Isread' => 1]);

        return response()->json([
            'success' => true,
            'message' => 'Notification marked as read.'
        ]);
    }

    public function unreadCount(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        $count = \Illuminate\Support\Facades\DB::table('NotificationAccount')
            ->join('Notification', 'NotificationAccount.NotificationID', '=', 'Notification.NotificationID')
            ->where('NotificationAccount.AccountID', $user->AccountID)
            ->where('Notification.Isread', 0)
            ->count();

        return response()->json([
            'success' => true,
            'data' => ['count' => $count]
        ]);
    }
}
