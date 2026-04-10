<?php

namespace App\Http\Controllers\Api\Parent;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ChildProfileController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        // TODO: Delegate fetching the parent's linked children
        return response()->json([
            'success' => true,
            'message' => 'Linked children retrieved.',
            'data' => []
        ]);
    }

    public function show(int $id): JsonResponse
    {
        // TODO: Delegate fetching a specific child's details (restricted to the parent)
        return response()->json([
            'success' => true,
            'message' => 'Child details retrieved.',
            'data' => null
        ]);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        // TODO: Delegate updating basic info or medical/dietary forms
        return response()->json([
            'success' => true,
            'message' => 'Child profile updated.',
            'data' => null
        ]);
    }
}
