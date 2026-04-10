<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/**
 * @group Mobile - Evaluation
 *
 * APIs for managing classroom evaluations (psycho-motor) within the mobile application.
 */
class ClassEvaluationController extends Controller
{
    private function applyParentVisibilityFilters($query)
    {
        $evaluationSchoolYearSql = "(CASE WHEN MONTH(Evaluation.Date) >= 7 THEN YEAR(Evaluation.Date) ELSE YEAR(Evaluation.Date) - 1 END)";
        $inscriptionSchoolYearSql = "(CASE WHEN MONTH(Inscription.Date) >= 7 THEN YEAR(Inscription.Date) ELSE YEAR(Inscription.Date) - 1 END)";

        return $query
            ->whereExists(function ($subQuery) use ($evaluationSchoolYearSql) {
                $subQuery->select(DB::raw(1))
                    ->from('Planning')
                    ->whereRaw("YEAR(Planning.Startdate) = {$evaluationSchoolYearSql}")
                    ->where(function ($planningQuery) {
                        $planningQuery->where('Planning.Isarchived', 0)
                            ->orWhereNull('Planning.Isarchived');
                    });
            })
            ->whereExists(function ($subQuery) use ($evaluationSchoolYearSql, $inscriptionSchoolYearSql) {
                $subQuery->select(DB::raw(1))
                    ->from('Payment')
                    ->join('Inscription', 'Payment.InscriptionID', '=', 'Inscription.InscriptionID')
                    ->whereColumn('Payment.ChildID', 'Evaluation.ChildID')
                    ->where(function ($inscriptionQuery) {
                        $inscriptionQuery->where('Inscription.Isarchived', 0)
                            ->orWhereNull('Inscription.Isarchived');
                    })
                    ->whereRaw("{$inscriptionSchoolYearSql} = {$evaluationSchoolYearSql}");
            });
    }

    /**
     * Get Activities by Date for Class
     *
     * Retrieves all activities and their associated criteria for a specific class on a given date.
     * Starts by querying the Planday generated for the class and its linked Plandayactivities.
     *
     * @authenticated
     * @urlParam classId int required The ID of the class (ClassID). Example: 1
     * @urlParam date string required The date (YYYY-MM-DD). Example: "2026-04-06"
     * 
     * @response 200 {
     *   "data": {
     *     "activities": [
     *       {
     *         "activity_id": 1,
     *         "activity_name": "Atelier Peinture",
     *         "criteria": [
     *           {
     *             "criteria_id": 1,
     *             "criteria_name": "Reconnaissance des couleurs"
     *           }
     *         ]
     *       }
     *     ]
     *   }
     * }
     */
    public function activitiesByDate($classId, $date)
    {
        $planday = DB::table('Planday')
            ->where('ClassID', $classId)
            ->where('Date', $date)
            ->first();

        if (!$planday) {
            return response()->json(['success' => true, 'data' => ['activities' => []]]);
        }

        $activitiesQuery = DB::table('Plandayactivity')
            ->join('Activity', 'Plandayactivity.ActivityID', '=', 'Activity.ActivityID')
            ->leftJoin('CriteriaActivity', 'Activity.ActivityID', '=', 'CriteriaActivity.ActivityID')
            ->leftJoin('Criteria', 'CriteriaActivity.CriteriaID', '=', 'Criteria.CriteriaID')
            ->where('Plandayactivity.PlandayID', $planday->PlandayID)
            ->select('Activity.ActivityID', 'Activity.Title', 'Criteria.CriteriaID', 'Criteria.Name')
            ->get();

        $activitiesMap = [];

        foreach ($activitiesQuery as $row) {
            if (!isset($activitiesMap[$row->ActivityID])) {
                $activitiesMap[$row->ActivityID] = [
                    'activity_id' => $row->ActivityID,
                    'activity_name' => $row->Title,
                    'criteria' => []
                ];
            }
            if ($row->CriteriaID) {
                // Ensure no duplicates
                $exists = false;
                foreach ($activitiesMap[$row->ActivityID]['criteria'] as $c) {
                    if ($c['criteria_id'] == $row->CriteriaID) {
                        $exists = true;
                        break;
                    }
                }
                if (!$exists) {
                    $activitiesMap[$row->ActivityID]['criteria'][] = [
                        'criteria_id' => $row->CriteriaID,
                        'criteria_name' => $row->Name
                    ];
                }
            }
        }

        return response()->json([
            'success' => true,
            'data' => [
                'activities' => array_values($activitiesMap)
            ]
        ]);
    }

    /**
     * Get Child Evaluations by Date
     *
     * Retrieves the existing evaluations and grades for a child on a specific date.
     *
     * @authenticated
     * @urlParam childId int required The ID of the child. Example: 45
     * @urlParam date string required The date (YYYY-MM-DD). Example: "2026-04-06"
     * 
     * @response 200 {
     *   "data": {
     *     "evaluations": [
     *       {
     *         "evaluation_id": 10,
     *         "activity_id": 1,
     *         "criteria": [
     *           {
     *             "criteria_id": 1,
     *             "status_label": "Acquise"
     *           }
     *         ]
     *       }
     *     ]
     *   }
     * }
     */
    public function evaluationsByDate($childId, $date)
    {
        $evaluations = DB::table('Evaluation')
            ->join('Grade', 'Evaluation.EvaluationID', '=', 'Grade.EvaluationID')
            ->join('Gradestatus', 'Grade.GradestatusID', '=', 'Gradestatus.GradestatusID')
            ->where('Evaluation.ChildID', $childId)
            ->where('Evaluation.Date', $date)
            ->select(
                'Evaluation.EvaluationID',
                'Evaluation.ActivityID',
                'Grade.CriteriaID',
                'Gradestatus.Name as status_label'
            )
            ->get();

        $evaluationsMap = [];
        foreach ($evaluations as $row) {
            if (!isset($evaluationsMap[$row->EvaluationID])) {
                $evaluationsMap[$row->EvaluationID] = [
                    'evaluation_id' => $row->EvaluationID,
                    'activity_id' => $row->ActivityID,
                    'criteria' => []
                ];
            }
            $evaluationsMap[$row->EvaluationID]['criteria'][] = [
                'criteria_id' => $row->CriteriaID,
                'status_label' => $row->status_label
            ];
        }

        return response()->json([
            'success' => true,
            'data' => [
                'evaluations' => array_values($evaluationsMap)
            ]
        ]);
    }

    /**
     * Store Bulk Evaluations
     *
     * Saves or updates evaluations and criteria grades for multiple children and activities simultaneously.
     *
     * @authenticated
     * @bodyParam teacher_id string required The CIN or ID of the teacher performing the evaluation. Example: "11112222"
     * @bodyParam evaluation_date string required The date (YYYY-MM-DD). Example: "2026-04-06"
     * @bodyParam evaluations array required Collection of criteria evaluations. Example: [{"child_id": 45, "activity_id": 1, "criteria_id": 2, "status_label": "Acquise"}]
     * 
     * @response 200 {
     *   "success": true,
     *   "message": "Evaluations updated successfully."
     * }
     */
    public function storeBulk(Request $request)
    {
        $payload = $request->input('evaluations', []);
        $date = $request->input('evaluation_date');

        if (empty($payload) || !$date) {
            return response()->json(['message' => 'Invalid payload.'], 400);
        }

        DB::beginTransaction();

        try {
            foreach ($payload as $e) {
                $childId = $e['child_id'];
                $activityId = $e['activity_id'];
                $criteriaId = $e['criteria_id'];
                $statusLabel = $e['status_label'];

                // 1. Get or Create Evaluation
                $evalId = DB::table('Evaluation')
                    ->where('ChildID', $childId)
                    ->where('ActivityID', $activityId)
                    ->where('Date', $date)
                    ->value('EvaluationID');

                if (!$evalId) {
                    $activity = DB::table('Activity')->where('ActivityID', $activityId)->first();
                    $evalId = DB::table('Evaluation')->insertGetId([
                        'ChildID' => $childId,
                        'ActivityID' => $activityId,
                        'Date' => $date,
                        'Activtitytitlesnapshot' => $activity ? $activity->Title : '',
                        'Activitydescriptionsnapshot' => $activity ? $activity->Description : ''
                    ]);
                }

                // 2. Insert or Update Grade
                $status = DB::table('Gradestatus')->where('Name', $statusLabel)->first();
                $statusId = $status ? $status->GradestatusID : 1;
                $criteria = DB::table('Criteria')->where('CriteriaID', $criteriaId)->first();

                $gradeExists = DB::table('Grade')
                    ->where('EvaluationID', $evalId)
                    ->where('CriteriaID', $criteriaId)
                    ->exists();

                if ($gradeExists) {
                    DB::table('Grade')
                        ->where('EvaluationID', $evalId)
                        ->where('CriteriaID', $criteriaId)
                        ->update([
                            'GradestatusID' => $statusId,
                            'Status' => $statusLabel
                        ]);
                } else {
                    DB::table('Grade')->insert([
                        'EvaluationID' => $evalId,
                        'CriteriaID' => $criteriaId,
                        'GradestatusID' => $statusId,
                        'Status' => $statusLabel,
                        'Criterianamesnapshot' => $criteria ? $criteria->Name : ''
                    ]);
                }
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Evaluations updated successfully.'
            ]);
        } catch (\Exception $ex) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to save evaluations: ' . $ex->getMessage()
            ], 500);
        }
    }

    /**
     * Store Single Evaluation
     * Required by TeacherChildProfile (via EvaluationService::evaluateCriteria)
     */
    public function storeSingle(Request $request)
    {
        $childId = $request->input('child_id');
        $activityId = $request->input('activity_id');
        $date = $request->input('evaluation_date');
        $criteriaArr = $request->input('criteria', []);

        if (!$childId || !$date || empty($criteriaArr)) {
            return response()->json(['success' => false, 'message' => 'Invalid payload.'], 400);
        }

        DB::beginTransaction();
        try {
            $evalId = DB::table('Evaluation')
                ->where('ChildID', $childId)
                ->where('ActivityID', $activityId)
                ->where('Date', $date)
                ->value('EvaluationID');

            if (!$evalId) {
                $activity = DB::table('Activity')->where('ActivityID', $activityId)->first();
                $evalId = DB::table('Evaluation')->insertGetId([
                    'ChildID' => $childId,
                    'ActivityID' => $activityId,
                    'Date' => $date,
                    'Activtitytitlesnapshot' => $activity ? $activity->Title : '',
                    'Activitydescriptionsnapshot' => $activity ? $activity->Description : ''
                ]);
            }

            foreach ($criteriaArr as $c) {
                $statusLabel = $c['status_label'];
                $criteriaId = $c['criteria_id'];

                $status = DB::table('Gradestatus')->where('Name', $statusLabel)->first();
                $statusId = $status ? $status->GradestatusID : 1;
                $criteria = DB::table('Criteria')->where('CriteriaID', $criteriaId)->first();

                $gradeExists = DB::table('Grade')
                    ->where('EvaluationID', $evalId)
                    ->where('CriteriaID', $criteriaId)
                    ->exists();

                if ($gradeExists) {
                    DB::table('Grade')
                        ->where('EvaluationID', $evalId)
                        ->where('CriteriaID', $criteriaId)
                        ->update([
                            'GradestatusID' => $statusId,
                            'Status' => $statusLabel
                        ]);
                } else {
                    DB::table('Grade')->insert([
                        'EvaluationID' => $evalId,
                        'CriteriaID' => $criteriaId,
                        'GradestatusID' => $statusId,
                        'Status' => $statusLabel,
                        'Criterianamesnapshot' => $criteria ? $criteria->Name : ''
                    ]);
                }
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Evaluation saved.',
                'data' => ['id' => $evalId]
            ]);
        } catch (\Exception $ex) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed: ' . $ex->getMessage()
            ], 500);
        }
    }

    /**
     * Parent View: Get Child Evaluations
     * Returns a formatted timeline list of acquired/reinforce competencies for the Parent App.
     */
    public function parentViewChildEvaluations($childId)
    {
        $evaluations = $this->applyParentVisibilityFilters(DB::table('Evaluation'))
            ->join('Grade', 'Evaluation.EvaluationID', '=', 'Grade.EvaluationID')
            ->join('Gradestatus', 'Grade.GradestatusID', '=', 'Gradestatus.GradestatusID')
            ->join('Criteria', 'Grade.CriteriaID', '=', 'Criteria.CriteriaID')
            ->leftJoin('Activity', 'Evaluation.ActivityID', '=', 'Activity.ActivityID')
            ->where('Evaluation.ChildID', $childId)
            ->select(
                'Evaluation.EvaluationID',
                'Evaluation.ActivityID',
                'Activity.Title as activity_name',
                'Grade.CriteriaID',
                'Criteria.Name as criteria_name',
                'Gradestatus.Name as status_label',
                'Evaluation.Date'
            )
            ->orderBy('Evaluation.Date', 'desc')
            ->get();

        $evaluationsMap = [];
        foreach ($evaluations as $row) {
            if (!isset($evaluationsMap[$row->EvaluationID])) {
                $evaluationsMap[$row->EvaluationID] = [
                    'evaluation_id' => $row->EvaluationID,
                    'activity_name' => $row->activity_name ?: 'Activité ' . $row->EvaluationID,
                    'date' => $row->Date,
                    'criteria' => []
                ];
            }
            $evaluationsMap[$row->EvaluationID]['criteria'][] = [
                'criteria_name' => $row->criteria_name,
                'status_label' => $row->status_label
            ];
        }

        return response()->json([
            'success' => true,
            'data' => [
                'evaluations' => array_values($evaluationsMap)
            ]
        ]);
    }
}
