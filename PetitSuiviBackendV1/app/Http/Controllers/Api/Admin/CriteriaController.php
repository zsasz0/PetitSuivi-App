<?php
namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CriteriaController extends Controller
{
    /**
     * @group Admin - Activities
     * @authenticated
     * @response { "success": true, "data": [] }
     */
    public function index(Request $request): JsonResponse
    {
        $criteria = \App\Models\Criteria::all(['CriteriaID as id', 'Name as name']);
        return response()->json([
            'success' => true,
            'data' => $criteria
        ]);
    }

    /**
     * @group Admin - Activities
     * @authenticated
     * @bodyParam name string required Example: Creativity
     * @response { "success": true, "data": {"id": 1, "name": "Creativity"} }
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'name' => 'required|string|unique:Criteria,Name'
        ]);

        $criteria = \App\Models\Criteria::create([
            'Name' => $request->name
        ]);

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $criteria->CriteriaID,
                'name' => $criteria->Name
            ]
        ], 201);
    }

    /**
     * @group Admin - Activities
     * @authenticated
     * @response { "success": true, "message": "Criteria deleted." }
     */
    public function destroy(int $id): JsonResponse
    {
        $criteria = \App\Models\Criteria::find($id);
        
        if (!$criteria) {
            return response()->json(['success' => false, 'message' => 'Criteria not found.'], 404);
        }

        try {
            // Delete pivot relationships first, if they exist
            \App\Models\CriteriaActivity::where('CriteriaID', $id)->delete();
            $criteria->delete();
            
            return response()->json(['success' => true, 'message' => 'Criteria deleted.']);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Error deleting criteria.'], 500);
        }
    }
}
