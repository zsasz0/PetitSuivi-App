<?php

namespace App\Http\Controllers\Api\Mobile\Parent;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use App\Models\Account;

/**
 * @group Mobile - Parent Security
 *
 * APIs for security options such as changing passwords.
 */
class ParentPasswordController extends Controller
{
    /**
     * Change Password
     *
     * Updates the password of the authenticated parent.
     *
     * @authenticated
     * @bodyParam new_password string required The new secure password. Example: "P@ssw0rd123!"
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Password changed successfully."
     * }
     */
    public function change(Request $request): JsonResponse
    {
        $request->validate([
            'new_password' => 'required|string|min:8'
        ]);

        $user = $request->user();
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Unauthenticated.'], 401);
        }

        // Laravel Hash
        $newHashed = Hash::make($request->new_password);

        DB::table('Account')
            ->where('AccountID', $user->AccountID)
            ->update([
                'Password' => $newHashed
            ]);

        return response()->json([
            'success' => true,
            'message' => 'Password changed successfully.'
        ]);
    }
}
