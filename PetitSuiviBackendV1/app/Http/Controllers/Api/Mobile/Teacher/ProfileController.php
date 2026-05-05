<?php

namespace App\Http\Controllers\Api\Mobile\Teacher;

use App\Http\Controllers\Controller;
use App\Models\Account;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

/**
 * @group Teacher — Profile Management
 *
 * Endpoints for teachers to view and update their personal
 * information and manage their account password.
 */
class ProfileController extends Controller
{
    /**
     * Get teacher profile.
     *
     * Returns the authenticated teacher's personal information
     * including name, email, phone, and address.
     *
     * @urlParam cin string required The teacher's CIN. Example: 88552233
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Profile retrieved.",
     *   "data": {
     *     "cin": "88552233",
     *     "firstName": "Fatma",
     *     "lastName": "Mrad",
     *     "email": "fatma@example.com",
     *     "phone": "12345678",
     *     "adresse": "Tunis, Tunisia"
     *   }
     * }
     *
     * @response 404 {
     *   "success": false,
     *   "message": "Teacher not found."
     * }
     */
    public function show(string $cin): JsonResponse
    {
        $account = \Illuminate\Support\Facades\DB::table('Account')
            ->where('Cin', $cin)
            ->where('RoleID', 1)
            ->first();

        if (!$account) {
            return response()->json([
                'success' => false,
                'message' => 'Teacher not found.'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Profile retrieved.',
            'data' => [
                'cin' => (string) $account->Cin,
                'firstName' => $account->Firstname,
                'lastName' => $account->Lastname,
                'email' => $account->Email,
                'phone' => (string) $account->Phone,
                'adresse' => $account->Adresse
            ]
        ]);
    }

    /**
     * Update teacher profile.
     *
     * Updates personal information fields for the teacher account.
     * Only the provided fields are updated; omitted fields retain
     * their current values.
     *
     * @urlParam cin string required The teacher's CIN. Example: 88552233
     *
     * @bodyParam firstName string required First name. Example: Fatma
     * @bodyParam lastName string required Last name. Example: Mrad
     * @bodyParam email string required Email address. Example: fatma@example.com
     * @bodyParam phone string required Phone number (8 digits). Example: 12345678
     * @bodyParam adresse string optional Postal address. Example: Tunis, Tunisia
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Profile updated."
     * }
     *
     * @response 404 {
     *   "success": false,
     *   "message": "Teacher not found."
     * }
     *
     * @response 422 {
     *   "success": false,
     *   "message": "Validation failed.",
     *   "errors": { "email": ["The email has already been taken."] }
     * }
     */
    public function update(Request $request, string $cin): JsonResponse
    {
        $validated = $request->validate([
            'firstName' => 'required|string|max:50',
            'lastName' => 'required|string|max:50',
            'email' => 'required|email|max:50',
            'phone' => 'required|string|max:11',
            'adresse' => 'nullable|string|max:50'
        ]);

        $updated = \Illuminate\Support\Facades\DB::table('Account')
            ->where('Cin', $cin)
            ->where('RoleID', 1)
            ->update([
                'Firstname' => $validated['firstName'],
                'Lastname' => $validated['lastName'],
                'Email' => $validated['email'],
                'Phone' => $validated['phone'],
                'Adresse' => $validated['adresse'] ?? null
            ]);

        if (!$updated && \Illuminate\Support\Facades\DB::table('Account')->where('Cin', $cin)->where('RoleID', 1)->doesntExist()) {
            return response()->json([
                'success' => false,
                'message' => 'Teacher not found.'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Profile updated.'
        ]);
    }

    /**
     * Change teacher password.
     *
     * Updates the account password. The new password must meet
     * the following criteria: min 8 chars, 1 uppercase, 1 lowercase,
     * 1 digit, and 1 special character.
     *
     * @bodyParam new_password string required The new password (min 8 chars). Example: NewStr0ng!Pass
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Mot de passe modifié."
     * }
     *
     * @response 422 {
     *   "success": false,
     *   "message": "Validation failed.",
     *   "errors": { "new_password": ["The password must be at least 8 characters."] }
     * }
     */
    public function changePassword(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'new_password' => [
                'required',
                'string',
                'min:8',
                'regex:/[a-z]/',
                'regex:/[A-Z]/',
                'regex:/[0-9]/',
                'regex:/[@$!%*#?&.]/'
            ]
        ]);

        $user = $request->user();
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        \Illuminate\Support\Facades\DB::table('Account')
            ->where('AccountID', $user->AccountID)
            ->update([
                'Password' => \Illuminate\Support\Facades\Hash::make($validated['new_password'])
            ]);

        // Revoke all tokens so the user has to login again with the new password
        $user->tokens()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Mot de passe modifié.'
        ]);
    }
}
