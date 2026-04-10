<?php

namespace App\Http\Controllers\Api\Parent;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FinanceController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        // TODO: Delegate fetching a read-only list of payments for the parent
        return response()->json([
            'success' => true,
            'message' => 'Financial records retrieved.',
            'data' => []
        ]);
    }

    public function show(int $id): JsonResponse
    {
        // TODO: Delegate fetching details of a specific payment/installments
        return response()->json([
            'success' => true,
            'message' => 'Payment record details.',
            'data' => null
        ]);
    }
}
