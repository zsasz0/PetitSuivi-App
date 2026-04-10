<?php

namespace App\Http\Controllers\Api\Mobile\Parent;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

/**
 * @group Mobile - Parent Support
 *
 * APIs for retrieving support and contact parameters for the parent mobile app.
 */
class ParentSupportController extends Controller
{
    /**
     * Get Support Parameters
     *
     * Retrieves system-wide contact and company parameters used by the Support & FAQ page.
     *
     * @response 200 {
     *   "success": true,
     *   "data": [
     *     { "name": "contact_email", "value": "support@petitsuivi.com" },
     *     { "name": "contact_phone", "value": "+216 70 123 456" },
     *     { "name": "company_name", "value": "Petit Suivi" }
     *   ]
     * }
     */
    public function index(): JsonResponse
    {
        $params = DB::table('Parameter')
            ->select('Name as name', 'Value as value')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $params,
        ]);
    }
}
