<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Mail\TeacherCredentialsMail;
use App\Models\Account;
use App\Models\Person;
use App\Models\Teacher;
use App\Support\AccountEmailUniqueness;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use Exception;

/**
 * @group Admin - Teachers
 * 
 * APIs for managing teachers.
 */
class TeacherController extends Controller
{
    /**
     * Get all teachers
     * 
     * Retrieves a list of all teachers in the system for administrative management.
     * The response utilizes the Account view merged with Teacher identifiers.
     * 
     * @authenticated
     * 
     * @response 200 {
     *   "data": [
     *     {
     *       "cin": 12345678,
     *       "firstName": "John",
     *       "lastName": "Doe",
     *       "birthdate": "1990-01-01",
     *       "phone": "555-1234",
     *       "email": "john.doe@example.com",
     *       "adresse": "123 Main St",
     *       "is_archived": false
     *     }
     *   ]
     * }
     */
    public function index(Request $request): JsonResponse
    {
        $teachers = Account::where('RoleID', 1)
            ->join('Teacher', 'Account.PersonID', '=', 'Teacher.TeacherID')
            ->select(
                'Account.Cin as cin',
                'Account.Firstname as firstName',
                'Account.Lastname as lastName',
                'Account.Birthdate as birthdate',
                'Account.Phone as phone',
                'Account.Email as email',
                'Account.Adresse as adresse',
                'Account.Is_archived as is_archived'
            )
            ->get()
            ->map(function ($teacher) {
                $teacher->is_archived = (bool) $teacher->is_archived;
                return $teacher;
            });

        return response()->json([
            'data' => $teachers
        ]);
    }

    /**
     * Create a new teacher
     * 
     * Registers a new teacher account in the system. The transaction inserts a new base Person,
     * links it functionally to the Teacher table, and builds the specific Teacher Account.
     * 
     * @authenticated
     * 
     * @bodyParam cin integer required The Account Cin of the teacher. Example: 12345678
     * @bodyParam firstName string required First name. Example: John
     * @bodyParam lastName string required Last name. Example: Doe
     * @bodyParam email string required Email address. Example: john.doe@example.com
     * @bodyParam phone string optional Phone number. Example: 555-1234
     * @bodyParam birthdate string optional Birth date (YYYY-MM-DD). Example: 1990-01-01
     * @bodyParam adresse string optional Address. Example: 123 Main St
     * @bodyParam password string required Password for the Account. Example: secret123
     * @bodyParam password_confirmation string required Password confirmation. Example: secret123
     * @bodyParam send_credentials boolean optional Whether to send credentials by email. Example: true
     * 
     * @response 201 {
     *   "message": "Enseignant ajouté avec succès"
     * }
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'cin' => 'required|integer|unique:Account,Cin',
            'firstName' => 'required|string|max:255',
            'lastName' => 'required|string|max:255',
            'email' => ['required', 'email', 'max:255', AccountEmailUniqueness::validationRule()],
            'adresse' => 'required|string|max:255',
            'password' => 'required|string|min:6|confirmed',
        ]);

        try {
            DB::beginTransaction();

            $personId = DB::table('Person')->insertGetId([]);

            DB::table('Teacher')->insert([
                'TeacherID' => $personId
            ]);

            Account::create([
                'Cin' => $request->cin,
                'Firstname' => $request->firstName,
                'Lastname' => $request->lastName,
                'Email' => AccountEmailUniqueness::trim($request->email),
                'Phone' => $request->phone,
                'Birthdate' => $request->birthdate,
                'Adresse' => $request->adresse,
                'Password' => Hash::make($request->password),
                'Is_archived' => false,
                'Approval_status' => 'approved',
                'Inscriptiondate' => now()->toDateString(),
                'RoleID' => 1, // 1 = Teacher
                'PersonID' => $personId
            ]);

            DB::commit();

            if ($request->boolean('send_credentials') && !empty($request->email)) {
                try {
                    Mail::to($request->email)->send(new TeacherCredentialsMail(
                        Account::where('Cin', $request->cin)->where('RoleID', 1)->firstOrFail(),
                        $request->password
                    ));
                } catch (Exception $mailException) {
                    Log::warning('Teacher credentials email failed on create: ' . $mailException->getMessage(), [
                        'teacher_cin' => $request->cin,
                    ]);
                }
            }

            return response()->json(['message' => 'Enseignant ajouté avec succès'], 201);
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

            return response()->json(['message' => 'Erreur lors de la création', 'error' => $e->getMessage()], 500);
        } catch (Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Erreur lors de la création', 'error' => $e->getMessage()], 500);
        }
    }

    /**
     * Update an existing teacher
     * 
     * Updates an existing teacher's account details identified by their CIN.
     * 
     * @authenticated
     * 
     * @urlParam cin integer required The Cin of the Account to update. Example: 12345678
     * 
     * @bodyParam firstName string required First name. Example: John
     * @bodyParam lastName string required Last name. Example: Doe
     * @bodyParam email string required Email address. Example: john.doe@example.com
     * @bodyParam phone string optional Phone number. Example: 555-1234
     * @bodyParam birthdate string optional Birth date (YYYY-MM-DD). Example: 1990-01-01
     * @bodyParam adresse string optional Address. Example: 123 Main St
     * @bodyParam password string optional New password. Example: secret123
     * @bodyParam password_confirmation string optional Password confirmation. Example: secret123
     * @bodyParam send_credentials boolean optional Whether to send credentials by email. Example: true
     * 
     * @response 200 {
     *   "message": "Enseignant mis à jour avec succès"
     * }
     */
    public function update(Request $request, int $cin): JsonResponse
    {
        $account = Account::where('Cin', $cin)->where('RoleID', 1)->firstOrFail();

        $request->validate([
            'firstName' => 'required|string|max:255',
            'lastName' => 'required|string|max:255',
            'email' => ['required', 'email', 'max:255', AccountEmailUniqueness::validationRule($account->AccountID)],
            'password' => 'nullable|string|min:6|confirmed',
        ]);

        $updateData = [
            'Firstname' => $request->firstName,
            'Lastname' => $request->lastName,
            'Email' => AccountEmailUniqueness::trim($request->email),
            'Phone' => $request->phone,
            'Birthdate' => $request->birthdate,
            'Adresse' => $request->adresse,
        ];

        if ($request->filled('password')) {
            $updateData['Password'] = Hash::make($request->password);
        }

        try {
            $account->update($updateData);
        } catch (QueryException $e) {
            if (AccountEmailUniqueness::isDuplicateTriggerException($e)) {
                return response()->json([
                    'message' => 'The given data was invalid.',
                    'errors' => [
                        'email' => [AccountEmailUniqueness::DUPLICATE_EMAIL_MESSAGE],
                    ],
                ], 422);
            }

            throw $e;
        }

        if ($request->boolean('send_credentials') && $request->filled('password') && !empty($account->Email)) {
            try {
                $freshAccount = Account::where('AccountID', $account->AccountID)->firstOrFail();
                Mail::to($freshAccount->Email)->send(new TeacherCredentialsMail($freshAccount, $request->password));
            } catch (Exception $mailException) {
                Log::warning('Teacher credentials email failed on update: ' . $mailException->getMessage(), [
                    'teacher_cin' => $cin,
                ]);
            }
        }

        return response()->json(['message' => 'Enseignant mis à jour avec succès'], 200);
    }

    /**
     * Toggle Archive Status
     * 
     * Updates the Is_archived status of a teacher's Account. An archived teacher cannot log in to the mobile app.
     * 
     * @authenticated
     * 
     * @urlParam cin integer required The Cin of the Account. Example: 12345678
     * 
     * @response 200 {
     *   "message": "Statut d'archivage mis à jour avec succès"
     * }
     */
    public function toggleArchive(int $cin): JsonResponse
    {
        $account = Account::where('Cin', $cin)->where('RoleID', 1)->firstOrFail();
        
        $account->update([
            'Is_archived' => !$account->Is_archived
        ]);

        return response()->json(['message' => 'Statut d\'archivage mis à jour avec succès'], 200);
    }

    /**
     * Delete a teacher
     * 
     * Permanently deletes a teacher and their associated account data.
     * 
     * @authenticated
     * 
     * @urlParam cin integer required The Cin of the Account to delete. Example: 12345678
     * 
     * @response 200 {
     *   "message": "Enseignant supprimé avec succès"
     * }
     */
    public function destroy(int $cin): JsonResponse
    {
        $account = Account::where('Cin', $cin)->where('RoleID', 1)->firstOrFail();
        $personId = $account->PersonID;

        try {
            DB::beginTransaction();

            $account->delete();
            DB::table('Teacher')->where('TeacherID', $personId)->delete();
            DB::table('Person')->where('PersonID', $personId)->delete();

            DB::commit();

            return response()->json(['message' => 'Enseignant supprimé avec succès'], 200);
        } catch (Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Erreur lors de la suppression', 'error' => $e->getMessage()], 500);
        }
    }
}
