<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ChildController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'planning_id' => 'nullable|integer|exists:Planning,PlanningID',
        ]);

        $planningId = $request->query('planning_id') ? (int) $request->query('planning_id') : null;

        $childrenQuery = DB::table('Child')
            ->select('Child.ChildID as child_id', 'Child.Firstname as firstName', 'Child.Lastname as lastName')
            ->orderBy('Child.Firstname')
            ->orderBy('Child.Lastname');

        if ($planningId) {
            $childrenQuery
                ->join('ChildClass', 'Child.ChildID', '=', 'ChildClass.ChildID')
                ->join('Class', function ($join) use ($planningId) {
                    $join->on('ChildClass.ClassID', '=', 'Class.ClassID')
                        ->where('Class.PlanningID', '=', $planningId);
                })
                ->addSelect(DB::raw('MIN(Class.Name) as class_name'))
                ->groupBy('Child.ChildID', 'Child.Firstname', 'Child.Lastname');
        }

        $children = $childrenQuery->get();

        return response()->json([
            'success' => true,
            'message' => 'Children retrieved.',
            'data' => $children
        ]);
    }

    public function show(int $id): JsonResponse
    {
        // TODO: Delegate fetching a specific child profile
        return response()->json([
            'success' => true,
            'message' => 'Child details.',
            'data' => null
        ]);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        // TODO: Delegate updating a child's global data
        return response()->json([
            'success' => true,
            'message' => 'Child details updated.',
            'data' => null
        ]);
    }
}
