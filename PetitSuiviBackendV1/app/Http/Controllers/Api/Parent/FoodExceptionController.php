<?php

namespace App\Http\Controllers\Api\Parent;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FoodExceptionController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        // TODO: Delegate registering a temporary allergy or food exception
        return response()->json([
            'success' => true,
            'message' => 'Food exception registered.',
            'data' => null
        ], 201);
    }

    public function destroy(int $id): JsonResponse
    {
        // TODO: Delegate revoking a registered food exception
        return response()->json([
            'success' => true,
            'message' => 'Food exception revoked.',
            'data' => null
        ]);
    }
}
