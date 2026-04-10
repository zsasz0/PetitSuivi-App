<?php

namespace App\Http\Controllers\Api\Mobile\Parent;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/**
 * @group Mobile - Parent Payments
 *
 * APIs for retrieving payment and inscription history for the authenticated parent.
 */
class ParentPaymentsController extends Controller
{
    /**
     * List Payment History
     *
     * Retrieves all payment records for the parent's children, including partial payments,
     * class assignments, meal plans, and inscription status.
     *
     * @authenticated
     * @urlParam cin string required The parent's CIN. Example: 12345678
     *
     * @response 200 {
     *   "success": true,
     *   "data": [
     *     {
     *       "inscription_id": 101,
     *       "child_id": 45,
     *       "child_full_name": "Youssef Mejri",
     *       "amount": 1550.00,
     *       "payment_method": "monthlyPartial",
     *       "meal_plan": "Mon enfant prend le déjeuner et le goûter",
     *       "inscription_date": "2025-08-15",
     *       "frais_inscription_amount": 150,
     *       "inscription_status": { "name": "approved" },
     *       "class": { "name": "Moyenne Section B", "year": 2025 },
     *       "partial_payments": [
     *         { "value": 400, "date": "2025-10-01" }
     *       ]
     *     }
     *   ]
     * }
     */
    public function index($cin): JsonResponse
    {
        $account = DB::table('Account')
            ->where('Cin', $cin)
            ->where('RoleID', 3)
            ->first();

        if (!$account) {
            return response()->json(['success' => false, 'message' => 'Parent not found.'], 404);
        }

        $parent = DB::table('Parent')
            ->where('ParentID', $account->PersonID)
            ->first();

        if (!$parent) {
            return response()->json(['success' => true, 'data' => []]);
        }

        $children = DB::table('Child')
            ->where('ParentID', $parent->ParentID)
            ->get();

        $childIds = $children->pluck('ChildID')->toArray();

        if (empty($childIds)) {
            return response()->json(['success' => true, 'data' => []]);
        }

        // Fetch all payments for these children
        $payments = DB::table('Payment')
            ->whereIn('ChildID', $childIds)
            ->get();

        $paymentMethods = DB::table('Paymentmethod')
            ->pluck('Name', 'PaymentmethodID');

        $childClassMap = DB::table('ChildClass')
            ->join('Class', 'ChildClass.ClassID', '=', 'Class.ClassID')
            ->leftJoin('Planning', 'Class.PlanningID', '=', 'Planning.PlanningID')
            ->select(
                'ChildClass.ChildID',
                'Class.Name as class_name',
                'Class.Year as class_year',
                'Class.PlanningID as planning_id',
                'Class.Isarchived as class_archived',
                'Planning.Startdate as planning_start',
                'Planning.Enddate as planning_end',
                'Planning.Isarchived as planning_archived'
            )
            ->orderByDesc('Class.Year')
            ->orderByDesc('Class.ClassID')
            ->get()
            ->groupBy('ChildID');

        $data = $payments->map(function ($payment) use ($children, $paymentMethods, $childClassMap) {
            $child = $children->firstWhere('ChildID', $payment->ChildID);
            $childName = $child
                ? trim($child->Firstname . ' ' . $child->Lastname)
                : 'Enfant';

            // Fetch inscription details
            $inscription = $payment->InscriptionID
                ? DB::table('Inscription')->where('InscriptionID', $payment->InscriptionID)->first()
                : null;

            // Resolve inscription status
            $inscStatus = null;
            if ($inscription && $inscription->InscriptionstatusID) {
                $status = DB::table('Inscriptionstatus')
                    ->where('InscriptionstatusID', $inscription->InscriptionstatusID)
                    ->first();
                $inscStatus = $status ? ['name' => strtolower($status->Name)] : null;
            }

            $classInfo = null;
            $childClass = null;
            if ($childClassMap->has($payment->ChildID)) {
                $childClasses = $childClassMap->get($payment->ChildID);
                $inscriptionDate = $inscription && $inscription->Date ? strtotime($inscription->Date) : null;
                $isArchivedInscription = (bool) ($inscription->Isarchived ?? false);

                $childClass = $childClasses->first(function ($row) use ($inscriptionDate, $isArchivedInscription) {
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

                if (!$childClass) {
                    $childClass = $childClasses->first(function ($row) use ($isArchivedInscription) {
                        return (bool) ($row->planning_archived ?? false) === $isArchivedInscription;
                    });
                }

                if (!$childClass) {
                    $childClass = $childClasses->first();
                }
            }

            if ($childClass) {
                $classInfo = [
                    'name' => $childClass->class_name,
                    'year' => (int) $childClass->class_year,
                ];
            }

            // Resolve meal plan
            $mealPlanName = null;
            if ($inscription && $inscription->MealplanID) {
                $mealPlan = DB::table('Mealplan')
                    ->where('MealplanID', $inscription->MealplanID)
                    ->first();
                $mealPlanName = $mealPlan ? $mealPlan->Name : null;
            }

            $paymentMethod = null;
            if ($inscription && $inscription->PaymentmethodID) {
                $paymentMethod = $paymentMethods->get($inscription->PaymentmethodID);
            }

            // Fetch partial payments
            $partials = DB::table('Partialpayment')
                ->where('PaymentID', $payment->PaymentID)
                ->get()
                ->map(fn($pp) => [
                    'id'    => $pp->PartialpaymentID,
                    'value' => (float) $pp->Value,
                    'date'  => $pp->Date,
                ]);

            return [
                'inscription_id'          => $inscription ? $inscription->InscriptionID : null,
                'child_id'                => $payment->ChildID,
                'child_full_name'         => $childName,
                'amount'                  => (float) $payment->Amount,
                'payment_method'          => $paymentMethod,
                'meal_plan'               => $mealPlanName,
                'inscription_date'        => $inscription ? $inscription->Date : null,
                'frais_inscription_amount' => $inscription ? $inscription->Inscriptionfeespaymentamount : null,
                'inscription_status'      => $inscStatus,
                'class'                   => $classInfo,
                'partial_payments'        => $partials,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }
}
