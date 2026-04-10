<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class PaymentReportController extends Controller
{
    private function getPlanningMonths(string $startDate, string $endDate): array
    {
        $start = Carbon::parse($startDate)->startOfMonth();
        $end = Carbon::parse($endDate)->startOfMonth();
        $months = [];

        while ($start->lte($end)) {
            $months[] = $start->format('Y-m');
            $start->addMonth();
        }

        return $months;
    }

    private function resolvePaymentForPlanning(int $childId, object $planning): ?object
    {
        $payments = DB::table('Payment')
            ->join('Inscription', 'Payment.InscriptionID', '=', 'Inscription.InscriptionID')
            ->where('Payment.ChildID', $childId)
            ->select(
                'Payment.PaymentID',
                'Payment.Amount as expected_amount',
                'Inscription.PaymentmethodID',
                'Inscription.Date as inscription_date',
                'Inscription.InscriptionID',
                'Inscription.Isarchived as inscription_archived'
            )
            ->orderByDesc('Inscription.Date')
            ->orderByDesc('Inscription.InscriptionID')
            ->get();

        if ($payments->isEmpty()) {
            return null;
        }

        $planningStart = !empty($planning->Startdate) ? Carbon::parse($planning->Startdate)->startOfDay() : null;
        $planningEnd = !empty($planning->Enddate) ? Carbon::parse($planning->Enddate)->endOfDay() : null;
        $isArchivedPlanning = (bool) ($planning->Isarchived ?? false);

        $dateMatched = $payments->first(function ($payment) use ($planningStart, $planningEnd) {
            if (!$planningStart || !$planningEnd || empty($payment->inscription_date)) {
                return false;
            }

            $inscriptionDate = Carbon::parse($payment->inscription_date);
            return $inscriptionDate->betweenIncluded($planningStart, $planningEnd);
        });

        if ($dateMatched) {
            return $dateMatched;
        }

        $archiveMatched = $payments->first(function ($payment) use ($isArchivedPlanning) {
            return (bool) ($payment->inscription_archived ?? false) === $isArchivedPlanning;
        });

        return $archiveMatched ?: $payments->first();
    }

    /**
     * Generate a comprehensive financial report for a specific planning year.
     * Includes revenue summaries and monthly trends.
     *
     * @group Admin - Payment Reports
     * @authenticated
     *
     * @param int $planningId
     * @return JsonResponse
     */
    public function getPaymentReport(int $planningId): JsonResponse
    {
        $planning = DB::table('Planning')->where('PlanningID', $planningId)->first();
        if (!$planning) {
            return response()->json(['success' => false, 'message' => 'Planning not found'], 404);
        }

        $classes = DB::table('Class')->where('PlanningID', $planningId)->get();
        if ($classes->isEmpty()) {
            return response()->json([
                'success' => true,
                'summary' => [
                    'total_expected' => 0,
                    'total_paid' => 0,
                    'total_pending' => 0,
                    'count_paid' => 0,
                    'count_partial' => 0,
                    'count_pending' => 0,
                ],
                'monthly_status_data' => []
            ]);
        }

        $globalExpected = 0;
        $globalPaid = 0;
        $globalCountPaid = 0;
        $globalCountPartial = 0;
        $globalCountPending = 0;

        $startDate = $planning->Startdate ?? date('Y-09-01');
        $endDate = $planning->Enddate ?? date('Y-06-30', strtotime('+1 year'));
        $planningMonths = $this->getPlanningMonths($startDate, $endDate);
        $monthlyStatusData = [];

        foreach ($planningMonths as $monthKey) {
            $monthlyStatusData[$monthKey] = ['month' => $monthKey, 'paid' => 0, 'partial' => 0, 'pending' => 0];
        }

        $paymentMethodMap = DB::table('Paymentmethod')->pluck('Name', 'PaymentmethodID');

        foreach ($classes as $cls) {
            $childIds = DB::table('ChildClass')->where('ClassID', $cls->ClassID)->pluck('ChildID');

            if ($childIds->isEmpty()) {
                continue;
            }

            foreach ($childIds as $childId) {
                // Find payment for this child in this class (using active inscription)
                $payment = $this->resolvePaymentForPlanning($childId, $planning);

                if (!$payment) {
                    continue;
                }

                $expectedAmount = (float) $payment->expected_amount;
                $paymentMethod = $paymentMethodMap[$payment->PaymentmethodID] ?? '';

                $partials = DB::table('Partialpayment')->where('PaymentID', $payment->PaymentID)->get();

                $paidAmount = 0;
                $childMonthPayments = [];
                foreach ($partials as $pp) {
                    $paidAmount += (float) $pp->Value;
                    if (!empty($pp->Targetmonth)) {
                        $targetMonthInt = (int) $pp->Targetmonth;
                        if (!isset($childMonthPayments[$targetMonthInt])) {
                            $childMonthPayments[$targetMonthInt] = 0;
                        }
                        $childMonthPayments[$targetMonthInt] += (float) $pp->Value;
                    }
                }

                if ($expectedAmount > 0 && $paidAmount >= $expectedAmount) {
                    $globalCountPaid++;
                } elseif ($paidAmount > 0) {
                    $globalCountPartial++;
                } else {
                    $globalCountPending++;
                }

                $globalExpected += $expectedAmount;
                $globalPaid += $paidAmount;

                // Only distribute partial monthly status for non-oneShot payments
                if (strtolower($paymentMethod) !== 'oneshot' && strtolower($paymentMethod) !== 'one_shot') {
                    $numberOfMonths = count($planningMonths);
                    $expectedMonthlyAmount = $numberOfMonths > 0 ? $expectedAmount / $numberOfMonths : 0;

                    foreach ($planningMonths as $monthKey) {
                        $parts = explode('-', $monthKey);
                        $mInt = isset($parts[1]) ? (int) $parts[1] : 0;
                        $paidForMonth = $childMonthPayments[$mInt] ?? 0;
                        
                        if ($paidForMonth >= $expectedMonthlyAmount && $expectedMonthlyAmount > 0) {
                            $monthlyStatusData[$monthKey]['paid']++;
                        } elseif ($paidForMonth > 0) {
                            $monthlyStatusData[$monthKey]['partial']++;
                        } else {
                            $monthlyStatusData[$monthKey]['pending']++;
                        }
                    }
                }
            }
        }

        return response()->json([
            'success' => true,
            'summary' => [
                'total_expected' => $globalExpected,
                'total_paid' => $globalPaid,
                'total_pending' => max(0, $globalExpected - $globalPaid),
                'count_paid' => $globalCountPaid,
                'count_partial' => $globalCountPartial,
                'count_pending' => $globalCountPending,
            ],
            'monthly_status_data' => array_values($monthlyStatusData),
        ]);
    }

    /**
     * Get detailed payment information for a specific month.
     * Returns lists of parents who paid fully, partially, or not at all for that month.
     *
     * @group Admin - Payment Reports
     * @authenticated
     *
     * @param int $planningId
     * @param string $month Format: YYYY-MM (e.g., "2025-09")
     * @return JsonResponse
     */
    public function getMonthlyPaymentReport(int $planningId, string $month): JsonResponse
    {
        if (!preg_match('/^\d{4}-(0[1-9]|1[0-2])$/', $month)) {
            return response()->json(['success' => false, 'message' => 'Invalid month format'], 400);
        }

        $planning = DB::table('Planning')->where('PlanningID', $planningId)->first();
        if (!$planning) {
            return response()->json(['success' => false, 'message' => 'Planning not found'], 404);
        }

        $planningMonths = $this->getPlanningMonths(
            $planning->Startdate ?? date('Y-09-01'),
            $planning->Enddate ?? date('Y-06-30', strtotime('+1 year'))
        );

        if (!in_array($month, $planningMonths, true)) {
            return response()->json(['success' => false, 'message' => 'Month is outside planning range'], 400);
        }

        $numberOfMonths = count($planningMonths);

        $classIds = DB::table('Class')->where('PlanningID', $planningId)->pluck('ClassID');
        $childIds = DB::table('ChildClass')->whereIn('ClassID', $classIds)->pluck('ChildID')->unique();
        $paymentMethodMap = DB::table('Paymentmethod')->pluck('Name', 'PaymentmethodID');

        $paidFully = [];
        $paidPartially = [];
        $notPaid = [];

        foreach ($childIds as $childId) {
            $child = DB::table('Child')->where('ChildID', $childId)->first();
            if (!$child) continue;

            $parent = DB::table('Account')->where('PersonID', $child->ParentID)->where('RoleID', 3)->first();

            $payment = $this->resolvePaymentForPlanning($childId, $planning);

            if (!$payment) continue;

            $paymentMethod = strtolower($paymentMethodMap[$payment->PaymentmethodID] ?? '');
            if ($paymentMethod === 'oneshot' || $paymentMethod === 'one_shot') continue;

            $expectedAmount = (float) $payment->expected_amount;
            $expectedMonthlyAmount = $numberOfMonths > 0 ? $expectedAmount / $numberOfMonths : 0;

            $parts = explode('-', $month);
            $targetMonthInt = isset($parts[1]) ? (int) $parts[1] : 0;

            $monthPayments = DB::table('Partialpayment')
                ->where('PaymentID', $payment->PaymentID)
                ->where('Targetmonth', $targetMonthInt)
                ->get();

            $paidForMonth = $monthPayments->sum('Value');

            $childData = [
                'child_id' => $child->ChildID,
                'child_name' => trim($child->Firstname . ' ' . $child->Lastname),
                'parent_name' => $parent ? trim($parent->Firstname . ' ' . $parent->Lastname) : null,
                'parent_phone' => $parent->Phone ?? null,
                'expected_monthly' => round($expectedMonthlyAmount, 2),
                'paid_amount' => round($paidForMonth, 2),
            ];

            if ($paidForMonth >= $expectedMonthlyAmount && $expectedMonthlyAmount > 0) {
                $paidFully[] = $childData;
            } elseif ($paidForMonth > 0) {
                $paidPartially[] = $childData;
            } else {
                $notPaid[] = $childData;
            }
        }

        return response()->json([
            'success' => true,
            'summary' => [
                'paid_fully_count' => count($paidFully),
                'paid_partially_count' => count($paidPartially),
                'not_paid_count' => count($notPaid),
            ],
            'paid_fully' => $paidFully,
            'paid_partially' => $paidPartially,
            'not_paid' => $notPaid,
        ]);
    }
}
