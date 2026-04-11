<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use App\Models\Account;
use App\Support\AccountEmailUniqueness;
use Illuminate\Database\QueryException;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

class AuthController extends Controller
{
    /**
     * Teacher Login
     *
     * Authenticates a teacher using email and password, returning a secure
     * authentication token along with user details.
     *
     * @group Mobile - Auth
     * 
     * @bodyParam email string required The teacher's email. Example: teacher@example.com
     * @bodyParam password string required The teacher's password. Example: secret
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Connexion réussie",
     *   "user": {
     *     "AccountID": 102,
     *     "email": "teacher@example.com",
     *     "cin": 12345678,
     *     "firstName": "Ahmed",
     *     "lastName": "Ben Ali",
     *     "phone": "22334455",
     *     "address": "Tunis",
     *     "birthdate": "1990-01-01",
     *     "inscriptionDate": "2025-01-01",
     *     "role": {
     *       "name": "teacher"
     *     }
     *   },
     *   "token": "token_string_here"
     * }
     * @response 401 {
     *   "success": false,
     *   "message": "Les identifiants ne correspondent à aucun compte dans notre système."
     * }
     * @response 403 {
     *   "success": false,
     *   "message": "Votre compte est archivé. Veuillez contacter l'administration."
     * }
     */
    public function teacherLogin(Request $request): JsonResponse
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required'
        ]);

        $account = Account::where('RoleID', 1)->where('Email', $request->email)->first();
        $isValid = false;

        if ($account) {
            if ($account->Password === $request->password) {
                $isValid = true;
            } elseif (md5($request->password) === $account->Password) {
                $isValid = true;
            } else {
                try {
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

        if ($account->Is_archived) {
            return response()->json([
                'success' => false,
                'message' => 'Votre compte est archivé. Veuillez contacter l\'administration.'
            ], 403);
        }

        // Creating the sanctum token
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
     * Authenticates a parent using email and password, returning a secure
     * authentication token along with user details.
     *
     * @group Mobile - Auth
     * 
     * @bodyParam email string required The parent's email. Example: parent@example.com
     * @bodyParam password string required The parent's password. Example: secret
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Connexion réussie",
     *   "user": {
     *     "AccountID": 205,
     *     "email": "parent@example.com",
     *     "cin": 87654321,
     *     "firstName": "Sami",
     *     "lastName": "Ben Ali",
     *     "phone": "99887766",
     *     "address": "Tunis",
     *     "birthdate": "1990-01-01",
     *     "inscriptionDate": "2025-01-01",
     *     "role": {
     *       "name": "parent"
     *     }
     *   },
     *   "token": "token_string_here"
     * }
     * @response 403 {
     *   "success": false,
     *   "message": "Votre compte nécessite l'approbation de l'administration.",
     *   "requires_admin_approval": true
     * }
     * @response 401 {
     *   "success": false,
     *   "message": "Les identifiants ne correspondent à aucun compte."
     * }
     */
    public function parentLogin(Request $request): JsonResponse
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required'
        ]);

        $account = Account::where('RoleID', 3)->where('Email', $request->email)->first();
        $isValid = false;

        if ($account) {
            // Check legacy plain text or MD5, fallback to Laravel Hash (Bcrypt/Argon2)
            if ($account->Password === $request->password) {
                $isValid = true;
            } elseif (md5($request->password) === $account->Password) {
                $isValid = true;
            } else {
                try {
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

        // Creating the sanctum token
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
     * Parent Registration
     *
     * Registers a new parent account along with their children and initial inscriptions.
     *
     * @group Mobile - Auth
     * 
     * @bodyParam cin int required The parent's CIN. Example: 12345678
     * @bodyParam firstName string required The parent's first name. Example: Sami
     * @bodyParam lastName string required The parent's last name. Example: Ben Ali
     * @bodyParam birthdate string nullable The parent's birthdate. Example: 1980-01-01
     * @bodyParam email string required The parent's email. Example: parent@example.com
     * @bodyParam phone string required The parent's phone number. Example: 99887766
     * @bodyParam adresse string required The parent's address. Example: Tunis
     * @bodyParam password string required The password. Example: secret
     * @bodyParam password_confirmation string required Password confirmation. Example: secret
     * @bodyParam role string required The role (must be "parent"). Example: parent
     * @bodyParam children object[] required The list of children to add.
     * @bodyParam children[].firstName string required Child's first name. Example: Youssef
     * @bodyParam children[].lastName string required Child's last name. Example: Ben Ali
     * @bodyParam children[].birthdate string nullable Child's birthdate. Example: 2020-05-15
     * @bodyParam children[].medicalRecordForm object nullable The extensive medical record data.
     * @bodyParam children[].inscriptions object[] required The list of inscriptions for the child.
     * @bodyParam children[].inscriptions[].insc_date string required Inscription date in ISO8601. Example: 2025-01-01
     * @bodyParam children[].inscriptions[].status string required Status, normally "pending". Example: pending
     * @bodyParam children[].inscriptions[].type string required Inscription type (e.g., Préscolaire). Example: Préscolaire (التحضيري)
     * @bodyParam children[].inscriptions[].payment_method string required Payment method. Example: monthlyPartial
     * @bodyParam children[].inscriptions[].meal_plan string nullable Chosen meal plan.
     * @bodyParam children[].inscriptions[].total_amount float required Calculated total fee amount. Example: 1200.0
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Inscription réussie."
     * }
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
}
