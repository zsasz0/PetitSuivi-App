<?php

namespace App\Http\Controllers\Api\Parent;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        // TODO: Delegate fetching aggregated data (meals, recent photos, notifications)
        return response()->json([
            'success' => true,
            'message' => 'Parent dashboard data retrieved.',
            'data' => []
        ]);
    }
}
