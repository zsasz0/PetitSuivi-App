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
