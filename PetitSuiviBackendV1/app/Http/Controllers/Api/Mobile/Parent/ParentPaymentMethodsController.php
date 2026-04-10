<?php

namespace App\Http\Controllers\Api\Mobile\Parent;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;

/**
 * @group Mobile - Parent Settings
 */
class ParentPaymentMethodsController extends Controller
{
    /**
     * Get Payment Methods
     *
     * Retrieves the available payment methods for inscriptions.
     *
     * @response 200 {
     *   "success": true,
     *   "data": [
     *     {"value": "yearly", "label": "Annuel"},
     *     {"value": "monthlyTotal", "label": "Mensuel (Total)"},
     *     {"value": "monthlyPartial", "label": "Mensuel (Partiel)"}
     *   ]
     * }
     */
    public function index(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => [
                [
                    'value' => 'yearly',
                    'label' => 'Totalité (Annuel)',
                ],
                [
                    'value' => 'monthlyTotal',
                    'label' => 'Trimestriel', // Or just some labels
                ],
                [
                    'value' => 'monthlyPartial',
                    'label' => 'Mensuel',
                ]
            ]
        ]);
    }
}
