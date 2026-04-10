<?php

namespace App\Http\Controllers\Api\Mobile\Parent;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/**
 * @group Mobile - Parent Profile
 *
 * APIs for viewing and updating the authenticated parent's personal information.
 */
class ParentProfileController extends Controller
{
    /**
     * View Parent Profile
     *
     * Retrieves the parent's personal information by CIN.
     *
     * @authenticated
     * @urlParam cin string required The parent's CIN. Example: 12345678
     *
     * @response 200 {
     *   "success": true,
     *   "data": {
     *     "cin": "12345678",
     *     "firstName": "Ahmed",
     *     "lastName": "Mejri",
     *     "email": "ahmed@example.com",
     *     "phone": "12345678",
     *     "adresse": "Tunis, Tunisia"
     *   }
     * }
     */
    public function show($cin): JsonResponse
    {
        $account = DB::table('Account')
            ->where('Cin', $cin)
            ->where('RoleID', 3) // Parent role
            ->first();

        if (!$account) {
            return response()->json([
                'success' => false,
                'message' => 'Parent not found.',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'cin'       => $account->Cin,
                'firstName' => $account->Firstname,
                'lastName'  => $account->Lastname,
                'email'     => $account->Email,
                'phone'     => $account->Phone,
                'adresse'   => $account->Adresse,
            ],
        ]);
    }

    /**
     * Update Parent Profile
     *
     * Updates the parent's personal information.
     *
     * @authenticated
     * @urlParam cin string required The parent's CIN. Example: 12345678
     * @bodyParam firstName string required First name. Example: "Ahmed"
     * @bodyParam lastName string required Last name. Example: "Mejri"
     * @bodyParam email string required Email address. Example: "ahmed@example.com"
     * @bodyParam phone string required Phone number. Example: "12345678"
     * @bodyParam adresse string required Address. Example: "Tunis, Tunisia"
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Profile updated successfully.",
     *   "data": {
     *     "firstName": "Ahmed",
     *     "lastName": "Mejri",
     *     "email": "ahmed@example.com",
     *     "phone": "12345678",
     *     "adresse": "Tunis, Tunisia"
     *   }
     * }
     */
    public function update(Request $request, $cin): JsonResponse
    {
        $validated = $request->validate([
            'firstName' => 'required|string|max:100',
            'lastName'  => 'required|string|max:100',
            'email'     => 'required|email|max:150',
            'phone'     => 'required|string|max:20',
            'adresse'   => 'required|string|max:255',
        ]);

        $account = DB::table('Account')
            ->where('Cin', $cin)
            ->where('RoleID', 3)
            ->first();

        if (!$account) {
            return response()->json([
                'success' => false,
                'message' => 'Parent not found.',
            ], 404);
        }

        DB::table('Account')
            ->where('AccountID', $account->AccountID)
            ->update([
                'Firstname' => $validated['firstName'],
                'Lastname'  => $validated['lastName'],
                'Email'     => $validated['email'],
                'Phone'     => $validated['phone'],
                'Adresse'   => $validated['adresse'],
            ]);

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully.',
            'data' => [
                'firstName' => $validated['firstName'],
                'lastName'  => $validated['lastName'],
                'email'     => $validated['email'],
                'phone'     => $validated['phone'],
                'adresse'   => $validated['adresse'],
            ],
        ]);
    }
}
