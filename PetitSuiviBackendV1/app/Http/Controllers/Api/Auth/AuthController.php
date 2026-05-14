<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Mail\PasswordResetMail;
use App\Models\Account;
use App\Support\AccountEmailUniqueness;
use Illuminate\Database\QueryException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    /**
     * Verify password against multiple hash formats.
     * Supports legacy plain text, MD5, and modern Bcrypt/Argon2.
     */
    private function verifyPassword(string $inputPassword, ?string $storedPassword): bool
    {
        if ($storedPassword === null) {
            return false;
        }

        // Plain text (legacy)
        if ($storedPassword === $inputPassword) {
            return true;
        }

        // MD5 (legacy)
        if (md5($inputPassword) === $storedPassword) {
            return true;
        }

        // Bcrypt / Argon2 (modern)
        try {
            if (str_starts_with($storedPassword, '$2y$') || str_starts_with($storedPassword, '$argon')) {
                return Hash::check($inputPassword, $storedPassword);
            }
        } catch (\Throwable $e) {
            // Corrupted hash — treat as invalid
        }

        return false;
    }

    /**
     * Admin Login
     *
     * Authenticates an administrative user via email and password, returning
     * a secure Bearer token for API access.
     *
     * @group Authentication
     *
     * @bodyParam email string required The administrator's email. Example: admin@testing.com
     * @bodyParam password string required The administrator's password. Example: password
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Connexion réussie",
     *   "user": { "AccountID": 10000000, "Email": "admin@testing.com", "RoleID": 2 },
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

        if (!$account || !$this->verifyPassword($request->password, $account->Password)) {
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
     * Teacher Login
     *
     * Authenticates a teacher using email and password.
     *
     * @group Authentication
     *
     * @bodyParam email string required The teacher's email. Example: teacher@example.com
     * @bodyParam password string required The teacher's password. Example: secret
     *
     * @response 200 { "success": true, "message": "Connexion réussie", "user": {}, "token": "..." }
     * @response 401 { "success": false, "message": "Les identifiants ne correspondent à aucun compte dans notre système." }
     * @response 403 { "success": false, "message": "Votre compte est archivé. Veuillez contacter l'administration." }
     */
    public function teacherLogin(Request $request): JsonResponse
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required'
        ]);

        $account = Account::where('RoleID', 1)->where('Email', $request->email)->first();

        if (!$account || !$this->verifyPassword($request->password, $account->Password)) {
            return response()->json([
                'success' => false,
                'message' => 'Les identifiants ne correspondent à aucun compte dans notre système.'
            ], 401);
        }

        if ($account->Is_archived) {
            return response()->json([
                'success' => false,
                'message' => 'Votre compte est archivé. Veuillez contacter l\'administration.'
            ], 403);
        }

        $token = $account->createToken('mobile-teacher')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Connexion réussie',
            'user' => [
                'AccountID' => $account->AccountID,
                'email' => $account->Email,
                'cin' => $account->Cin,
                'firstName' => $account->Firstname,
                'lastName' => $account->Lastname,
                'phone' => $account->Phone,
                'address' => $account->Adresse,
                'birthdate' => $account->Birthdate,
                'inscriptionDate' => $account->Inscriptiondate,
                'role' => ['name' => 'teacher'],
            ],
            'token' => $token
        ]);
    }

    /**
     * Check Registration Email Availability
     *
     * @group Authentication
     *
     * @bodyParam email string required The email to check. Example: test@example.com
     */
    public function checkRegistrationEmail(Request $request): JsonResponse
    {
        $request->validate([
            'email' => ['required', 'email', 'max:255'],
        ]);

        $exists = AccountEmailUniqueness::exists($request->email);

        return response()->json([
            'available' => !$exists,
            'message' => $exists ? AccountEmailUniqueness::DUPLICATE_EMAIL_MESSAGE : null,
        ]);
    }

    /**
     * Parent Login
     *
     * Authenticates a parent using email and password.
     *
     * @group Authentication
     *
     * @bodyParam email string required The parent's email. Example: parent@example.com
     * @bodyParam password string required The parent's password. Example: secret
     *
     * @response 200 { "success": true, "message": "Connexion réussie", "user": {}, "token": "..." }
     * @response 403 { "success": false, "message": "Votre compte nécessite l'approbation de l'administration." }
     * @response 401 { "success": false, "message": "Les identifiants ne correspondent à aucun compte." }
     */
    public function parentLogin(Request $request): JsonResponse
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required'
        ]);

        $account = Account::where('RoleID', 3)->where('Email', $request->email)->first();

        if (!$account || !$this->verifyPassword($request->password, $account->Password)) {
            return response()->json([
                'success' => false,
                'message' => 'Les identifiants ne correspondent à aucun compte dans notre système.'
            ], 401);
        }

        if ($account->Approval_status !== 'approved') {
            return response()->json([
                'success' => false,
                'message' => 'Votre compte nécessite l\'approbation de l\'administration.',
                'requires_admin_approval' => true
            ], 403);
        }

        if ($account->Is_archived) {
            return response()->json([
                'success' => false,
                'message' => 'Votre compte est archivé. Veuillez contacter l\'administration.'
            ], 403);
        }

        $token = $account->createToken('mobile-parent')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Connexion réussie',
            'user' => [
                'AccountID' => $account->AccountID,
                'email' => $account->Email,
                'cin' => $account->Cin,
                'firstName' => $account->Firstname,
                'lastName' => $account->Lastname,
                'phone' => $account->Phone,
                'address' => $account->Adresse,
                'birthdate' => $account->Birthdate,
                'inscriptionDate' => $account->Inscriptiondate,
                'role' => ['name' => 'parent'],
            ],
            'token' => $token
        ]);
    }

    /**
     * Forgot Password
     *
     * Generates a new temporary password for a parent or teacher account and
     * sends it to the account email address.
     *
     * @group Authentication
     *
     * @bodyParam email string required The account email. Example: parent@example.com
     * @bodyParam role string required The account role. Must be `teacher` or `parent`. Example: parent
     *
     * @response 200 { "success": true, "message": "Un nouveau mot de passe a ete envoye par email." }
     * @response 404 { "success": false, "message": "Aucun utilisateur trouve avec cet email." }
     */
    public function forgotPassword(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => 'required|email',
            'role' => 'required|in:teacher,parent',
        ]);

        $roleId = $validated['role'] === 'teacher' ? 1 : 3;

        $account = Account::where('RoleID', $roleId)
            ->where('Email', trim($validated['email']))
            ->first();

        if (!$account) {
            return response()->json([
                'success' => false,
                'message' => 'Aucun utilisateur trouve avec cet email.',
            ], 404);
        }

        $newPassword = $this->generateTemporaryPassword();

        DB::beginTransaction();

        try {
            DB::table('Account')
                ->where('AccountID', $account->AccountID)
                ->update([
                    'Password' => Hash::make($newPassword),
                ]);

            $freshAccount = Account::where('AccountID', $account->AccountID)->firstOrFail();
            Mail::to($freshAccount->Email)->send(new PasswordResetMail($freshAccount, $newPassword));

            DB::commit();
        } catch (\Throwable $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Impossible d\'envoyer le nouveau mot de passe pour le moment.',
            ], 500);
        }

        return response()->json([
            'success' => true,
            'message' => 'Un nouveau mot de passe a ete envoye par email.',
        ]);
    }

    private function generateTemporaryPassword(): string
    {
        return 'PS-' . Str::upper(Str::random(8)) . random_int(10, 99);
    }

    /**
     * Parent Registration
     *
     * Registers a new parent account along with their children and initial inscriptions.
     *
     * @group Authentication
     *
     * @bodyParam cin int required The parent's CIN. Example: 12345678
     * @bodyParam firstName string required The parent's first name. Example: Sami
     * @bodyParam lastName string required The parent's last name. Example: Ben Ali
     * @bodyParam email string required The parent's email. Example: parent@example.com
     * @bodyParam password string required The password. Example: secret
     * @bodyParam children object[] required The list of children to add.
     *
     * @response 200 { "success": true, "message": "Inscription réussie." }
     */
    public function register(Request $request): JsonResponse
    {
        $request->validate([
            'cin' => 'required',
            'firstName' => 'required',
            'lastName' => 'required',
            'email' => ['required', 'email', 'max:255', AccountEmailUniqueness::validationRule()],
            'password' => 'required',
        ]);

        try {
            DB::beginTransaction();

            $personId = DB::table('Person')->insertGetId([]);

            DB::table('Parent')->insert([
                'ParentID' => $personId
            ]);

            $accountId = DB::table('Account')->insertGetId([
                'PersonID' => $personId,
                'RoleID' => 3,
                'Cin' => $request->cin,
                'Firstname' => $request->firstName,
                'Lastname' => $request->lastName,
                'Birthdate' => $request->birthdate,
                'Email' => AccountEmailUniqueness::trim($request->email),
                'Phone' => $request->phone,
                'Adresse' => $request->adresse,
                'Password' => Hash::make($request->password),
                'Inscriptiondate' => now()->toDateString(),
                'Approval_status' => 'pending',
                'Is_archived' => 0,
            ]);

            $children = $request->input('children', []);
            foreach ($children as $childData) {
                $childId = DB::table('Child')->insertGetId([
                    'Firstname' => $childData['firstName'] ?? '',
                    'Lastname'  => $childData['lastName'] ?? '',
                    'Birthdate' => $childData['birthdate'] ?? null,
                    'ParentID'  => $personId,
                ]);

                $inscriptions = $childData['inscriptions'] ?? [];
                foreach ($inscriptions as $inscData) {
                    $typeStr = $inscData['type'] ?? '';
                    $typeID = (str_contains(strtolower($typeStr), 'maternelle') || str_contains(strtolower($typeStr), 'kindergarten')) ? 1 : 2;

                    $mealStr = $inscData['meal_plan'] ?? '';
                    $mealID = 4;
                    if (str_contains(strtolower($mealStr), 'et le goûter') || str_contains(strtolower($mealStr), 'et le gouter')) $mealID = 1;
                    elseif (str_contains(strtolower($mealStr), 'seulement le dejeuner') || str_contains(strtolower($mealStr), 'seulement le déjeuner')) $mealID = 2;
                    elseif (str_contains(strtolower($mealStr), 'seulement le gouter') || str_contains(strtolower($mealStr), 'seulement le goûter')) $mealID = 3;

                    $payID = ($inscData['payment_method'] ?? '') === 'oneShot' ? 2 : 1;
                    $statusStr = $inscData['status'] ?? 'pending';
                    $statusID = $statusStr === 'approved' ? 1 : ($statusStr === 'rejected' ? 2 : 3);

                    $fraisSnapshot = (float) DB::table('Parameter')->where('Name', 'frais_inscription')->value('Value') ?: 0;
                    $baseFee = (float) DB::table('Parameter')->where('Name', 'Prix de base')->value('Value') ?: 1200;
                    $mealFee = (float) DB::table('Parameter')->where('Name', $mealStr)->value('Value') ?: 0;
                    $secureTotalAmount = $baseFee + $mealFee;

                    $inscriptionId = DB::table('Inscription')->insertGetId([
                        'Date' => $inscData['insc_date'] ?? now()->toDateString(),
                        'Totalamount' => $secureTotalAmount,
                        'Isarchived' => 0,
                        'Basefee' => $baseFee,
                        'Mealplanfee' => $mealFee,
                        'Fraisinscriptionsnapshot' => $fraisSnapshot,
                        'Inscriptionfeespaymentamount' => null,
                        'MealplanID' => $mealID,
                        'PaymentmethodID' => $payID,
                        'InscriptiontypeID' => $typeID,
                        'TypeID' => $typeID,
                        'InscriptionstatusID' => $statusID,
                    ]);

                    DB::table('Payment')->insert([
                        'ChildID' => $childId,
                        'InscriptionID' => $inscriptionId,
                        'Amount' => $secureTotalAmount,
                        'Date' => now()->toDateString(),
                    ]);

                    if (isset($childData['medicalRecordForm'])) {
                        DB::table('Medicalform')->insert([
                            'InscriptionID' => $inscriptionId,
                            'Formdata' => json_encode($childData['medicalRecordForm']),
                        ]);
                    }
                }
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Inscription réussie.'
            ]);
        } catch (QueryException $e) {
            DB::rollBack();

            if (AccountEmailUniqueness::isDuplicateTriggerException($e)) {
                return response()->json([
                    'message' => 'The given data was invalid.',
                    'errors' => [
                        'email' => [AccountEmailUniqueness::DUPLICATE_EMAIL_MESSAGE],
                    ],
                ], 422);
            }

            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de l\'inscription: ' . $e->getMessage()
            ], 500);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de l\'inscription: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * User Logout
     *
     * Revokes the current access token.
     *
     * @group Authentication
     * @authenticated
     *
     * @response 200 { "success": true, "message": "Logged out successfully.", "data": null }
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
     * @group Authentication
     * @authenticated
     *
     * @response 200 { "success": true, "message": "Authenticated user profile.", "data": null }
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
