<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * @group Admin - Parameters
 *
 * APIs for managing global system parameters (e.g., fee amounts, feature toggles like AI or inscriptions).
 */
class ParameterController extends Controller
{
    /**
     * Get All Parameters
     *
     * Retrieves the list of all currently configured parameters.
     *
     * @authenticated
     * @response 200 {
     *   "success": true,
     *   "message": "System parameters retrieved.",
     *   "data": [
     *     {
     *       "id": 1,
     *       "name": "ai_enabled",
     *       "value": "true"
     *     },
     *     {
     *       "id": 2,
     *       "name": "inscriptions_open",
     *       "value": "1"
     *     }
     *   ]
     * }
     */
    public function index(Request $request): JsonResponse
    {
        $parameters = \Illuminate\Support\Facades\DB::table('Parameter')->get()->map(function ($p) {
            return [
                'id'    => $p->ParameterID,
                'name'  => $p->Name,
                'value' => $p->Value,
            ];
        });

        return response()->json([
            'success' => true,
            'message' => 'System parameters retrieved.',
            'data'    => $parameters,
        ]);
    }

    /**
     * Bulk Update Parameters
     *
     * Updates multiple parameters in a single request. Extensively used by the frontend
     * when saving the "Général Paramètres" panel or toggling special switches (AI/Inscriptions).
     *
     * @authenticated
     * @bodyParam parameters array required The list of parameters to update. Example: [{"id": 1, "value": "false"}]
     * @bodyParam parameters[].id int required The ID of the parameter.
     * @bodyParam parameters[].value string required The new value.
     *
     * @response 200 {
     *   "success": true,
     *   "message": "System parameters updated successfully.",
     *   "data": null
     * }
     */
    public function updateBulk(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'parameters'         => 'required|array',
            'parameters.*.id'    => 'required|integer',
            'parameters.*.value' => 'nullable|string',
        ]);

        \Illuminate\Support\Facades\DB::transaction(function () use ($validated) {
            foreach ($validated['parameters'] as $param) {
                \Illuminate\Support\Facades\DB::table('Parameter')
                    ->where('ParameterID', $param['id'])
                    ->update(['Value' => $param['value']]);
            }
        });

        return response()->json([
            'success' => true,
            'message' => 'System parameters updated successfully.',
            'data'    => null
        ]);
    }
}
