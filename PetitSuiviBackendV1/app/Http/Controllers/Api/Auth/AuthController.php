<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Models\Account;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    /**
     * Admin Login
     *
     * Authenticates an administrative user via email and password, returning 
     * a secure Bearer token for API access. Supports gracefully falling back
     * between modern Bcrypt, legacy plain text, and MD5 hashes.
     *
     * @group Authentication
     * 
     * @bodyParam email string required The administrator's email. Example: admin@testing.com
     * @bodyParam password string required The administrator's password. Example: password
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Connexion réussie",
     *   "user": {
     *     "AccountID": 10000000,
     *     "Email": "admin@testing.com",
     *     "Password": "$2y$12$...",
     *     "PersonID": 12,
     *     "RoleID": 1
     *   },
     *   "token": "1|abcdef1234567890..."
     * }
     * @response 401 {
     *   "success": false,
     *   "message": "Les identifiants ne correspondent à aucun compte dans notre système."
     * }
     */
    public function login(Request $request): JsonResponse
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required'
        ]);

        $account = Account::where('Email', $request->email)->first();
        $isValid = false;

        if ($account) {
            // Support legacy plain text or MD5 hashed passwords
            if ($account->Password === $request->password) {
                $isValid = true;
            } elseif (md5($request->password) === $account->Password) {
                $isValid = true;
            } else {
                // Safely attempt Laravel Hash (Bcrypt/Argon2)
                try {
                    // Check if it's potentially a valid Laravel hash format before invoking
                    if (str_starts_with($account->Password, '$2y$') || str_starts_with($account->Password, '$argon')) {
                        if (Hash::check($request->password, $account->Password)) {
                            $isValid = true;
                        }
                    }
                } catch (\Throwable $e) {
                    $isValid = false;
                }
            }
        }

        if (!$isValid) {
            return response()->json([
                'success' => false,
                'message' => 'Les identifiants ne correspondent à aucun compte dans notre système.'
            ], 401);
        }

        $token = $account->createToken('auth-token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Connexion réussie',
            'user' => $account,
            'token' => $token
        ]);
    }

    /**
     * User Logout
     *
     * Revokes the current access token and logs the user out securely 
     * by destroying their active Sanctum token in the database.
     *
     * @group Authentication
     * @authenticated
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Logged out successfully.",
     *   "data": null
     * }
     */
    public function logout(Request $request): JsonResponse
    {
        if ($user = $request->user()) {
            $user->currentAccessToken()->delete();
        } elseif ($user = auth('sanctum')->user()) {
            $user->currentAccessToken()->delete();
        }

        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully.',
            'data' => null
        ]);
    }

    /**
     * Get Authenticated User Profile
     *
     * Retrieves the profile information of the currently authenticated administrator.
     *
     * @group Authentication
     * @authenticated
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Authenticated user profile.",
     *   "data": null
     * }
     */
    public function me(Request $request): JsonResponse
    {
        // TODO: Delegate fetching authenticated user profile
        return response()->json([
            'success' => true,
            'message' => 'Authenticated user profile.',
            'data' => null
        ]);
    }
}
