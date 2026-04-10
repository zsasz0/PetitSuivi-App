<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/**
 * @group Admin - Classes
 *
 * APIs for retrieving class types.
 */
class ClassTypeController extends Controller
{
    /**
     * List Class Types
     *
     * Retrieves all class types available in the system (e.g. Preschool, Kindergarten).
     * Used by the frontend to resolve the type_id when creating a new class.
     *
     * @authenticated
     *
     * @response 200 {
     *   "success": true,
     *   "data": [
     *     {
     *       "id": 1,
     *       "name": "Kindergarten"
     *     },
     *     {
     *       "id": 2,
     *       "name": "Preschool"
     *     }
     *   ]
     * }
     */
    public function index(Request $request): JsonResponse
    {
        $types = DB::table('Classtype')
            ->select(
                'ClasstypeID as id',
                'Name as name'
            )
            ->get();

        return response()->json([
            'success' => true,
            'data' => $types
        ]);
    }
}
