<?php

namespace App\Http\Controllers\Api\Parent;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class EventNotificationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        // TODO: Delegate fetching upcoming events and notifications targeted to the parent
        return response()->json([
            'success' => true,
            'message' => 'Events and notifications retrieved.',
            'data' => []
        ]);
    }

    public function markAsRead(Request $request, int $id): JsonResponse
    {
        // TODO: Delegate marking a notification as read
        return response()->json([
            'success' => true,
            'message' => 'Notification marked as read.',
            'data' => null
        ]);
    }
}
