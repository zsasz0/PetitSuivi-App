<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        // TODO: Delegate fetching history of broadcasted notifications
        return response()->json([
            'success' => true,
            'message' => 'Broadcast history retrieved.',
            'data' => []
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        // TODO: Delegate broadcasting a manual notification to user cohorts
        return response()->json([
            'success' => true,
            'message' => 'Notification broadcasted successfully.',
            'data' => null
        ], 201);
    }
}
