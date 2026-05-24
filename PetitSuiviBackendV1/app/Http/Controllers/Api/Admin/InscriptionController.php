<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use RuntimeException;

/**
 * InscriptionController
 *
 * Handles all inscription (enrollment) management operations for the Admin panel.
 * Covers listing, status changes (approve/reject/reset), class assignment,
 * AI-driven medical form analysis, food exception management, and archival toggling.
 *
 * Database Tables Used:
 *   Inscription, Payment, Child, ChildClass, Class, Classtype, Inscriptiontype,
 *   InscriptionStatusInscription, Inscriptionstatus, Medicalform,
 *   Dietarycomment, Healthcomment, Childfoodexception, ChildFoodExceptionMeals,
 *   Account (RoleID=3 for parents), Parent.
 */
class InscriptionController extends Controller
{
    /**
     * List all inscriptions
     *
     * Returns every inscription record with nested child, parent, class, status,
     * preferred type, medical form data, AI dietary/health comments, and archive state.
     * The frontend uses this to populate both the active and archived DataGrids.
     *
     * Data flow:
     *   Inscription → Payment → Child → Parent → Account (RoleID=3)
     *   Inscription → InscriptionStatusInscription → Inscriptionstatus
     *   Inscription → Inscriptiontype (preferred_type)
     *   Inscription → Medicalform → Dietarycomment / Healthcomment
     *   Child → ChildClass → Class (assigned class)
     *
     * @group Admin - Inscriptions
     * @authenticated
     *
     * @response 200 {
     *   "success": true,
     *   "data": [
     *     {
     *       "id": 1,
     *       "child_full_name": "Youssef Mejri",
     *       "child_id": 102,
     *       "age": 5,
     *       "inscription_date": "2025-08-15",
     *       "payment_method": "monthlyPartial",
     *       "total_amount": 1550.00,
     *       "is_archived": false,
     *       "previous_inscriptions_count": 0,
     *       "dietary_comment": "Allergique aux arachides.",
     *       "health_comment": "Asthme léger.",
     *       "status": { "id": 1, "name": "pending" },
     *       "class": { "id": 5, "name": "Moyenne Section B" },
     *       "parent": { "full_name": "Ahmed Mejri" },
     *       "preferred_type": { "id": 1, "name": "Kindergarten" },
     *       "medical_file": {}
     *     }
     *   ]
     * }
     */
    public function index(Request $request): JsonResponse
    {
        $includeUnapprovedParentChildren = $request->boolean('include_unapproved_parent_children');

        // Fetch all inscriptions with related data via raw joins for full control
        $inscriptions = DB::table('Inscription')
            ->select(
                'Inscription.InscriptionID',
                'Inscription.Date',
                'Inscription.PaymentmethodID',
                'Inscription.Totalamount',
                'Inscription.Isarchived',
                'Inscription.InscriptiontypeID',
                'Inscription.InscriptionstatusID',
                'Inscription.MealplanID',
                'Child.ChildID',
                'Child.Firstname as child_firstname',
                'Child.Lastname as child_lastname',
                'Child.Birthdate as child_birthdate',
                'Child.ParentID'
            )
            // Link Inscription → Payment → Child
            ->leftJoin('Payment', 'Inscription.InscriptionID', '=', 'Payment.InscriptionID')
            ->leftJoin('Child', 'Payment.ChildID', '=', 'Child.ChildID')
            ->orderByDesc('Inscription.InscriptionID')
            ->get();

        // Pre-fetch lookup tables for efficiency
        $statusMap = DB::table('Inscriptionstatus')->pluck('Name', 'InscriptionstatusID');
        $paymentMethodMap = DB::table('Paymentmethod')->pluck('Name', 'PaymentmethodID');
        $typeMap = DB::table('Inscriptiontype')->get()->keyBy('InscriptiontypeID');
        $classTypeMap = DB::table('Classtype')->get()->keyBy('ClasstypeID');

        // Pre-fetch all plannings for date-range matching
        $plannings = DB::table('Planning')->get();

        // Pre-fetch child → class assignments (include PlanningID for year scoping)
        $childClassMap = DB::table('ChildClass')
            ->join('Class', 'ChildClass.ClassID', '=', 'Class.ClassID')
            ->select('ChildClass.ChildID', 'Class.ClassID', 'Class.Name as class_name', 'Class.ClasstypeID', 'Class.PlanningID')
            ->get()
            ->groupBy('ChildID');

        // Pre-fetch medical forms by ChildID (a child has only 1 form, submitted with first inscription)
        $medicalFormsByChild = DB::table('Medicalform')
            ->join('Payment', 'Medicalform.InscriptionID', '=', 'Payment.InscriptionID')
            ->select('Medicalform.*', 'Payment.ChildID')
            ->orderBy('Medicalform.MedicalformID', 'asc') // Use the original one
            ->get()
            ->keyBy('ChildID');

        // Pre-fetch dietary/health comments by MedicalformID
        $dietaryComments = DB::table('Dietarycomment')->get()->keyBy('DietarycommentID');
        $healthComments = DB::table('Healthcomment')->get()->keyBy('HealthcommentID');

        // Pre-fetch parent accounts (RoleID=3)
        $parentAccounts = DB::table('Account')
            ->where('RoleID', 3)
            ->select('PersonID', 'Firstname', 'Lastname', 'Approval_status')
            ->get()
            ->keyBy('PersonID');

        // Count previous inscriptions per child
        $previousCounts = DB::table('Payment')
            ->select('ChildID', DB::raw('COUNT(DISTINCT InscriptionID) as cnt'))
            ->groupBy('ChildID')
            ->pluck('cnt', 'ChildID');

        if (!$includeUnapprovedParentChildren) {
            // Keep the registrations view limited to children whose parent is approved.
            $inscriptions = $inscriptions->filter(function ($insc) use ($parentAccounts) {
                if ($insc->ParentID && isset($parentAccounts[$insc->ParentID])) {
                    return $parentAccounts[$insc->ParentID]->Approval_status === 'approved';
                }
                return false;
            });
        }

        $result = $inscriptions->map(function ($insc) use (
            $statusMap, $paymentMethodMap, $typeMap, $classTypeMap,
            $childClassMap, $medicalFormsByChild, $dietaryComments,
            $healthComments, $parentAccounts, $previousCounts, $plannings
        ) {
            $inscId = $insc->InscriptionID;
            $childId = $insc->ChildID;

            // Build child name
            $childFullName = trim(($insc->child_firstname ?? '') . ' ' . ($insc->child_lastname ?? ''));

            // Calculate age
            $age = null;
            if (!empty($insc->child_birthdate)) {
                try { $age = Carbon::parse($insc->child_birthdate)->age; } catch (\Exception $e) {}
            }

            // Resolve status directly
            $statusId = $insc->InscriptionstatusID;
            $statusName = $statusId ? ($statusMap[$statusId] ?? 'pending') : 'pending';
            $paymentMethod = ($insc->PaymentmethodID && isset($paymentMethodMap[$insc->PaymentmethodID]))
                ? $paymentMethodMap[$insc->PaymentmethodID]
                : null;

            // Resolve preferred inscription type
            $preferredType = null;
            if ($insc->InscriptiontypeID && isset($typeMap[$insc->InscriptiontypeID])) {
                $type = $typeMap[$insc->InscriptiontypeID];
                $preferredType = ['id' => $type->InscriptiontypeID, 'name' => $type->Name];
            }

            // Determine which planning covers this inscription's date
            $inscPlanningId = $this->findPlanningIdForDate($insc->Date, $plannings);

            // Resolve assigned class (via ChildClass pivot), scoped to inscription's planning
            $classData = null;
            if ($childId && $childClassMap->has($childId)) {
                $childClasses = $childClassMap->get($childId);
                $classRow = null;

                // Try to find a class matching the inscription's planning period
                if ($inscPlanningId) {
                    $classRow = $childClasses->first(fn($c) => $c->PlanningID == $inscPlanningId);
                }
                // Fallback: take the first available class if no planning match
                if (!$classRow) {
                    $classRow = $childClasses->first();
                }

                if ($classRow) {
                    $classData = [
                        'id'   => $classRow->ClassID,
                        'name' => $classRow->class_name,
                        'type' => isset($classTypeMap[$classRow->ClasstypeID])
                            ? $classTypeMap[$classRow->ClasstypeID]->Name : null,
                    ];
                }
            }

            // Enforce consistency: approved must have a class
            if ($statusName === 'approved' && !$classData) {
                $pendingId = $statusMap->search('pending');
                $statusName = 'pending';
                $statusId = $pendingId ?: $statusId;
            }

            // Resolve parent name
            $parentFullName = null;
            if ($insc->ParentID && isset($parentAccounts[$insc->ParentID])) {
                $pa = $parentAccounts[$insc->ParentID];
                $parentFullName = trim(($pa->Firstname ?? '') . ' ' . ($pa->Lastname ?? ''));
            }

            // Resolve medical form + AI comments (tracked securely via ChildID)
            $medForm = $medicalFormsByChild[$childId] ?? null;
            $medicalFile = null;
            $dietaryComment = null;
            $healthComment = null;

            if ($medForm) {
                $formData = $medForm->Formdata;
                if (is_string($formData)) {
                    $decoded = json_decode($formData, true);
                    $medicalFile = $decoded ?: null;
                } else {
                    $medicalFile = $formData;
                }

                if ($medForm->DietarycommentID && isset($dietaryComments[$medForm->DietarycommentID])) {
                    $dietaryComment = $dietaryComments[$medForm->DietarycommentID]->Dietarycomment;
                }
                if ($medForm->HealthcommentID && isset($healthComments[$medForm->HealthcommentID])) {
                    $healthComment = $healthComments[$medForm->HealthcommentID]->Healthcomment;
                }
            }

            if (
                (!is_string($dietaryComment) || trim($dietaryComment) === '') &&
                (!is_string($healthComment) || trim($healthComment) === '')
            ) {
                [$fallbackDietaryComment, $fallbackHealthComment] = $this->resolveOriginalStoredAiCommentsForChild($childId);
                $dietaryComment = $fallbackDietaryComment;
                $healthComment = $fallbackHealthComment;
            }

            // Previous inscriptions count (exclude current)
            $prevCount = max(0, ($previousCounts[$childId] ?? 1) - 1);

            return [
                'id'                          => $inscId,
                'child_id'                    => $childId,
                'child_full_name'             => $childFullName ?: null,
                'age'                         => $age,
                'parent'                      => ['full_name' => $parentFullName],
                'preferred_type'              => $preferredType,
                'class'                       => $classData,
                'inscription_date'            => $insc->Date,
                'payment_method'              => $paymentMethod,
                'total_amount'                => $insc->Totalamount !== null ? (float) $insc->Totalamount : null,
                'medical_file'                => $medicalFile,
                'dietary_comment'             => $dietaryComment,
                'health_comment'              => $healthComment,
                'is_archived'                 => (bool) $insc->Isarchived,
                'status'                      => ['id' => $statusId, 'name' => $statusName],
                'previous_inscriptions_count' => $prevCount,
                'meal_plan_id'                => $insc->MealplanID,
            ];
        })->values();

        return response()->json([
            'success' => true,
            'data'    => $result,
        ]);
    }

    /**
     * Show a single inscription
     *
     * Returns detailed information about a specific inscription including all
     * nested relationships (child, parent, class, medical form, AI comments).
     *
     * @group Admin - Inscriptions
     * @authenticated
     *
     * @urlParam id integer required The InscriptionID. Example: 1
     *
     * @response 200 {
     *   "success": true,
     *   "data": {
     *     "id": 1,
     *     "child_full_name": "Youssef Mejri",
     *     "child_id": 102,
     *     "inscription_date": "2025-08-15",
     *     "status": { "id": 1, "name": "approved" },
     *     "class": { "id": 5, "name": "Moyenne Section B" },
     *     "medical_file": {}
     *   }
     * }
     */
    public function show(int $id): JsonResponse
    {
        $insc = DB::table('Inscription')
            ->where('Inscription.InscriptionID', $id)
            ->leftJoin('Payment', 'Inscription.InscriptionID', '=', 'Payment.InscriptionID')
            ->leftJoin('Child', 'Payment.ChildID', '=', 'Child.ChildID')
            ->select(
                'Inscription.*',
                'Child.ChildID', 'Child.Firstname as child_firstname',
                'Child.Lastname as child_lastname', 'Child.Birthdate as child_birthdate',
                'Child.ParentID'
            )
            ->first();

        if (!$insc) {
            return response()->json(['success' => false, 'message' => 'Inscription not found.'], 404);
        }

        // Resolve status
        $statusId = $insc->InscriptionstatusID;
        $statusName = 'pending';
        if ($statusId) {
            $statusName = DB::table('Inscriptionstatus')
                ->where('InscriptionstatusID', $statusId)->value('Name') ?? 'pending';
        }

        // Resolve class — scoped to the planning period matching this inscription's date
        $classData = null;
        if ($insc->ChildID) {
            $query = DB::table('ChildClass')
                ->join('Class', 'ChildClass.ClassID', '=', 'Class.ClassID')
                ->where('ChildClass.ChildID', $insc->ChildID)
                ->select('Class.ClassID', 'Class.Name', 'Class.PlanningID');

            // Find the planning that matches this inscription's school year
            if ($insc->Date) {
                $matchingPlanningId = $this->findPlanningIdForDate($insc->Date);
                if ($matchingPlanningId) {
                    $query->where('Class.PlanningID', $matchingPlanningId);
                }
            }

            $cls = $query->first();
            if ($cls) {
                $classData = ['id' => $cls->ClassID, 'name' => $cls->Name];
            }
        }

        // Resolve medical form by ChildID
        $medForm = null;
        if ($insc->ChildID) {
            $medForm = DB::table('Medicalform')
                ->join('Payment', 'Medicalform.InscriptionID', '=', 'Payment.InscriptionID')
                ->where('Payment.ChildID', $insc->ChildID)
                ->select('Medicalform.*')
                ->orderBy('Medicalform.MedicalformID', 'asc') // Get original form
                ->first();
        }
        $medicalFile = null;
        if ($medForm && $medForm->Formdata) {
            $decoded = is_string($medForm->Formdata) ? json_decode($medForm->Formdata, true) : $medForm->Formdata;
            $medicalFile = $decoded ?: null;
        }

        $childFullName = trim(($insc->child_firstname ?? '') . ' ' . ($insc->child_lastname ?? ''));

        return response()->json([
            'success' => true,
            'data' => [
                'id'              => $insc->InscriptionID,
                'child_id'        => $insc->ChildID,
                'child_full_name' => $childFullName ?: null,
                'inscription_date' => $insc->Date,
                'status'          => ['id' => $statusId, 'name' => $statusName],
                'class'           => $classData,
                'medical_file'    => $medicalFile,
                'meal_plan_id'    => $insc->MealplanID,
            ],
        ]);
    }

    /**
     * Update inscription status
     *
     * Changes the status of an inscription to approved, rejected, or pending.
     * When approving with a class_id, assigns the child to that class via the
     * ChildClass pivot table. When rejecting or resetting to pending, removes
     * the ChildClass assignment. Also manages Payment record creation on approval.
     *
     * @group Admin - Inscriptions
     * @authenticated
     *
     * @urlParam id integer required The InscriptionID. Example: 1
     * @bodyParam status string required The target status: "approved", "rejected", or "pending". Example: approved
     * @bodyParam class_id integer Optional class ID for assignment on approval. Example: 5
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Inscription status updated.",
     *   "data": {
     *     "id": 1,
     *     "status": { "id": 2, "name": "approved" },
     *     "class": { "id": 5, "name": "Moyenne Section B" }
     *   }
     * }
     */
    public function updateStatus(Request $request, int $id): JsonResponse
    {
        $request->validate([
            'status'   => 'required|string|in:approved,rejected,pending',
            'class_id' => 'nullable|integer',
        ]);

        $statusName = $request->input('status');
        $classId = $request->input('class_id');

        // Resolve the Inscriptionstatus ID from the name
        $statusRow = DB::table('Inscriptionstatus')->whereRaw('LOWER(Name) = ?', [strtolower($statusName)])->first();
        if (!$statusRow) {
            // Auto-create the status if it doesn't exist
            $newStatusId = DB::table('Inscriptionstatus')->insertGetId(['Name' => $statusName]);
            $statusId = $newStatusId;
        } else {
            $statusId = $statusRow->InscriptionstatusID;
        }

        // Verify inscription exists
        $inscription = DB::table('Inscription')->where('InscriptionID', $id)->first();
        if (!$inscription) {
            return response()->json(['success' => false, 'message' => 'Inscription not found.'], 404);
        }

        // Get the child ID via Payment
        $childId = DB::table('Payment')->where('InscriptionID', $id)->value('ChildID');

        return DB::transaction(function () use ($id, $statusName, $statusId, $classId, $childId, $inscription) {
            // Validate approval prerequisites before persisting the approved status.
            $classData = null;
            if ($statusName === 'approved') {
                DB::table('Inscription')
                    ->where('InscriptionID', $id)
                    ->update(['InscriptionstatusID' => $statusId]);

                if ($classId && $childId) {
                    // Only allow assignment to a class from the same, active planning.
                    $matchingPlanningId = $this->findPlanningIdForDate($inscription->Date);
                    $cls = DB::table('Class')
                        ->leftJoin('Planning', 'Class.PlanningID', '=', 'Planning.PlanningID')
                        ->select('Class.*', 'Planning.Isarchived as PlanningIsarchived')
                        ->where('Class.ClassID', $classId)
                        ->first();

                    if (!$cls) {
                        return response()->json(['success' => false, 'message' => 'Class not found.'], 422);
                    }

                    if ((bool) ($cls->PlanningIsarchived ?? false)) {
                        return response()->json([
                            'success' => false,
                            'message' => 'Cannot assign class: selected class belongs to an archived planning.',
                        ], 422);
                    }

                    if ($matchingPlanningId && (int) $cls->PlanningID !== (int) $matchingPlanningId) {
                        return response()->json([
                            'success' => false,
                            'message' => 'Cannot assign class: selected class does not belong to this inscription planning.',
                        ], 422);
                    }

                    $enrolledCount = DB::table('ChildClass')->where('ClassID', $classId)->count();
                    $alreadyEnrolled = DB::table('ChildClass')
                        ->where('ChildID', $childId)->where('ClassID', $classId)->exists();

                    if (!$alreadyEnrolled && $cls->Capacity !== null && $enrolledCount >= $cls->Capacity) {
                        return response()->json([
                            'success' => false,
                            'message' => 'Cannot assign class: selected class is full.',
                        ], 422);
                    }

                    // Assign child to class (upsert pattern)
                    if (!$alreadyEnrolled) {
                        // Remove only class assignments for the SAME planning period
                        // so we don't destroy the child's class in other school years
                        $samePlanningClassIds = DB::table('Class')
                            ->where('PlanningID', $cls->PlanningID)
                            ->pluck('ClassID');
                        DB::table('ChildClass')
                            ->where('ChildID', $childId)
                            ->whereIn('ClassID', $samePlanningClassIds)
                            ->delete();

                        DB::table('ChildClass')->insert([
                            'ChildID' => $childId,
                            'ClassID' => $classId,
                        ]);
                    }

                    $classData = ['id' => $cls->ClassID, 'name' => $cls->Name];
                }

                // Ensure a Payment record exists
                $this->ensurePaymentExists($id, $childId, $inscription);

            } else {
                DB::table('Inscription')
                    ->where('InscriptionID', $id)
                    ->update(['InscriptionstatusID' => $statusId]);

                // Rejected or pending → remove class assignment ONLY for this inscription's year
                if ($childId && $inscription->Date) {
                    $matchingPlanningId = $this->findPlanningIdForDate($inscription->Date);

                    if ($matchingPlanningId) {
                        $yearClassIds = DB::table('Class')
                            ->where('PlanningID', $matchingPlanningId)
                            ->pluck('ClassID');
                        DB::table('ChildClass')
                            ->where('ChildID', $childId)
                            ->whereIn('ClassID', $yearClassIds)
                            ->delete();
                    } else {
                        // Fallback: if no planning match, delete all (legacy behavior)
                        DB::table('ChildClass')->where('ChildID', $childId)->delete();
                    }
                } elseif ($childId) {
                    DB::table('ChildClass')->where('ChildID', $childId)->delete();
                }
            }

            return response()->json([
                'success' => true,
                'message' => 'Inscription status updated.',
                'data'    => [
                    'id'     => $id,
                    'status' => ['id' => $statusId, 'name' => $statusName],
                    'class'  => $classData,
                ],
            ]);
        });
    }

    /**
     * Toggle inscription archive state
     *
     * Flips the Isarchived flag (0↔1) on the Inscription record.
     * Archived inscriptions appear in a separate DataGrid section in the frontend.
     *
     * @group Admin - Inscriptions
     * @authenticated
     *
     * @urlParam id integer required The InscriptionID. Example: 1
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Archive status toggled."
     * }
     */
    public function toggleArchive(int $id): JsonResponse
    {
        $inscription = DB::table('Inscription')->where('InscriptionID', $id)->first();
        if (!$inscription) {
            return response()->json(['success' => false, 'message' => 'Inscription not found.'], 404);
        }

        $newState = $inscription->Isarchived ? 0 : 1;
        DB::table('Inscription')->where('InscriptionID', $id)->update(['Isarchived' => $newState]);

        return response()->json([
            'success' => true,
            'message' => $newState ? 'Inscription archived.' : 'Inscription unarchived.',
        ]);
    }

    /**
     * Save or update AI-generated comments
     *
     * Persists the (possibly admin-edited) dietary and health comments
     * produced by the AI medical form analysis. Creates or updates
     * Dietarycomment and Healthcomment records linked to the child's Medicalform.
     *
     * @group Admin - Inscriptions
     * @authenticated
     *
     * @urlParam childId integer required The ChildID. Example: 102
     * @bodyParam dietary_comment string required The dietary analysis text. Example: Allergique aux arachides.
     * @bodyParam health_comment string required The health analysis text. Example: Asthme léger.
     *
     * @response 200 {
     *   "success": true,
     *   "message": "AI comments saved.",
     *   "dietary_comment": "Allergique aux arachides.",
     *   "health_comment": "Asthme léger."
     * }
     */
    public function saveAiComments(Request $request, int $childId): JsonResponse
    {
        $request->validate([
            'dietary_comment' => 'nullable|string|max:5000',
            'health_comment'  => 'nullable|string|max:5000',
        ]);

        // Medical comments are child-level data in this app: later re-inscriptions keep the
        // original medical record context, so comment edits must stay in sync across all forms.
        // Find ALL medical forms for this child
        $medForms = DB::table('Medicalform')
            ->join('Inscription', 'Inscription.InscriptionID', '=', 'Medicalform.InscriptionID')
            ->join('Payment', 'Payment.InscriptionID', '=', 'Inscription.InscriptionID')
            ->where('Payment.ChildID', $childId)
            ->select('Medicalform.*')
            ->get();

        if ($medForms->isEmpty()) {
            return response()->json(['success' => false, 'message' => 'No medical form found for this child.'], 404);
        }

        $dietaryText = $request->input('dietary_comment');
        $healthText = $request->input('health_comment');

        DB::transaction(function () use ($medForms, $dietaryText, $healthText) {
            // Find existing shared comment IDs if any
            $sharedDietaryId = $medForms->pluck('DietarycommentID')->filter()->first();
            $sharedHealthId = $medForms->pluck('HealthcommentID')->filter()->first();

            // Upsert Dietary comment
            if ($dietaryText !== null) {
                if ($sharedDietaryId) {
                    DB::table('Dietarycomment')
                        ->where('DietarycommentID', $sharedDietaryId)
                        ->update(['Dietarycomment' => $dietaryText]);
                } else {
                    $sharedDietaryId = DB::table('Dietarycomment')->insertGetId(
                        ['Dietarycomment' => $dietaryText],
                        'DietarycommentID'
                    );
                }
                // Link all the child's medical forms to this single shared dietary record
                DB::table('Medicalform')
                    ->whereIn('MedicalformID', $medForms->pluck('MedicalformID'))
                    ->update(['DietarycommentID' => $sharedDietaryId]);
            }

            // Upsert Health comment
            if ($healthText !== null) {
                if ($sharedHealthId) {
                    DB::table('Healthcomment')
                        ->where('HealthcommentID', $sharedHealthId)
                        ->update(['Healthcomment' => $healthText]);
                } else {
                    $sharedHealthId = DB::table('Healthcomment')->insertGetId(
                        ['Healthcomment' => $healthText],
                        'HealthcommentID'
                    );
                }
                // Link all the child's medical forms to this single shared health record
                DB::table('Medicalform')
                    ->whereIn('MedicalformID', $medForms->pluck('MedicalformID'))
                    ->update(['HealthcommentID' => $sharedHealthId]);
            }
        });

        return response()->json([
            'success'         => true,
            'message'         => 'AI comments saved and synced across all child inscriptions.',
            'dietary_comment' => $dietaryText,
            'health_comment'  => $healthText,
        ]);
    }

    /**
     * Rescan medical form with AI
     *
     * Triggers the AI backend service to re-analyse the child's medical form
     * and extract dietary restrictions and health notes. If AI is not configured,
     * returns default "no issues" messages. Optionally saves results to the database.
     *
     * @group Admin - Inscriptions
     * @authenticated
     *
     * @urlParam childId integer required The ChildID. Example: 102
     * @bodyParam save_to_db boolean Whether to persist results immediately. Example: false
     *
     * @response 200 {
     *   "success": true,
     *   "dietary_comment": "Allergique aux arachides et aux fruits de mer.",
     *   "health_comment": "Asthme léger nécessitant un inhalateur."
     * }
     */
    public function rescanMedical(Request $request, int $childId): JsonResponse
    {
        $saveToDb = $request->input('save_to_db', true);

        if (!$this->isAiEnabled()) {
            return response()->json([
                'success' => false,
                'message' => 'AI module disabled. Please disable ai_enabled in Parameters to bypass AI approval.',
            ], 409);
        }

        // Find ALL medical forms for this child
        $medForms = DB::table('Medicalform')
            ->join('Inscription', 'Inscription.InscriptionID', '=', 'Medicalform.InscriptionID')
            ->join('Payment', 'Payment.InscriptionID', '=', 'Inscription.InscriptionID')
            ->where('Payment.ChildID', $childId)
            ->select('Medicalform.*')
            ->orderByDesc('Medicalform.MedicalformID')
            ->get();

        if ($medForms->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => 'No medical form found for this child.',
            ], 404);
        }

        // Use the newest form data for scanning
        $latestMedForm = $medForms->first();

        // Get child name for AI prompt
        $child = DB::table('Child')->where('ChildID', $childId)->first();
        $childName = trim(($child->Firstname ?? '') . ' ' . ($child->Lastname ?? ''));

        // Parse form data
        $rawFormData = is_string($latestMedForm->Formdata)
            ? json_decode($latestMedForm->Formdata, true) : (array) ($latestMedForm->Formdata ?? []);
        $fullFormJson = json_encode($rawFormData, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);

        try {
            // ── Dietary Analysis ──
            $dietaryPrompt = config('prompts.medical.analyze_dietary', "Analyse uniquement les contraintes alimentaires et precautions de repas utiles pour le personnel de garde a partir du formulaire medical suivant. Reponds en francais, en 1 phrase courte uniquement. N'inclue jamais le nom de l'enfant, la date de naissance, des labels comme 'Restriction alimentaire :', des antecedents generaux, des details familiaux, ni un recapitulatif complet du dossier. Mentionne seulement l'interdiction, l'allergie, l'intolerance, le regime obligatoire ou toute information de sante qui implique une adaptation concrete de l'alimentation, des ingredients, des boissons, de la texture ou des quantites. Si aucune precaution alimentaire claire n'est presente, reponds exactement par '✅ Aucune restriction alimentaire détectée.' Formulaire medical : :fullFormJson");
            $dietaryPrompt = str_replace([':childName', ':fullFormJson'], [$childName, $fullFormJson], $dietaryPrompt);

            $dietaryOutput = $this->callCopilotProxy($dietaryPrompt);
            $dietaryOutput = $dietaryOutput ?: '✅ Aucune restriction alimentaire détectée.';

            // ── Health Analysis ──
            $healthPrompt = config('prompts.medical.analyze_health', "Analyse uniquement les informations de sante generale utiles pour le personnel de garde a partir du formulaire medical suivant. Reponds en francais, en 1 ou 2 phrases courtes maximum. N'inclue jamais le nom de l'enfant, la date de naissance, des labels comme 'Analyse Santé Générale' ou 'Restriction alimentaire', des antecedents familiaux, les conditions de naissance, ni un recapitulatif complet du dossier. Mentionne seulement les problemes de sante actuels ou les precautions concretes a suivre qui ne sont pas deja des consignes alimentaires. Si aucun probleme notable n'est present, reponds exactement par '✅ Aucun problème de santé notable détecté.' Formulaire medical : :fullFormJson");
            $healthPrompt = str_replace([':childName', ':fullFormJson'], [$childName, $fullFormJson], $healthPrompt);

            $healthOutput = $this->callCopilotProxy($healthPrompt);
            $healthOutput = $healthOutput ?: '✅ Aucun problème de santé notable détecté.';

            if ($saveToDb) {
                // Keep comments in sync across all a child's medical forms
                $this->persistAiCommentsSynced($medForms, $dietaryOutput, $healthOutput);
            }

            return response()->json([
                'success'         => true,
                'message'         => 'Analysis complete and synced.',
                'dietary_comment' => $dietaryOutput,
                'health_comment'  => $healthOutput,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'AI module error: ' . $e->getMessage() . ' Please disable ai_enabled in Parameters if you want to bypass this step.',
            ], 502);
        }
    }

    /**
     * Scan meals for food exceptions
     *
     * Sends the dietary comment to the AI service which cross-references all
     * existing meals in the system and returns a list of potentially
     * problematic meals for this child.
     *
     * @group Admin - Inscriptions
     * @authenticated
     *
     * @urlParam childId integer required The ChildID. Example: 102
     * @bodyParam dietary_comment string required The dietary restrictions text. Example: Allergique aux arachides.
     *
     * @response 200 {
     *   "success": true,
     *   "exceptions": [
     *     { "meal_id": 14, "reason": "Contient des arachides dans la sauce." },
     *     { "meal_id": 22, "reason": "Présence de fruits à coque." }
     *   ]
     * }
     */
    public function scanMeals(Request $request, int $childId): JsonResponse
    {
        $request->validate([
            'dietary_comment' => 'nullable|string',
            'health_comment' => 'nullable|string',
        ]);

        $restrictionContext = $this->buildMealRestrictionContext(
            $request->input('dietary_comment'),
            $request->input('health_comment')
        );

        if ($restrictionContext === null) {
            return response()->json([
                'success' => true,
                'exceptions' => [],
                'message' => 'No actionable meal restriction was found for this child.',
            ]);
        }

        // Resolve the child's MealplanID from their latest inscription
        $mealPlanId = DB::table('Payment')
            ->join('Inscription', 'Payment.InscriptionID', '=', 'Inscription.InscriptionID')
            ->where('Payment.ChildID', $childId)
            ->orderByDesc('Inscription.Date')
            ->orderByDesc('Inscription.InscriptionID')
            ->value('Inscription.MealplanID');

        // Gratuit (MealplanID=4) → no meals to scan
        if ((int) $mealPlanId === 4) {
            return response()->json(['success' => true, 'exceptions' => []]);
        }

        // Load meals filtered by the child's meal plan
        $mealsQuery = DB::table('Meals')
            ->leftJoin('Mealscategory', 'Meals.MealscategoryID', '=', 'Mealscategory.MealscategoryID')
            ->select('Meals.MealsID', 'Meals.Name', 'Mealscategory.Name as category_name');

        // Dejeuner-only (MealplanID=2) → only scan lunch meals
        if ((int) $mealPlanId === 2) {
            $mealsQuery->whereRaw('LOWER(Mealscategory.Name) = ?', ['lunch']);
        }
        // Gouter-only (MealplanID=3) → only scan snack meals
        elseif ((int) $mealPlanId === 3) {
            $mealsQuery->where(function ($sub) {
                $sub->whereRaw('LOWER(Mealscategory.Name) IN (?, ?, ?, ?)', ['snack', 'snacks', 'goûter', 'gouter']);
            });
        }

        $meals = $mealsQuery->get();

        if ($meals->isEmpty()) {
            return response()->json(['success' => true, 'exceptions' => []]);
        }

        try {
            $mealsJson = $meals->map(fn($m) => ['id' => $m->MealsID, 'name' => $m->Name, 'category' => $m->category_name])->toJson(JSON_UNESCAPED_UNICODE);

            $prompt = "Given this child context related to meals:\n{$restrictionContext}\n\nAnd these meals:\n{$mealsJson}\n\nIdentify only the meals that could plausibly conflict with the child's dietary restrictions or with any health note that implies a concrete meal precaution. Return ONLY a JSON array of problematic meals in this exact format: [{\"meal_id\": <id>, \"reason\": \"<brief explanation in French>\"}]. If no issues, return [].";

            $rawOutput = $this->callCopilotProxy($prompt);

            // Extract JSON array from AI response
            if (!preg_match('/\[.*\]/s', $rawOutput, $matches)) {
                throw new RuntimeException('AI returned an unexpected format for meal scanning.');
            }

            $parsed = json_decode($matches[0], true);
            if (!is_array($parsed)) {
                throw new RuntimeException('AI returned invalid JSON for meal scanning.');
            }

            $exceptions = $parsed;

            // Enrich exceptions with meal name from DB
            $mealsById = $meals->keyBy('MealsID');
            $exceptions = array_map(function ($exc) use ($mealsById) {
                $mealId = $exc['meal_id'] ?? null;
                $meal = $mealId ? ($mealsById[$mealId] ?? null) : null;
                $exc['meal_name'] = $meal->Name ?? null;
                return $exc;
            }, $exceptions);

            return response()->json(['success' => true, 'exceptions' => $exceptions]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'AI module error: ' . $e->getMessage() . ' Please disable ai_enabled in Parameters if you want to bypass this step.',
            ], 500);
        }
    }

    /**
     * Save food exceptions for a child
     *
     * Persists the admin-verified food exceptions into the Childfoodexception table.
     * Uses a delete-then-reinsert strategy for clean replacement. Also links
     * exceptions to meals via the ChildFoodExceptionMeals pivot table.
     *
     * @group Admin - Inscriptions
     * @authenticated
     *
     * @urlParam childId integer required The ChildID. Example: 102
     * @bodyParam exceptions array required List of food exception objects. Example: [{"meal_id": 14, "reason": "Contient des arachides."}]
     * @bodyParam exceptions[].meal_id integer required The MealID. Example: 14
     * @bodyParam exceptions[].reason string required Explanation of the exception. Example: Contient des arachides.
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Food exceptions saved.",
     *   "count": 2
     * }
     */
    public function saveFoodExceptions(Request $request, int $childId): JsonResponse
    {
        $request->validate([
            'exceptions'           => 'present|array',
            'exceptions.*.meal_id' => 'required|integer',
            'exceptions.*.reason'  => 'required|string',
        ]);

        $exceptions = $request->input('exceptions', []);

        DB::transaction(function () use ($childId, $exceptions) {
            // Food exceptions also belong to the child, not to an individual school-year
            // inscription. Replacing them by ChildID preserves one long-lived exception set.
            // Get existing exception IDs for this child to clean up pivot
            $existingIds = DB::table('Childfoodexception')
                ->where('ChildID', $childId)
                ->pluck('ChildfoodexceptionID');

            // Delete pivot rows
            if ($existingIds->isNotEmpty()) {
                DB::table('ChildFoodExceptionMeals')
                    ->whereIn('ChildfoodexceptionID', $existingIds)
                    ->delete();
            }

            // Delete old exceptions
            DB::table('Childfoodexception')->where('ChildID', $childId)->delete();

            // Insert new exceptions and link to meals
            foreach ($exceptions as $exc) {
                $excId = DB::table('Childfoodexception')->insertGetId([
                    'ChildID' => $childId,
                    'Reason'  => $exc['reason'],
                ], 'ChildfoodexceptionID');

                // Link to meal via pivot
                DB::table('ChildFoodExceptionMeals')->insert([
                    'ChildfoodexceptionID' => $excId,
                    'MealsID'              => $exc['meal_id'],
                ]);
            }
        });

        return response()->json([
            'success' => true,
            'message' => 'Food exceptions saved.',
            'count'   => count($exceptions),
        ]);
    }

    /**
     * Toggle Inscription Fee (Frais d'Inscription)
     *
     * Toggles whether the annual administration fee has been collected
     * for a specific inscription. When checked, the Inscriptionfeespaymentamount
     * column is set to the Fraisinscriptionsnapshot value; when unchecked,
     * it is reset to NULL.
     *
     * @group Admin - Payments
     * @authenticated
     *
     * @urlParam id integer required The InscriptionID. Example: 101
     * @bodyParam checked boolean required Whether the fee is now paid. Example: true
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Frais inscription updated.",
     *   "data": {
     *     "frais_inscription_amount": 150
     *   }
     * }
     */
    public function toggleFrais(Request $request, int $id): JsonResponse
    {
        $request->validate([
            'checked' => 'required|boolean',
        ]);

        $inscription = DB::table('Inscription')
            ->where('InscriptionID', $id)
            ->first();

        if (!$inscription) {
            return response()->json([
                'success' => false,
                'message' => 'Inscription not found.',
            ], 404);
        }

        $checked  = (bool) $request->input('checked');
        $snapshot = $inscription->Fraisinscriptionsnapshot;

        // When checked → set amount to snapshot; when unchecked → null
        $newAmount = $checked ? $snapshot : null;

        DB::table('Inscription')
            ->where('InscriptionID', $id)
            ->update(['Inscriptionfeespaymentamount' => $newAmount]);

        return response()->json([
            'success' => true,
            'message' => 'Frais inscription updated.',
            'data'    => [
                'frais_inscription_amount' => $newAmount !== null ? (float) $newAmount : null,
            ],
        ]);
    }

    /* ═══════════════════════════════════════════════════════════════
     * PRIVATE HELPER METHODS
     * ═══════════════════════════════════════════════════════════════ */

    /**
     * Ensure a Payment record exists for an approved inscription.
     * Creates one if missing, using inscription's total amount and date.
     */
    private function ensurePaymentExists(int $inscriptionId, ?int $childId, object $inscription): void
    {
        if (!$childId) return;

        $existing = DB::table('Payment')
            ->where('InscriptionID', $inscriptionId)
            ->where('ChildID', $childId)
            ->first();

        if (!$existing) {
            DB::table('Payment')->insert([
                'InscriptionID' => $inscriptionId,
                'ChildID'       => $childId,
                'Amount'        => max((float) ($inscription->Totalamount ?? 0), 0),
                'Date'          => $inscription->Date ?? now()->format('Y-m-d'),
            ]);
        }
    }

    /**
     * Persist AI-generated dietary and health comments to the database in sync.
     * Ensures all of a child's medical forms share the exact same comment record
     * to prevent duplication and desync issues across years.
     */
    private function persistAiCommentsSynced(\Illuminate\Support\Collection $medForms, string $dietary, string $health): void
    {
        DB::transaction(function () use ($medForms, $dietary, $health) {
            $sharedDietaryId = $medForms->pluck('DietarycommentID')->filter()->first();
            $sharedHealthId = $medForms->pluck('HealthcommentID')->filter()->first();

            // Handle Dietary
            if ($sharedDietaryId) {
                DB::table('Dietarycomment')->where('DietarycommentID', $sharedDietaryId)->update(['Dietarycomment' => $dietary]);
            } else {
                $sharedDietaryId = DB::table('Dietarycomment')->insertGetId(['Dietarycomment' => $dietary], 'DietarycommentID');
            }
            DB::table('Medicalform')->whereIn('MedicalformID', $medForms->pluck('MedicalformID'))
                ->update(['DietarycommentID' => $sharedDietaryId]);

            // Handle Health
            if ($sharedHealthId) {
                DB::table('Healthcomment')->where('HealthcommentID', $sharedHealthId)->update(['Healthcomment' => $health]);
            } else {
                $sharedHealthId = DB::table('Healthcomment')->insertGetId(['Healthcomment' => $health], 'HealthcommentID');
            }
            DB::table('Medicalform')->whereIn('MedicalformID', $medForms->pluck('MedicalformID'))
                ->update(['HealthcommentID' => $sharedHealthId]);
        });
    }

    /**
     * Determine the PlanningID for an inscription date using a 2-month pre-start margin.
     *
     * A planning is eligible when the inscription date falls between:
     *   - Startdate minus 2 months
     *   - Enddate
     *
     * If multiple plannings match, prefer non-archived plannings first, then the
     * planning whose Startdate is closest to the inscription date.
     *
     * @param string|null $date       The inscription date.
     * @param \Illuminate\Support\Collection|null $plannings  Optional pre-fetched plannings.
     * @return int|null  The matched PlanningID, or null.
     */
    private function findPlanningIdForDate(?string $date, $plannings = null): ?int
    {
        if (!$date) {
            return null;
        }

        try {
            $inscriptionDate = Carbon::parse($date)->startOfDay();
        } catch (\Exception $exception) {
            return null;
        }

        $planningRows = $plannings ?: DB::table('Planning')->get();

        $matchedPlanning = collect($planningRows)
            ->filter(function ($planning) use ($inscriptionDate) {
                if (empty($planning->Startdate) || empty($planning->Enddate)) {
                    return false;
                }

                try {
                    $startDate = Carbon::parse($planning->Startdate)->startOfDay();
                    $endDate = Carbon::parse($planning->Enddate)->endOfDay();
                } catch (\Exception $exception) {
                    return false;
                }

                $effectiveStart = $startDate->copy()->subMonthsNoOverflow(2);

                return $inscriptionDate->between($effectiveStart, $endDate);
            })
            ->sort(function ($left, $right) use ($inscriptionDate) {
                $leftArchived = (int) ($left->Isarchived ?? 0);
                $rightArchived = (int) ($right->Isarchived ?? 0);

                if ($leftArchived !== $rightArchived) {
                    return $leftArchived <=> $rightArchived;
                }

                $leftDistance = abs($inscriptionDate->diffInSeconds(Carbon::parse($left->Startdate), false));
                $rightDistance = abs($inscriptionDate->diffInSeconds(Carbon::parse($right->Startdate), false));

                if ($leftDistance !== $rightDistance) {
                    return $leftDistance <=> $rightDistance;
                }

                return Carbon::parse($right->Startdate)->timestamp <=> Carbon::parse($left->Startdate)->timestamp;
            })
            ->first();

        return $matchedPlanning->PlanningID ?? null;
    }

    private function resolveOriginalStoredAiCommentsForChild(int $childId): array
    {
        $medicalForm = DB::table('Medicalform')
            ->join('Payment', 'Medicalform.InscriptionID', '=', 'Payment.InscriptionID')
            ->leftJoin('Dietarycomment', 'Medicalform.DietarycommentID', '=', 'Dietarycomment.DietarycommentID')
            ->leftJoin('Healthcomment', 'Medicalform.HealthcommentID', '=', 'Healthcomment.HealthcommentID')
            ->where('Payment.ChildID', $childId)
            ->orderBy('Medicalform.MedicalformID')
            ->select(
                'Dietarycomment.Dietarycomment as dietary_comment',
                'Healthcomment.Healthcomment as health_comment'
            )
            ->first();

        if ($medicalForm) {
            $dietaryComment = is_string($medicalForm->dietary_comment) ? trim($medicalForm->dietary_comment) : '';
            $healthComment = is_string($medicalForm->health_comment) ? trim($medicalForm->health_comment) : '';

            if ($dietaryComment !== '' || $healthComment !== '') {
                return [$dietaryComment !== '' ? $dietaryComment : null, $healthComment !== '' ? $healthComment : null];
            }
        }

        return [null, null];
    }

    private function buildMealRestrictionContext(?string $dietaryComment, ?string $healthComment): ?string
    {
        $parts = [];

        $dietary = $this->normalizeMealRelevantComment($dietaryComment);
        if ($dietary !== '') {
            $parts[] = 'Résumé alimentaire: ' . $dietary;
        }

        $health = $this->normalizeMealRelevantComment($healthComment);
        if ($health !== '') {
            $parts[] = 'Notes de santé pouvant affecter les repas: ' . $health;
        }

        return $parts === [] ? null : implode("\n", $parts);
    }

    private function normalizeMealRelevantComment(?string $text): string
    {
        $text = trim((string) $text);
        if ($text === '') {
            return '';
        }

        $lower = mb_strtolower($text, 'UTF-8');
        if (
            str_starts_with($text, '✅') ||
            str_contains($lower, 'aucune restriction alimentaire détectée') ||
            str_contains($lower, 'aucun problème de santé notable détecté')
        ) {
            return '';
        }

        return $text;
    }

    /**
     * Proxy a request to the local custom AI API.
     *
     * Accepts `prompt` or `user_prompt`, plus optional `system_prompt` and `model`.
     */
    public function customApi(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'prompt' => 'nullable|string',
            'user_prompt' => 'nullable|string',
            'system_prompt' => 'nullable|string',
            'model' => 'nullable|string|max:100',
        ]);

        $userPrompt = trim((string) ($validated['user_prompt'] ?? $validated['prompt'] ?? ''));
        if ($userPrompt === '') {
            return response()->json([
                'success' => false,
                'message' => 'A prompt is required.',
            ], 422);
        }

        $messages = [];
        $systemPrompt = trim((string) ($validated['system_prompt'] ?? ''));
        if ($systemPrompt !== '') {
            $messages[] = [
                'role' => 'system',
                'content' => $systemPrompt,
            ];
        }

        $messages[] = [
            'role' => 'user',
            'content' => $userPrompt,
        ];

        $copilotUrl = rtrim((string) config('services.copilot.url', 'http://localhost:4141'), '/') . '/v1/chat/completions';

        try {
            $response = Http::timeout(60)
                ->acceptJson()
                ->post($copilotUrl, [
                    'model' => $validated['model'] ?? 'gpt-4o-mini',
                    'messages' => $messages,
                ]);

            if ($response->failed()) {
                $raw = $response->json();

                return response()->json([
                    'success' => false,
                    'message' => data_get($raw, 'error.message')
                        ?? data_get($raw, 'error')
                        ?? ('Custom AI request failed with status ' . $response->status() . '.'),
                    'status' => $response->status(),
                    'raw' => $raw,
                ], $response->status());
            }

            $raw = $response->json();

            return response()->json([
                'success' => true,
                'answer' => trim((string) data_get($raw, 'choices.0.message.content', '')),
                'model' => data_get($raw, 'model', $validated['model'] ?? 'gpt-4o-mini'),
                'usage' => data_get($raw, 'usage'),
                'raw' => $raw,
            ]);
        } catch (\Throwable $e) {
            return response()->json([
                'success' => false,
                'message' => 'Could not connect to custom AI API: ' . $e->getMessage(),
            ], 500);
        }
    }

    private function callCopilotProxy(string $prompt): string
    {
        $copilotUrl = rtrim((string) config('services.copilot.url', 'http://localhost:4141'), '/') . '/v1/chat/completions';

        $response = Http::timeout(60)
            ->acceptJson()
            ->post($copilotUrl, [
                'model' => 'gpt-4o-mini',
                'messages' => [
                    [
                        'role' => 'user',
                        'content' => $prompt,
                    ],
                ],
            ]);

        if ($response->failed()) {
            throw new RuntimeException('Could not connect to the AI server.');
        }

        $data = $response->json();
        $content = trim((string) data_get($data, 'choices.0.message.content', ''));

        if ($content === '') {
            throw new RuntimeException('AI returned an empty response.');
        }

        return $content;
    }

    private function isAiEnabled(): bool
    {
        $value = DB::table('Parameter')
            ->where('Name', 'ai_enabled')
            ->value('Value');

        return in_array(strtolower((string) $value), ['true', '1'], true);
    }
}
