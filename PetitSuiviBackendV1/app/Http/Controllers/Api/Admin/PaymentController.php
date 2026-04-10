<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PaymentController extends Controller
{
    /**
     * List All Payment Records
     *
     * Retrieves every Payment row with its associated Inscription, Child,
     * Class, inscription status, payment method, meal plan, and nested
     * partial payments. The frontend joins this data with /admin/inscriptions
     * to build the master payments ledger DataGrid.
     *
     * Each row is enriched server-side with:
     * - child_full_name, inscription_date, amount
     * - inscription_status { id, name } (from InscriptionStatusInscription pivot)
     * - payment_status { id, name } (dynamically computed from partial sums)
     * - payment_method (resolved from Inscription.PaymentmethodID)
     * - base_fee, meal_plan_fee, meal_plan (from Inscription + Mealplan)
     * - frais_inscription_amount, frais_inscription_snapshot (from Inscription)
     * - class { name, year } (from ChildClass → Class)
     * - partial_payments[] (from Partialpayment table)
     *
     * @group Admin - Payments
     * @authenticated
     *
     * @response 200 {
     *   "success": true,
     *   "data": [
     *     {
     *       "inscription_id": 101,
     *       "child_id": 45,
     *       "child_full_name": "Youssef Mejri",
     *       "inscription_date": "2025-08-15",
     *       "amount": 1200,
     *       "payment_method": "monthlyPartial",
     *       "base_fee": 1000,
     *       "meal_plan_fee": 200,
     *       "meal_plan": "Oui",
     *       "frais_inscription_amount": 150,
     *       "frais_inscription_snapshot": 150,
     *       "inscription_status": { "id": 2, "name": "approved" },
     *       "payment_status": { "id": 1, "name": "pending" },
     *       "class": { "name": "Moyenne Section B", "year": 2025 },
     *       "partial_payments": [
     *         { "id": 300, "value": 400, "date": "2025-10-01", "target_month": "2025-09" }
     *       ]
     *     }
     *   ]
     * }
     */
    public function index(Request $request): JsonResponse
    {
        // ── 1. Fetch all Payment rows joined with Child and Inscription ──
        $payments = DB::table('Payment')
            ->leftJoin('Child', 'Payment.ChildID', '=', 'Child.ChildID')
            ->leftJoin('Inscription', 'Payment.InscriptionID', '=', 'Inscription.InscriptionID')
            ->select(
                'Payment.PaymentID',
                'Payment.Amount',
                'Payment.Date as payment_date',
                'Payment.InscriptionID',
                'Payment.ChildID',
                'Child.Firstname as child_firstname',
                'Child.Lastname as child_lastname',
                 'Inscription.Date as inscription_date',
                 'Inscription.PaymentmethodID',
                'Inscription.Totalamount',
                'Inscription.Basefee',
                'Inscription.Mealplanfee',
                'Inscription.Fraisinscriptionsnapshot',
                'Inscription.Inscriptionfeespaymentamount',
                'Inscription.MealplanID',
                'Inscription.InscriptionstatusID',
                'Inscription.Isarchived as inscription_archived'
            )
            ->orderByDesc('Payment.PaymentID')
            ->get();

        // ── 2. Pre-fetch lookup tables ──
        // Inscription status map
        $statusMap = DB::table('Inscriptionstatus')->pluck('Name', 'InscriptionstatusID');

        // Meal plans
        $mealPlans = DB::table('Mealplan')->pluck('Name', 'MealplanID');

        // Payment methods
        $paymentMethods = DB::table('Paymentmethod')->pluck('Name', 'PaymentmethodID');

        // Child → Class assignments
        $childClassMap = DB::table('ChildClass')
            ->join('Class', 'ChildClass.ClassID', '=', 'Class.ClassID')
            ->leftJoin('Planning', 'Class.PlanningID', '=', 'Planning.PlanningID')
            ->select(
                'ChildClass.ChildID',
                'Class.Name as class_name',
                'Class.Year as class_year',
                'Class.PlanningID as planning_id',
                'Planning.Startdate as planning_start',
                'Planning.Enddate as planning_end',
                'Planning.Isarchived as planning_archived'
            )
            ->orderByDesc('Class.Year')
            ->orderByDesc('Class.ClassID')
            ->get()
            ->groupBy('ChildID');

        // All partial payments grouped by PaymentID
        $partials = DB::table('Partialpayment')
            ->select('PartialpaymentID', 'PaymentID', 'Value', 'Date', 'Targetmonth')
            ->orderBy('Date')
            ->get()
            ->groupBy('PaymentID');

        // ── 3. Map each payment row into the frontend-expected shape ──
        $result = $payments->map(function ($p) use ($statusMap, $mealPlans, $paymentMethods, $childClassMap, $partials) {
            $inscId   = $p->InscriptionID;
            $childId  = $p->ChildID;
            $payId    = $p->PaymentID;

            // Child full name
            $childFullName = trim(($p->child_firstname ?? '') . ' ' . ($p->child_lastname ?? ''));

            // Inscription status from Inscription
            $statusId    = $p->InscriptionstatusID ?? null;
            $statusName  = $statusId ? ($statusMap[$statusId] ?? 'pending') : 'pending';

            // Meal plan name
            $mealPlanName = ($p->MealplanID && isset($mealPlans[$p->MealplanID]))
                ? $mealPlans[$p->MealplanID]
                : null;

            $paymentMethod = ($p->PaymentmethodID && isset($paymentMethods[$p->PaymentmethodID]))
                ? $paymentMethods[$p->PaymentmethodID]
                : null;

            // Class info via ChildClass pivot
            $classInfo = null;
            if ($childId && $childClassMap->has($childId)) {
                $childClasses = $childClassMap->get($childId);
                $inscriptionDate = $p->inscription_date ? strtotime($p->inscription_date) : null;
                $isArchivedInscription = (bool) ($p->inscription_archived ?? false);

                $classRow = $childClasses->first(function ($row) use ($inscriptionDate, $isArchivedInscription) {
                    $planningArchived = (bool) ($row->planning_archived ?? false);
                    if ($planningArchived !== $isArchivedInscription) {
                        return false;
                    }

                    if (!$inscriptionDate) {
                        return true;
                    }

                    $start = !empty($row->planning_start) ? strtotime($row->planning_start) : null;
                    $end = !empty($row->planning_end) ? strtotime($row->planning_end) : null;

                    return $start && $end && $inscriptionDate >= $start && $inscriptionDate <= $end;
                });

                if (!$classRow) {
                    $classRow = $childClasses->first(function ($row) use ($isArchivedInscription) {
                        return (bool) ($row->planning_archived ?? false) === $isArchivedInscription;
                    });
                }

                if (!$classRow) {
                    $classRow = $childClasses->first();
                }

                $classInfo = [
                    'name' => $classRow->class_name,
                    'year' => (int) $classRow->class_year,
                    'planning_id' => $classRow->planning_id,
                    'planning_start' => $classRow->planning_start,
                    'planning_end' => $classRow->planning_end,
                ];
            }

            // Partial payments as flat array
            $ppList = $partials->get($payId, collect())->map(function ($pp) {
                return [
                    'id'           => $pp->PartialpaymentID,
                    'value'        => (float) $pp->Value,
                    'date'         => $pp->Date,
                    'target_month' => $pp->Targetmonth,
                ];
            })->values()->toArray();

            // Dynamic payment status based on partials vs total
            $totalAmount  = (float) ($p->Amount ?? $p->Totalamount ?? 0);
            $partialPaid  = array_sum(array_column($ppList, 'value'));
            $paymentStatusName = 'pending';
            if ($totalAmount > 0 && $partialPaid >= $totalAmount) {
                $paymentStatusName = 'paid';
            } elseif ($partialPaid > 0) {
                $paymentStatusName = 'partial';
            }

            return [
                'inscription_id'              => $inscId,
                'child_id'                    => $childId,
                'child_full_name'             => $childFullName ?: null,
                'inscription_date'            => $p->inscription_date,
                'amount'                      => $totalAmount,
                'payment_method'              => $paymentMethod,
                'base_fee'                    => (float) ($p->Basefee ?? 0),
                'meal_plan_fee'               => (float) ($p->Mealplanfee ?? 0),
                'meal_plan'                   => $mealPlanName,
                'frais_inscription_amount'    => $p->Inscriptionfeespaymentamount !== null ? (float) $p->Inscriptionfeespaymentamount : null,
                'frais_inscription_snapshot'  => $p->Fraisinscriptionsnapshot !== null ? (float) $p->Fraisinscriptionsnapshot : null,
                'inscription_status'          => ['id' => $statusId, 'name' => $statusName],
                'payment_status'              => ['name' => $paymentStatusName],
                'class'                       => $classInfo,
                'partial_payments'            => $ppList,
            ];
        })->values();

        return response()->json([
            'success' => true,
            'data'    => $result,
        ]);
    }

    /**
     * Create a Payment Record
     *
     * Generates a new main Payment entry. Typically called automatically
     * when an inscription is approved, but can be triggered manually.
     *
     * @group Admin - Payments
     * @authenticated
     *
     * @bodyParam InscriptionID integer required The inscription ID. Example: 101
     * @bodyParam ChildID integer required The child ID. Example: 45
     * @bodyParam Amount numeric required Total amount due. Example: 1200
     * @bodyParam Date string required Payment creation date (YYYY-MM-DD). Example: 2025-09-15
     *
     * @response 201 {
     *   "success": true,
     *   "message": "Payment recorded.",
     *   "data": { "PaymentID": 251 }
     * }
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'InscriptionID' => 'required|integer|exists:Inscription,InscriptionID',
            'ChildID'       => 'required|integer|exists:Child,ChildID',
            'Amount'        => 'required|numeric|min:0',
            'Date'          => 'required|date',
        ]);

        $id = DB::table('Payment')->insertGetId([
            'InscriptionID' => $validated['InscriptionID'],
            'ChildID'       => $validated['ChildID'],
            'Amount'        => $validated['Amount'],
            'Date'          => $validated['Date'],
        ], 'PaymentID');

        return response()->json([
            'success' => true,
            'message' => 'Payment recorded.',
            'data'    => ['PaymentID' => $id],
        ], 201);
    }

    /**
     * Show Payment Details
     *
     * Retrieves full details for a single payment including all nested
     * partial payments.
     *
     * @group Admin - Payments
     * @authenticated
     *
     * @urlParam id integer required The PaymentID. Example: 250
     *
     * @response 200 {
     *   "success": true,
     *   "data": {
     *     "PaymentID": 250,
     *     "Amount": 1200,
     *     "Date": "2025-09-15",
     *     "InscriptionID": 101,
     *     "ChildID": 45,
     *     "partial_payments": []
     *   }
     * }
     */
    public function show(int $id): JsonResponse
    {
        $payment = DB::table('Payment')->where('PaymentID', $id)->first();

        if (!$payment) {
            return response()->json(['success' => false, 'message' => 'Payment not found.'], 404);
        }

        $partials = DB::table('Partialpayment')
            ->where('PaymentID', $id)
            ->orderBy('Date')
            ->get()
            ->map(fn($pp) => [
                'id'           => $pp->PartialpaymentID,
                'value'        => (float) $pp->Value,
                'date'         => $pp->Date,
                'target_month' => $pp->Targetmonth,
            ]);

        return response()->json([
            'success' => true,
            'data'    => [
                'PaymentID'        => $payment->PaymentID,
                'Amount'           => (float) $payment->Amount,
                'Date'             => $payment->Date,
                'InscriptionID'    => $payment->InscriptionID,
                'ChildID'          => $payment->ChildID,
                'partial_payments' => $partials,
            ],
        ]);
    }

    /**
     * Update a Payment Record
     *
     * Updates the total amount on a Payment record (e.g. after fee correction).
     *
     * @group Admin - Payments
     * @authenticated
     *
     * @urlParam id integer required The PaymentID. Example: 250
     * @bodyParam Amount numeric The corrected total amount. Example: 1400
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Payment updated.",
     *   "data": { "PaymentID": 250, "Amount": 1400 }
     * }
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $payment = DB::table('Payment')->where('PaymentID', $id)->first();

        if (!$payment) {
            return response()->json(['success' => false, 'message' => 'Payment not found.'], 404);
        }

        $validated = $request->validate([
            'Amount' => 'sometimes|numeric|min:0',
        ]);

        DB::table('Payment')->where('PaymentID', $id)->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Payment updated.',
            'data'    => ['PaymentID' => $id, 'Amount' => (float) ($validated['Amount'] ?? $payment->Amount)],
        ]);
    }
}
