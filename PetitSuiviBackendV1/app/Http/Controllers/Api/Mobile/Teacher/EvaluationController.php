<?php

namespace App\Http\Controllers\Api\Mobile\Teacher;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * @group Teacher — Student Evaluations
 *
 * Endpoints for managing competency evaluations. Teachers grade
 * children against criteria for each scheduled activity.
 */
class EvaluationController extends Controller
{
    /**
     * List evaluations.
     *
     * Returns evaluations for the teacher's class, optionally filtered
     * by child ID, activity ID, or date.
     *
     * @queryParam child_id integer Optional. Filter by child. Example: 8
     * @queryParam date string Optional. ISO date filter. Example: 2026-03-05
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Class evaluations retrieved.",
     *   "data": [
     *     {
     *       "evaluation_id": 1,
     *       "child_id": 8,
     *       "activity_id": 3,
     *       "criteria_id": 5,
     *       "status_label": "Acquise",
     *       "comment": "Très bon progrès",
     *       "date": "2026-03-05"
     *     }
     *   ]
     * }
     */
    public function index(Request $request): JsonResponse
    {
        $childId = $request->query('child_id');
        $date = $request->query('date');

        $query = \Illuminate\Support\Facades\DB::table('Evaluation')
            ->join('Grade', 'Evaluation.EvaluationID', '=', 'Grade.EvaluationID')
            ->join('Gradestatus', 'Grade.GradestatusID', '=', 'Gradestatus.GradestatusID')
            ->select(
                'Evaluation.EvaluationID as evaluation_id',
                'Evaluation.ChildID as child_id',
                'Evaluation.ActivityID as activity_id',
                'Grade.CriteriaID as criteria_id',
                'Gradestatus.Name as status_label',
                'Evaluation.Date as date'
            );

        if ($childId) {
            $query->where('Evaluation.ChildID', $childId);
        }
        if ($date) {
            $query->where('Evaluation.Date', $date);
        }

        $evaluations = $query->get();

        return response()->json([
            'success' => true,
            'message' => 'Class evaluations retrieved.',
            'data' => $evaluations
        ]);
    }

    /**
     * Submit a new evaluation.
     *
     * Creates a single criterion evaluation entry for a child on
     * a specific activity and date.
     *
     * @bodyParam child_id integer required The ChildID. Example: 8
     * @bodyParam activity_id integer required The ActivityID. Example: 3
     * @bodyParam teacher_id integer required The TeacherID (CIN). Example: 88552233
     * @bodyParam date string required ISO date. Example: 2026-03-05
     * @bodyParam criteria_id integer required The CriteriaID being evaluated. Example: 5
     * @bodyParam status_label string required Level label (Non acquise, En cours, Acquise, Dépassée). Example: Acquise
     * @bodyParam comment string optional Teacher comment. Example: Très bon progrès
     *
     * @response 201 {
     *   "success": true,
     *   "message": "Evaluation successfully submitted.",
     *   "data": null
     * }
     *
     * @response 422 {
     *   "success": false,
     *   "message": "Validation failed.",
     *   "errors": {}
     * }
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'child_id' => 'required|integer',
            'activity_id' => 'required|integer',
            'date' => 'required|date',
            'criteria_id' => 'required|integer',
            'status_label' => 'required|string'
        ]);

        \Illuminate\Support\Facades\DB::beginTransaction();
        try {
            // Check if Evaluation already exists
            $evalId = \Illuminate\Support\Facades\DB::table('Evaluation')
                ->where('ChildID', $validated['child_id'])
                ->where('ActivityID', $validated['activity_id'])
                ->where('Date', $validated['date'])
                ->value('EvaluationID');

            if (!$evalId) {
                $evalId = \Illuminate\Support\Facades\DB::table('Evaluation')->insertGetId([
                    'ChildID' => $validated['child_id'],
                    'ActivityID' => $validated['activity_id'],
                    'Date' => $validated['date']
                ]);
            }

            $status = \Illuminate\Support\Facades\DB::table('Gradestatus')
                ->where('Name', $validated['status_label'])
                ->first();
            $statusId = $status ? $status->GradestatusID : 1;

            $gradeExists = \Illuminate\Support\Facades\DB::table('Grade')
                ->where('EvaluationID', $evalId)
                ->where('CriteriaID', $validated['criteria_id'])
                ->exists();

            if ($gradeExists) {
                \Illuminate\Support\Facades\DB::table('Grade')
                    ->where('EvaluationID', $evalId)
                    ->where('CriteriaID', $validated['criteria_id'])
                    ->update([
                        'GradestatusID' => $statusId,
                        'Status' => $validated['status_label']
                    ]);
            } else {
                \Illuminate\Support\Facades\DB::table('Grade')->insert([
                    'EvaluationID' => $evalId,
                    'CriteriaID' => $validated['criteria_id'],
                    'GradestatusID' => $statusId,
                    'Status' => $validated['status_label']
                ]);
            }

            \Illuminate\Support\Facades\DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Evaluation successfully submitted.',
                'data' => null
            ], 201);
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to save evaluation.'
            ], 500);
        }
    }

    /**
     * Show evaluation details.
     *
     * Returns the full details for a specific evaluation entry.
     *
     * @urlParam id integer required The EvaluationID. Example: 1
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Evaluation details.",
     *   "data": {
     *     "evaluation_id": 1,
     *     "child_id": 8,
     *     "activity_id": 3,
     *     "status_label": "Acquise",
     *     "comment": "Très bon progrès"
     *   }
     * }
     *
     * @response 404 {
     *   "success": false,
     *   "message": "Evaluation not found."
     * }
     */
    public function show(int $id): JsonResponse
    {
        $evaluation = \Illuminate\Support\Facades\DB::table('Evaluation')
            ->join('Grade', 'Evaluation.EvaluationID', '=', 'Grade.EvaluationID')
            ->join('Gradestatus', 'Grade.GradestatusID', '=', 'Gradestatus.GradestatusID')
            ->where('Evaluation.EvaluationID', $id)
            ->select(
                'Evaluation.EvaluationID as evaluation_id',
                'Evaluation.ChildID as child_id',
                'Evaluation.ActivityID as activity_id',
                'Grade.CriteriaID as criteria_id',
                'Gradestatus.Name as status_label',
                'Evaluation.Date as date'
            )
            ->first();

        if (!$evaluation) {
            return response()->json([
                'success' => false,
                'message' => 'Evaluation not found.'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Evaluation details.',
            'data' => $evaluation
        ]);
    }

    /**
     * Update an evaluation.
     *
     * Modifies the status_label and/or comment for an existing evaluation.
     *
     * @urlParam id integer required The EvaluationID. Example: 1
     *
     * @bodyParam status_label string optional New level. Example: Dépassée
     * @bodyParam comment string optional Updated comment. Example: Excellente progression
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Evaluation updated.",
     *   "data": null
     * }
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $validated = $request->validate([
            'status_label' => 'required|string'
        ]);

        $status = \Illuminate\Support\Facades\DB::table('Gradestatus')
            ->where('Name', $validated['status_label'])
            ->first();
        $statusId = $status ? $status->GradestatusID : 1;

        $updated = \Illuminate\Support\Facades\DB::table('Grade')
            ->where('EvaluationID', $id)
            ->update([
                'GradestatusID' => $statusId,
                'Status' => $validated['status_label']
            ]);

        if (!$updated) {
            return response()->json([
                'success' => false,
                'message' => 'Evaluation not found or not modified.'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Evaluation updated.',
            'data' => null
        ]);
    }
}
