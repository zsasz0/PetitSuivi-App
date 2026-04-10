<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AccountController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        // TODO: Delegate fetching admin accounts
        return response()->json([
            'success' => true,
            'message' => 'Admin accounts retrieved.',
            'data' => []
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        // TODO: Delegate creating a new admin account
        return response()->json([
            'success' => true,
            'message' => 'Admin account created.',
            'data' => null
        ], 201);
    }

    public function show(int $id): JsonResponse
    {
        // TODO: Delegate fetching a specific admin account
        return response()->json([
            'success' => true,
            'message' => 'Account details.',
            'data' => null
        ]);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        // TODO: Delegate updating an admin account
        return response()->json([
            'success' => true,
            'message' => 'Account updated.',
            'data' => null
        ]);
    }

    /**
     * List Parents
     *
     * Retrieves all parent accounts to calculate total registered parents for the dashboard.
     *
     * @group Admin - Accounts
     * @authenticated
     *
     * @response 200 {
     *   "data": [
     *     {
     *       "AccountID": 105,
     *       "firstName": "Ali",
     *       "lastName": "Ben Salah"
     *     }
     *   ]
     * }
     */
    public function getParents(Request $request): JsonResponse
    {
        $parents = \App\Models\Account::where('RoleID', 3)->get();
        return response()->json([
            'data' => $parents
        ]);
    }
}
