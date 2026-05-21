<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Mail\ParentApprovedMail;
use App\Support\AccountEmailUniqueness;
use Illuminate\Http\Request;
use App\Models\Person;
use App\Models\Account;
use App\Models\Child;
use App\Models\Parent as ParentModel;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Schema;
use Illuminate\Database\QueryException;

/**
 * @group Admin - Parents
 * 
 * API endpoints for managing parent accounts and their associated children.
 */
class ParentController extends Controller
{
    /**
     * Get All Parents
     *
     * Retrieves a list of all parent accounts, along with their associated children.
     * Note: The underlying models (Account, Person, Parent) have no timestamps and 
     * use specific capitalization mapped to these response keys.
     *
     * @authenticated
     * 
     * @response 200 {
     *   "data": [
     *     {
     *       "cin": 12345678,
     *       "firstName": "John",
     *       "lastName": "Doe",
     *       "birthdate": "1980-05-15",
     *       "phone": "0600000000",
     *       "email": "john.doe@example.com",
     *       "adresse": "123 Main St",
     *       "is_archived": false,
     *       "approval_status": "approved",
     *       "children": [
     *         {
     *           "firstName": "Jane",
     *           "lastName": "Doe",
     *           "birthdate": "2015-02-10"
     *         }
     *       ]
     *     }
     *   ]
     * }
     */
    public function index()
    {
        $accounts = Account::where('RoleID', 3)->get();
        $formatted = [];

        foreach ($accounts as $account) {
            $childrenData = [];
            // Assuming PersonID on Account maps to ParentID on Child via Parent->PersonID
            if ($account->PersonID) {
                $children = Child::where('ParentID', $account->PersonID)->get();
                foreach ($children as $child) {
                    $childrenData[] = [
                        'id' => $child->ChildID,
                        'firstName' => $child->Firstname,
                        'lastName' => $child->Lastname,
                        'birthdate' => $child->Birthdate,
                    ];
                }
            }

            $formatted[] = [
                'cin' => (int) $account->Cin,
                'firstName' => $account->Firstname,
                'lastName' => $account->Lastname,
                'birthdate' => $account->Birthdate,
                'phone' => $account->Phone,
                'email' => $account->Email,
                'adresse' => $account->Adresse,
                'is_archived' => (bool) $account->Is_archived,
                'approval_status' => $account->Approval_status,
                'children' => $childrenData
            ];
        }

        return response()->json([
            'data' => $formatted
        ], 200);
    }

    /**
     * Create Parent
     *
     * Registers a new parent. This requires inserting into the Person supertype, 
     * then the Parent subtype, then the Account table, and finally the Child records.
     *
     * @authenticated
     * 
     * @bodyParam cin integer required The CIN of the parent. Example: 12345678
     * @bodyParam firstName string required First name. Example: John
     * @bodyParam lastName string required Last name. Example: Doe
     * @bodyParam birthdate date optional Date of birth. Example: 1980-05-15
     * @bodyParam phone string optional Phone number. Example: 0600000000
     * @bodyParam email string required Email address. Example: john.doe@example.com
     * @bodyParam adresse string optional Physical address. Example: 123 Main St
     * @bodyParam password string required Password. Example: secret123
     * @bodyParam password_confirmation string required Password confirmation. Example: secret123
     * @bodyParam children object[] optional Array of children to register.
     * @bodyParam children[].firstName string required Child's first name. Example: Jane
     * @bodyParam children[].lastName string required Child's last name. Example: Doe
     * @bodyParam children[].birthdate date optional Child's birth date. Example: 2015-02-10
     * 
     * @response 201 {
     *   "message": "Parent added successfully."
     * }
     */
    public function store(Request $request)
    {
        $request->validate([
            'cin' => 'required|numeric|unique:Account,Cin',
            'firstName' => 'required|string|max:255',
            'lastName' => 'required|string|max:255',
            'birthdate' => 'nullable|date',
            'phone' => 'nullable',
            'email' => ['required', 'email', 'max:255', AccountEmailUniqueness::validationRule()],
            'adresse' => 'nullable|string',
            'password' => 'required|string|min:6|confirmed',
            'children' => 'nullable|array',
            'children.*.firstName' => 'required|string|max:255',
            'children.*.lastName' => 'required|string|max:255',
            'children.*.birthdate' => 'nullable|date',
        ]);

        DB::beginTransaction();
        try {
            // 1. Insert Person (auto-increment PersonID)
            $person = new Person();
            $person->save();

            // 2. Insert into Parent subtype with same ID
            $parent = new ParentModel();
            $parent->ParentID = $person->PersonID;
            $parent->save();

            // 3. Insert Account mapped to Person
            $account = new Account();
            $account->Cin = $request->cin;
            $account->Firstname = $request->firstName;
            $account->Lastname = $request->lastName;
            $account->Birthdate = $request->birthdate;
            $account->Phone = $request->phone;
            $account->Email = AccountEmailUniqueness::trim($request->email);
            $account->Adresse = $request->adresse;
            $account->Password = Hash::make($request->password);
            $account->RoleID = 3;
            $account->PersonID = $person->PersonID;
            $account->Approval_status = 'approved';
            $account->Is_archived = 0;
            $account->save();

            // 4. Insert Children mapped to ParentID
            if ($request->has('children') && is_array($request->children)) {
                foreach ($request->children as $childData) {
                    $child = new Child();
                    $child->Firstname = $childData['firstName'];
                    $child->Lastname = $childData['lastName'];
                    $child->Birthdate = $childData['birthdate'] ?? null;
                    $child->ParentID = $parent->ParentID;
                    $child->save();
                }
            }

            DB::commit();

            return response()->json([
                'message' => 'Parent added successfully.'
            ], 201);
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
                'message' => 'Failed to create parent.',
                'error' => $e->getMessage()
            ], 500);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'message' => 'Failed to create parent.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update Parent
     *
     * Updates an existing parent's biographical and credential information.
     *
     * @authenticated
     * 
     * @urlParam cin integer required The CIN of the parent to update. Example: 12345678
     * @bodyParam firstName string required First name. Example: John
     * @bodyParam lastName string required Last name. Example: Doe
     * @bodyParam birthdate date optional Date of birth. Example: 1980-05-15
     * @bodyParam phone string optional Phone number. Example: 0600000000
     * @bodyParam email string required Email address. Example: john.doe@example.com
     * @bodyParam adresse string optional Physical address. Example: 123 Main St
     * @bodyParam password string optional New password. Example: newsecret123
     * @bodyParam password_confirmation string optional Password confirmation. Example: newsecret123
     * 
     * @response 200 {
     *   "message": "Parent updated successfully."
     * }
     */
    public function update(Request $request, $cin)
    {
        $account = Account::where('Cin', $cin)->where('RoleID', 3)->first();
        if (!$account) {
            return response()->json(['message' => 'Parent account not found'], 404);
        }

        $request->validate([
            'cin' => 'required|numeric|unique:Account,Cin,' . $account->AccountID . ',AccountID',
            'firstName' => 'required|string|max:255',
            'lastName' => 'required|string|max:255',
            'birthdate' => 'nullable|date',
            'phone' => 'nullable',
            'email' => ['required', 'email', 'max:255', AccountEmailUniqueness::validationRule($account->AccountID)],
            'adresse' => 'nullable|string',
            'password' => 'nullable|string|min:6|confirmed',
        ]);

        $account->Cin = $request->cin;
        $account->Firstname = $request->firstName;
        $account->Lastname = $request->lastName;
        $account->Birthdate = $request->birthdate;
        $account->Phone = $request->phone;
        $account->Email = AccountEmailUniqueness::trim($request->email);
        $account->Adresse = $request->adresse;
        
        if ($request->filled('password')) {
            $account->Password = Hash::make($request->password);
        }

        try {
            $account->save();
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

        return response()->json([
            'message' => 'Parent updated successfully.'
        ], 200);
    }

    /**
     * Delete Parent
     *
     * Permanently deletes a parent from the database (removing Account, Parent, and Person records).
     *
     * @authenticated
     * 
     * @urlParam cin integer required The CIN of the parent to delete. Example: 12345678
     * 
     * @response 200 {
     *   "message": "Parent deleted successfully."
     * }
     */
    public function destroy($cin)
    {
        $account = Account::where('Cin', $cin)->where('RoleID', 3)->first();
        if (!$account) {
            return response()->json(['message' => 'Parent account not found'], 404);
        }

        DB::beginTransaction();
        try {
            $personId = $account->PersonID;

            if ($personId) {
                $childIds = Child::where('ParentID', $personId)->pluck('ChildID');

                if ($childIds->isNotEmpty()) {
                    $paymentIds = DB::table('Payment')
                        ->whereIn('ChildID', $childIds)
                        ->pluck('PaymentID');

                    $inscriptionIds = DB::table('Payment')
                        ->whereIn('ChildID', $childIds)
                        ->whereNotNull('InscriptionID')
                        ->pluck('InscriptionID')
                        ->unique()
                        ->values();

                    if ($paymentIds->isNotEmpty()) {
                        DB::table('Partialpayment')->whereIn('PaymentID', $paymentIds)->delete();
                    }

                    $medicalForms = collect();
                    $dietaryCommentIds = collect();
                    $healthCommentIds = collect();

                    if ($inscriptionIds->isNotEmpty()) {
                        $medicalForms = DB::table('Medicalform')
                            ->whereIn('InscriptionID', $inscriptionIds)
                            ->get(['MedicalformID', 'DietarycommentID', 'HealthcommentID', 'InscriptionID']);

                        $dietaryCommentIds = $medicalForms->pluck('DietarycommentID')->filter()->unique()->values();
                        $healthCommentIds = $medicalForms->pluck('HealthcommentID')->filter()->unique()->values();
                    }

                    $foodExceptionIds = DB::table('Childfoodexception')
                        ->whereIn('ChildID', $childIds)
                        ->pluck('ChildfoodexceptionID');

                    $foodExceptionOverrideIds = DB::table('Childfoodexceptionoverride')
                        ->whereIn('ChildID', $childIds)
                        ->pluck('ChildfoodexceptionoverrideID');

                    if ($foodExceptionIds->isNotEmpty()) {
                        DB::table('ChildFoodExceptionMeals')
                            ->whereIn('ChildfoodexceptionID', $foodExceptionIds)
                            ->delete();
                    }

                    if ($foodExceptionOverrideIds->isNotEmpty()) {
                        DB::table('ChildFoodExceptionOverrideMeals')
                            ->whereIn('ChildfoodexceptionoverrideID', $foodExceptionOverrideIds)
                            ->delete();
                        DB::table('MealsChildFoodExceptionOverride')
                            ->whereIn('ChildfoodexceptionoverrideID', $foodExceptionOverrideIds)
                            ->delete();
                    }

                    $evaluationIds = DB::table('Evaluation')
                        ->whereIn('ChildID', $childIds)
                        ->pluck('EvaluationID');

                    if ($evaluationIds->isNotEmpty()) {
                        DB::table('Grade')->whereIn('EvaluationID', $evaluationIds)->delete();
                    }

                    DB::table('Childphotorecipient')->whereIn('ChildID', $childIds)->delete();
                    DB::table('Evaluation')->whereIn('ChildID', $childIds)->delete();
                    DB::table('Presence')->whereIn('ChildID', $childIds)->delete();
                    DB::table('ChildClass')->whereIn('ChildID', $childIds)->delete();
                    DB::table('Childfoodexceptionoverride')->whereIn('ChildID', $childIds)->delete();
                    DB::table('Childfoodexception')->whereIn('ChildID', $childIds)->delete();
                    DB::table('Payment')->whereIn('ChildID', $childIds)->delete();

                    if ($inscriptionIds->isNotEmpty()) {
                        DB::table('Medicalform')->whereIn('InscriptionID', $inscriptionIds)->delete();
                        if (Schema::hasTable('InscriptionStatusInscription')) {
                            DB::table('InscriptionStatusInscription')->whereIn('InscriptionID', $inscriptionIds)->delete();
                        }
                        DB::table('Inscription')->whereIn('InscriptionID', $inscriptionIds)->delete();

                        if ($dietaryCommentIds->isNotEmpty()) {
                            DB::table('Dietarycomment')
                                ->whereIn('DietarycommentID', $dietaryCommentIds)
                                ->whereNotIn('DietarycommentID', function ($query) use ($dietaryCommentIds) {
                                    $query->select('DietarycommentID')
                                        ->from('Medicalform')
                                        ->whereNotNull('DietarycommentID')
                                        ->whereIn('DietarycommentID', $dietaryCommentIds);
                                })
                                ->delete();
                        }

                        if ($healthCommentIds->isNotEmpty()) {
                            DB::table('Healthcomment')
                                ->whereIn('HealthcommentID', $healthCommentIds)
                                ->whereNotIn('HealthcommentID', function ($query) use ($healthCommentIds) {
                                    $query->select('HealthcommentID')
                                        ->from('Medicalform')
                                        ->whereNotNull('HealthcommentID')
                                        ->whereIn('HealthcommentID', $healthCommentIds);
                                })
                                ->delete();
                        }
                    }

                    Child::whereIn('ChildID', $childIds)->delete();
                }

                $pickupNotificationIds = DB::table('Pickupnotifications')
                    ->where('ParentID', $personId)
                    ->pluck('PickupnotificationsID');

                if ($pickupNotificationIds->isNotEmpty()) {
                    DB::table('PickupNotificationsTeacher')
                        ->whereIn('PickupnotificationsID', $pickupNotificationIds)
                        ->delete();
                }

                DB::table('Pickupnotifications')->where('ParentID', $personId)->delete();
                DB::table('Parent')->where('ParentID', $personId)->delete();
                DB::table('NotificationAccount')->where('AccountID', $account->AccountID)->delete();
                $account->delete();
                Person::where('PersonID', $personId)->delete();
            } else {
                DB::table('NotificationAccount')->where('AccountID', $account->AccountID)->delete();
                $account->delete();
            }

            DB::commit();
            return response()->json([
                'message' => 'Parent deleted successfully.'
            ], 200);
            
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'message' => 'Failed to delete parent.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update Approval Status
     *
     * Updates the 'Approval_status' column of the parent's Account record.
     *
     * @authenticated
     * 
     * @urlParam cin integer required The CIN of the parent. Example: 12345678
     * @bodyParam status string required The new approval status (pending, approved, rejected). Example: approved
     * 
     * @response 200 {
     *   "message": "Status updated successfully."
     * }
     */
    public function updateApprovalStatus(Request $request, $cin)
    {
        $request->validate([
            'status' => 'required|in:pending,approved,rejected'
        ]);

        $account = Account::where('Cin', $cin)->where('RoleID', 3)->first();
        if (!$account) {
            return response()->json(['message' => 'Parent account not found'], 404);
        }

        $wasApproved = $account->Approval_status === 'approved';
        $account->Approval_status = $request->status;
        $account->save();

        if ($request->status === 'approved' && !$wasApproved && !empty($account->Email)) {
            try {
                $freshAccount = Account::where('AccountID', $account->AccountID)->firstOrFail();
                Mail::to($freshAccount->Email)->send(new ParentApprovedMail($freshAccount));
            } catch (\Exception $mailException) {
                Log::warning('Parent approval email failed: ' . $mailException->getMessage(), [
                    'parent_cin' => $cin,
                ]);
            }
        }

        return response()->json([
            'message' => 'Status updated successfully.'
        ], 200);
    }

    /**
     * Toggle Archive Flag
     *
     * Toggles the 'Is_archived' column of the parent's Account record.
     *
     * @authenticated
     * 
     * @urlParam cin integer required The CIN of the parent. Example: 12345678
     * 
     * @response 200 {
     *   "message": "Archive status toggled successfully."
     * }
     */
    public function toggleArchive($cin)
    {
        $account = Account::where('Cin', $cin)->where('RoleID', 3)->first();
        if (!$account) {
            return response()->json(['message' => 'Parent account not found'], 404);
        }

        $account->Is_archived = !$account->Is_archived;
        $account->save();

        return response()->json([
            'message' => 'Archive status toggled successfully.'
        ], 200);
    }
}
