<?php

namespace App\Http\Controllers\Api\Parent;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PickupAlertController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        // TODO: Delegate broadcasting an arrival alert to the correct teacher
        return response()->json([
            'success' => true,
            'message' => 'Arrival alert broadcasted successfully.',
            'data' => null
        ], 201);
    }

    public function show(int $id): JsonResponse
    {
        // TODO: Delegate checking the status of an active arrival alert
        return response()->json([
            'success' => true,
            'message' => 'Arrival alert status.',
            'data' => null
        ]);
    }
}
