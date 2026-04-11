<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PartialPaymentController extends Controller
{
    /**
     * List All Partial Payments
     *
     * Retrieves a global ledger of all partial payment instalments
     * across the entire system, ordered by date descending.
     *
     * @group Admin - Payments
     * @authenticated
     *
     * @response 200 {
     *   "success": true,
     *   "data": [
     *     {
     *       "PartialpaymentID": 300,
     *       "PaymentID": 250,
     *       "Value": 400,
     *       "Date": "2025-10-01",
     *       "Targetmonth": "2025-09"
     *     }
     *   ]
     * }
     */
    public function index(Request $request): JsonResponse
    {
        $partials = DB::table('Partialpayment')
            ->select('PartialpaymentID', 'PaymentID', 'Value', 'Date', 'Targetmonth')
            ->orderByDesc('Date')
            ->get();

        return response()->json([
            'success' => true,
            'data'    => $partials,
        ]);
    }

    /**
     * Record a Payment Instalment (Transaction)
     *
     * Creates a new Partialpayment row linked to the Payment that matches
     * the given inscription + child combination. The frontend calls this
     * endpoint from both the manual payment form and the monthly schedule
     * checkbox.
     *
     * Route: POST /api/admin/payments/{inscriptionId}/{childId}/transactions
     *
     * Validation rules:
     * - amount must be > 0
     * - amount must not exceed the remaining balance
     * - date is required and must be a valid date
     * - target_month is optional (YYYY-MM), required for monthly payments
     *
     * @group Admin - Payments
     * @authenticated
     *
     * @urlParam inscriptionId integer required The InscriptionID. Example: 101
     * @urlParam childId integer required The ChildID. Example: 45
     * @bodyParam amount numeric required The instalment amount in TND. Example: 150.00
     * @bodyParam date string required The payment date (YYYY-MM-DD). Example: 2025-10-01
     * @bodyParam target_month string optional The month this payment covers (YYYY-MM). Example: 2025-09
     *
     * @response 201 {
     *   "success": true,
     *   "message": "Transaction recorded.",
     *   "data": {
     *     "PartialpaymentID": 301,
     *     "PaymentID": 250,
     *     "Value": 150.00,
     *     "Date": "2025-10-01",
     *     "Targetmonth": "2025-09"
     *   }
     * }
     *
     * @response 404 {
     *   "success": false,
     *   "message": "Payment record not found for this inscription/child."
     * }
     *
     * @response 422 {
     *   "success": false,
     *   "message": "Amount exceeds remaining balance."
     * }
     */
    public function storeTransaction(Request $request, int $inscriptionId, int $childId): JsonResponse
    {
        $validated = $request->validate([
            'amount'       => 'required|numeric|min:0.01',
            'date'         => 'required|date',
            'target_month' => 'nullable|string|max:7',
        ]);

        // 1. Find the Payment record for this inscription + child
        $payment = DB::table('Payment')
            ->where('InscriptionID', $inscriptionId)
            ->where('ChildID', $childId)
            ->first();

        if (!$payment) {
            return response()->json([
                'success' => false,
                'message' => 'Payment record not found for this inscription/child.',
            ], 404);
        }

        // 2. Calculate remaining balance
        $totalAmount = (float) ($payment->Amount ?? 0);
        $alreadyPaid = (float) DB::table('Partialpayment')
            ->where('PaymentID', $payment->PaymentID)
            ->sum('Value');

        $remaining = max(0, $totalAmount - $alreadyPaid);
        $amount    = (float) $validated['amount'];

        if ($amount > $remaining + 0.01) { // small tolerance for rounding
            return response()->json([
                'success' => false,
                'message' => 'Amount exceeds remaining balance.',
            ], 422);
        }

        // 3. Convert YYYY-MM target_month to integer month for DB
        $targetMonthRaw = $validated['target_month'] ?? null;
        $targetMonthInt = null;
        if ($targetMonthRaw) {
            // Frontend sends "2025-09" → extract month number 9
            $parts = explode('-', $targetMonthRaw);
            $targetMonthInt = isset($parts[1]) ? (int) $parts[1] : (int) $targetMonthRaw;
        }

        // 4. Insert the partial payment
        $id = DB::table('Partialpayment')->insertGetId([
            'PaymentID'   => $payment->PaymentID,
            'Value'       => round($amount, 2),
            'Date'        => $validated['date'],
            'Targetmonth' => $targetMonthInt,
        ], 'PartialpaymentID');

        return response()->json([
            'success' => true,
            'message' => 'Transaction recorded.',
            'data'    => [
                'PartialpaymentID' => $id,
                'PaymentID'        => $payment->PaymentID,
                'Value'            => round($amount, 2),
                'Date'             => $validated['date'],
                'target_month'     => $targetMonthInt !== null ? str_pad((string) $targetMonthInt, 2, '0', STR_PAD_LEFT) : null,
                'Targetmonth'      => $targetMonthInt,
            ],
        ], 201);
    }
}
