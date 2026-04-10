<?php

namespace App\Http\Controllers\Api\Mobile\Parent;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

/**
 * @group Mobile - Parent Notifications
 *
 * APIs for retrieving and managing notifications for parents in the mobile app.
 */
class ParentNotificationsController extends Controller
{
    /**
     * Get Notifications
     *
     * Retrieves all notifications for the authenticated parent.
     *
     * @authenticated
     * @queryParam role string required The role context (must be 'parent'). Example: parent
     *
     * @response 200 {
     *   "success": true,
     *   "data": [
     *     {
     *       "id": 1,
     *       "recipient_id": "12345678",
     *       "recipient_role": "parent",
     *       "type": "payment",
     *       "title": "Paiement en attente",
     *       "message": "Vous avez des paiements ou frais en attente.",
     *       "data": {"unpaid_count": 1},
     *       "is_read": false,
     *       "created_at": "2026-04-06T12:00:00Z"
     *     }
     *   ]
     * }
     */
    public function index(Request $request): JsonResponse
    {
        $role = $request->query('role', 'parent');
        
        // Since parents use CIN for many references in this system, identify them via the auth user CIN
        // Wait, the Sanctum token is tied to Account model which has 'Cin' column.
        $user = $request->user();
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Unauthenticated.'], 401);
        }

        $cin = $user->Cin;

        $notifications = DB::table('Notification')
            ->where('Recipientcin', $cin)
            ->where('Recipientrole', $role)
            ->orderBy('NotificationID', 'desc')
            ->get();

        $mapped = $notifications->map(function ($notif) {
            $dataDecoded = null;
            if (!empty($notif->Data)) {
                $dataDecoded = json_decode($notif->Data, true);
            }

            return [
                'id'             => $notif->NotificationID,
                'recipient_id'   => $notif->Recipientcin,
                'recipient_role' => $notif->Recipientrole,
                'type'           => $notif->Type,
                'title'          => $notif->Title,
                'message'        => $notif->Message,
                'data'           => $dataDecoded,
                'is_read'        => $notif->Isread == 1,
                // Provide fallback since legacy DB lacks timestamp
                'created_at'     => Carbon::now()->toIso8601String(),
            ];
        });

        return response()->json([
            'success' => true,
            'data'    => $mapped
        ]);
    }

    /**
     * Mark Notification as Read
     *
     * @authenticated
     * @urlParam id int required The ID of the notification. Example: 1
     */
    public function markAsRead(Request $request, $id): JsonResponse
    {
        $user = $request->user();
        if (!$user) return response()->json(['success' => false], 401);

        DB::table('Notification')
            ->where('NotificationID', $id)
            ->where('Recipientcin', $user->Cin)
            ->update(['Isread' => 1]);

        return response()->json([
            'success' => true,
            'message' => 'Notification marked as read.'
        ]);
    }

    /**
     * Mark All Notifications as Read
     *
     * @authenticated
     */
    public function markAllAsRead(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user) return response()->json(['success' => false], 401);
        $role = $request->input('role', 'parent');

        DB::table('Notification')
            ->where('Recipientcin', $user->Cin)
            ->where('Recipientrole', $role)
            ->update(['Isread' => 1]);

        return response()->json([
            'success' => true,
            'message' => 'All notifications marked as read.'
        ]);
    }

    /**
     * Get Unread Count
     *
     * @authenticated
     */
    public function unreadCount(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user) return response()->json(['success' => false], 401);
        $role = $request->query('role', 'parent');

        $count = DB::table('Notification')
            ->where('Recipientcin', $user->Cin)
            ->where('Recipientrole', $role)
            ->where('Isread', 0)
            ->count();

        return response()->json([
            'success' => true,
            'data'    => ['count' => $count]
        ]);
    }
}
