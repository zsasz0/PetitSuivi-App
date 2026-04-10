<?php

namespace App\Http\Controllers\Api\Mobile\Parent;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/**
 * @group Mobile - Parent Children
 *
 * APIs for listing, registering, and re-registering children for the authenticated parent.
 */
class ParentChildrenController extends Controller
{
    private function normalizeLookupName(?string $value): string
    {
        $normalized = mb_strtolower(trim((string) $value), 'UTF-8');
        $normalized = str_replace(["’", "`", "'"], ' ', $normalized);
        $normalized = strtr($normalized, [
            'à' => 'a', 'â' => 'a', 'ä' => 'a',
            'é' => 'e', 'è' => 'e', 'ê' => 'e', 'ë' => 'e',
            'î' => 'i', 'ï' => 'i',
            'ô' => 'o', 'ö' => 'o',
            'ù' => 'u', 'û' => 'u', 'ü' => 'u',
            'ç' => 'c', 'œ' => 'oe',
        ]);

        return preg_replace('/\s+/u', ' ', $normalized);
    }

    private function lookupCandidates(string $table, string $name): array
    {
        $normalized = $this->normalizeLookupName($name);
        $candidates = [$normalized];

        if ($table === 'Inscriptiontype') {
            if (str_contains($normalized, 'prescolaire')) {
                $candidates[] = 'preschool';
            }
            if (str_contains($normalized, 'maternelle')) {
                $candidates[] = 'kindergarten';
            }
        }

        return array_values(array_unique($candidates));
    }

    private function firstByName(string $table, string $name, array $columns = ['*']): ?object
    {
        $targets = $this->lookupCandidates($table, $name);

        return DB::table($table)
            ->get($columns)
            ->first(fn ($row) => in_array($this->normalizeLookupName($row->Name ?? null), $targets, true));
    }

    private function parameterValueByName(string $name, float $default = 0): float
    {
        $parameter = $this->firstByName('Parameter', $name, ['Name', 'Value']);

        return $parameter && is_numeric($parameter->Value)
            ? (float) $parameter->Value
            : $default;
    }

    /**
     * List Parent's Children
     *
     * Retrieves all children linked to the parent, with their inscriptions, classes, and statuses.
     *
     * @authenticated
     * @urlParam cin string required The parent's CIN. Example: 12345678
     *
     * @response 200 {
     *   "success": true,
     *   "data": [
     *     {
     *       "id": 45,
     *       "firstName": "Youssef",
     *       "lastName": "Mejri",
     *       "birthdate": "2020-05-15",
     *       "inscriptions": [],
     *       "classes": []
     *     }
     *   ]
     * }
     */
    public function index($cin): JsonResponse
    {
        // ParentID in the Parent table matches the Account CIN directly
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

        // Parent table has ParentID which equals the PersonID, NOT CIN
        $parent = DB::table('Parent')
            ->where('ParentID', $account->PersonID)
            ->first();

        if (!$parent) {
            return response()->json([
                'success' => true,
                'data' => [],
            ]);
        }

        $children = DB::table('Child')
            ->where('ParentID', $parent->ParentID)
            ->get();

        $activePlanning = DB::table('Planning')
            ->where('Isarchived', 0)
            ->orderByDesc('Startdate')
            ->first();

        $paymentMethods = DB::table('Paymentmethod')->pluck('Name', 'PaymentmethodID');

        $data = $children->map(function ($child) use ($paymentMethods, $activePlanning) {
            // Inscription has no ChildID — resolve through Payment table
            $inscriptionIds = DB::table('Payment')
                ->where('ChildID', $child->ChildID)
                ->whereNotNull('InscriptionID')
                ->pluck('InscriptionID')
                ->unique();

            $inscriptions = DB::table('Inscription')
                ->whereIn('InscriptionID', $inscriptionIds)
                ->orderBy('Date')
                ->orderBy('InscriptionID')
                ->get()
                ->map(function ($insc) {
                    // Get latest status from Inscription
                    $statusName = null;
                    if ($insc->InscriptionstatusID) {
                        $status = DB::table('Inscriptionstatus')
                            ->where('InscriptionstatusID', $insc->InscriptionstatusID)
                            ->first();
                        $statusName = $status ? $status->Name : null;
                    }

                    return [
                        'id' => $insc->InscriptionID,
                        'date' => $insc->Date,
                        'total_amount' => $insc->Totalamount,
                        'payment_method' => $paymentMethods[$insc->PaymentmethodID] ?? null,
                        'is_archived' => (bool) ($insc->Isarchived ?? false),
                        'status' => $statusName ? ['name' => strtolower($statusName)] : null,
                    ];
                })
                ->values();

            $hasOnlyArchivedInscriptions = $inscriptions->isNotEmpty()
                && $inscriptions->every(fn ($insc) => !empty($insc['is_archived']));

            if ($activePlanning && $hasOnlyArchivedInscriptions) {
                $inscriptions->push([
                    'id' => null,
                    'date' => $activePlanning->Startdate,
                    'total_amount' => null,
                    'payment_method' => null,
                    'is_archived' => false,
                    'status' => ['name' => 'inscription_requise'],
                ]);
            }

            // Fetch classes via ChildClass pivot
            $classes = DB::table('ChildClass')
                ->join('Class', 'ChildClass.ClassID', '=', 'Class.ClassID')
                ->leftJoin('Planning', 'Class.PlanningID', '=', 'Planning.PlanningID')
                ->where('ChildClass.ChildID', $child->ChildID)
                ->orderByDesc('Class.Year')
                ->orderByDesc('Class.ClassID')
                ->select(
                    'Class.ClassID as id',
                    'Class.Name as name',
                    'Class.Year as year',
                    'Class.PlanningID as planning_id',
                    'Planning.Startdate as planning_start',
                    'Planning.Enddate as planning_end'
                )
                ->get()
                ->map(fn($c) => [
                    'id' => $c->id,
                    'name' => $c->name,
                    'year' => $c->year,
                    'planning_id' => $c->planning_id,
                    'planning_start' => $c->planning_start,
                    'planning_end' => $c->planning_end,
                ]);

            return [
                'id'           => $child->ChildID,
                'firstName'    => $child->Firstname,
                'lastName'     => $child->Lastname,
                'birthdate'    => $child->Birthdate,
                'inscriptions' => $inscriptions,
                'classes'      => $classes,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }

    /**
     * Register New Child
     *
     * Creates a new child and inscription for the parent.
     *
     * @authenticated
     * @urlParam cin string required The parent's CIN. Example: 12345678
     * @bodyParam firstName string required Child's first name. Example: "Sami"
     * @bodyParam lastName string required Child's last name. Example: "Mejri"
     * @bodyParam birthdate string required Child's birth date (YYYY-MM-DD). Example: "2021-03-10"
     * @bodyParam inscription_type string required The inscription type. Example: "Maternelle (التمهيدي)"
     * @bodyParam payment_method string required Payment method. Example: "monthlyPartial"
     * @bodyParam meal_plan string required Meal plan selection. Example: "Mon enfant prend le déjeuner et le goûter"
     * @bodyParam total_amount float required Total computed amount. Example: 1550.00
     *
     * @response 201 {
     *   "success": true,
     *   "message": "Child registered successfully."
     * }
     */
    public function store(Request $request, $cin): JsonResponse
    {
        $validated = $request->validate([
            'firstName'        => 'required|string|max:100',
            'lastName'         => 'required|string|max:100',
            'birthdate'        => 'required|date',
            'inscription_type' => 'required|string',
            'payment_method'   => 'required|string',
            'meal_plan'        => 'required|string',
            'total_amount'     => 'required|numeric|min:0',
        ]);

        $account = DB::table('Account')
            ->where('Cin', $cin)
            ->where('RoleID', 3)
            ->first();

        if (!$account) {
            return response()->json(['success' => false, 'message' => 'Parent not found.'], 404);
        }

        // Parent table has ParentID which equals the PersonID, NOT CIN
        $parent = DB::table('Parent')
            ->where('ParentID', $account->PersonID)
            ->first();

        if (!$parent) {
            return response()->json(['success' => false, 'message' => 'Parent record not found.'], 404);
        }

        return DB::transaction(function () use ($validated, $parent, $request) {
            $requestedDate = $request->input('insc_date', now()->toDateString());
            $inscriptionDate = date('Y-m-d', strtotime($requestedDate));
            $paymentDate = $inscriptionDate > now()->toDateString()
                ? now()->toDateString()
                : $inscriptionDate;

            // Create child
            $childId = DB::table('Child')->insertGetId([
                'Firstname' => $validated['firstName'],
                'Lastname'  => $validated['lastName'],
                'Birthdate' => $validated['birthdate'],
                'ParentID'  => $parent->ParentID,
            ]);

            // Resolve inscription type
            $inscType = $this->firstByName('Inscriptiontype', $validated['inscription_type'], [
                'InscriptiontypeID',
                'Name',
            ]);

            // Resolve meal plan
            $mealPlan = $this->firstByName('Mealplan', $validated['meal_plan'], [
                'MealplanID',
                'Name',
            ]);

            $paymentMethod = $this->firstByName('Paymentmethod', $validated['payment_method'], [
                'PaymentmethodID',
                'Name',
            ]);

            // Get frais inscription from parameters
            $fraisSnapshot = (float) DB::table('Parameter')->where('Name', 'frais_inscription')->value('Value') ?: 0;
            $baseFee = (float) DB::table('Parameter')->where('Name', 'Prix de base')->value('Value') ?: 1200;
            $mealFee = $this->parameterValueByName($validated['meal_plan'], 0);
            $secureTotalAmount = $baseFee + $mealFee;

            // Set initial status to 'pending'
            $pendingStatus = DB::table('Inscriptionstatus')
                ->where('Name', 'pending')
                ->first();

            // Create inscription (Inscription table has NO ChildID — link via Payment)
            $inscriptionId = DB::table('Inscription')->insertGetId([
                'Date'                        => $inscriptionDate,
                'Totalamount'                 => $secureTotalAmount,
                'PaymentmethodID'             => $paymentMethod ? $paymentMethod->PaymentmethodID : null,
                'Basefee'                     => $baseFee,
                'Mealplanfee'                 => $mealFee,
                'Fraisinscriptionsnapshot'    => $fraisSnapshot,
                'Inscriptionfeespaymentamount' => null,
                'Isarchived'                  => 0,
                'TypeID'                      => $inscType ? $inscType->InscriptiontypeID : null,
                'InscriptiontypeID'           => $inscType ? $inscType->InscriptiontypeID : null,
                'MealplanID'                  => $mealPlan ? $mealPlan->MealplanID : null,
                'InscriptionstatusID'         => $pendingStatus ? $pendingStatus->InscriptionstatusID : null,
            ]);

            // Create payment record
            DB::table('Payment')->insert([
                'Amount'        => $secureTotalAmount,
                'Date'          => $paymentDate,
                'InscriptionID' => $inscriptionId,
                'ChildID'       => $childId,
            ]);

            // Handle medical form if present
            $medicalForm = $request->input('medical_form');
            if ($medicalForm && is_array($medicalForm) && !empty($medicalForm)) {
                DB::table('Medicalform')->insert([
                    'Formdata'      => json_encode($medicalForm),
                    'InscriptionID' => $inscriptionId,
                ]);
            }

            return response()->json([
                'success' => true,
                'message' => 'Child registered successfully.',
                'data'    => ['child_id' => $childId, 'inscription_id' => $inscriptionId],
            ], 201);
        });
    }

    /**
     * Re-register Existing Child
     *
     * Creates a new inscription for an existing child for the next academic year.
     *
     * @authenticated
     * @urlParam cin string required The parent's CIN. Example: 12345678
     * @urlParam childId int required The child's ID. Example: 45
     * @bodyParam payment_method string required Payment method. Example: "monthlyPartial"
     * @bodyParam meal_plan string required Meal plan selection. Example: "Mon enfant prend le déjeuner et le goûter"
     * @bodyParam total_amount float required Total computed amount. Example: 1550.00
     *
     * @response 201 {
     *   "success": true,
     *   "message": "Re-registration submitted successfully."
     * }
     */
    public function reRegister(Request $request, $cin, $childId): JsonResponse
    {
        $validated = $request->validate([
            'payment_method' => 'required|string',
            'meal_plan'      => 'required|string',
            'total_amount'   => 'required|numeric|min:0',
        ]);

        // Verify parent owns this child
        $account = DB::table('Account')
            ->where('Cin', $cin)
            ->where('RoleID', 3)
            ->first();

        if (!$account) {
            return response()->json(['success' => false, 'message' => 'Parent not found.'], 404);
        }

        // Parent table has ParentID which equals the PersonID, NOT CIN
        $parent = DB::table('Parent')
            ->where('ParentID', $account->PersonID)
            ->first();

        $child = DB::table('Child')
            ->where('ChildID', $childId)
            ->where('ParentID', $parent ? $parent->ParentID : -1)
            ->first();

        if (!$child) {
            return response()->json(['success' => false, 'message' => 'Child not found or not owned by parent.'], 404);
        }

        return DB::transaction(function () use ($validated, $childId, $request) {
            $requestedDate = $request->input('insc_date', now()->toDateString());
            $inscriptionDate = date('Y-m-d', strtotime($requestedDate));
            $paymentDate = $inscriptionDate > now()->toDateString()
                ? now()->toDateString()
                : $inscriptionDate;

            $latestInscription = DB::table('Payment')
                ->join('Inscription', 'Payment.InscriptionID', '=', 'Inscription.InscriptionID')
                ->where('Payment.ChildID', $childId)
                ->orderByDesc('Inscription.Date')
                ->orderByDesc('Inscription.InscriptionID')
                ->select('Inscription.InscriptiontypeID')
                ->first();

            $mealPlan = $this->firstByName('Mealplan', $validated['meal_plan'], [
                'MealplanID',
                'Name',
            ]);

            $paymentMethod = $this->firstByName('Paymentmethod', $validated['payment_method'], [
                'PaymentmethodID',
                'Name',
            ]);

            $fraisSnapshot = (float) DB::table('Parameter')->where('Name', 'frais_inscription')->value('Value') ?: 0;
            $baseFee = (float) DB::table('Parameter')->where('Name', 'Prix de base')->value('Value') ?: 1200;
            $mealFee = $this->parameterValueByName($validated['meal_plan'], 0);
            $secureTotalAmount = $baseFee + $mealFee;

            $pendingStatus = DB::table('Inscriptionstatus')
                ->where('Name', 'pending')
                ->first();

            // Inscription table has NO ChildID — link via Payment table below
            $inscriptionId = DB::table('Inscription')->insertGetId([
                'Date'                        => $inscriptionDate,
                'Totalamount'                 => $secureTotalAmount,
                'PaymentmethodID'             => $paymentMethod ? $paymentMethod->PaymentmethodID : null,
                'Basefee'                     => $baseFee,
                'Mealplanfee'                 => $mealFee,
                'Fraisinscriptionsnapshot'    => $fraisSnapshot,
                'Inscriptionfeespaymentamount' => null,
                'Isarchived'                  => 0,
                'TypeID'                      => $latestInscription?->InscriptiontypeID,
                'InscriptiontypeID'           => $latestInscription?->InscriptiontypeID,
                'MealplanID'                  => $mealPlan ? $mealPlan->MealplanID : null,
                'InscriptionstatusID'         => $pendingStatus ? $pendingStatus->InscriptionstatusID : null,
            ]);

            DB::table('Payment')->insert([
                'Amount'        => $secureTotalAmount,
                'Date'          => $paymentDate,
                'InscriptionID' => $inscriptionId,
                'ChildID'       => $childId,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Re-registration submitted successfully.',
                'data'    => ['inscription_id' => $inscriptionId],
            ], 201);
        });
    }
}
