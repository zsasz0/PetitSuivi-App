<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\Account;
use App\Models\Planning;

/**
 * @group Mobile - Classes
 *
 * APIs for managing classes within the mobile application.
 */
class ManageClassesController extends Controller
{
    /**
     * Get Teacher Classes by Planning
     *
     * Retrieves the classes assigned to the given teacher for the active planning.
     * Includes the nested list of children (students) for each class.
     *
     * @authenticated
     * @urlParam cin string required The CIN of the teacher (from Account). Example: "12345678"
     * 
     * @response 200 {
     *   "planning_start": "2025-09-01T00:00:00.000000Z",
     *   "planning_end": "2026-06-30T23:59:59.000000Z",
     *   "data": [
     *     {
     *       "id": 1,
     *       "name": "Moyenne Section",
     *       "students": [
     *         {
     *           "id": 45,
     *           "first_name": "Alice",
     *           "last_name": "Dupont",
     *           "birthdate": "2020-05-15"
     *         }
     *       ]
     *     }
     *   ]
     * }
     */
    public function classesByPlanning($cin)
    {
        $account = Account::where('Cin', $cin)->where('RoleID', 1)->first();

        if (!$account || !$account->PersonID) {
            return response()->json(['message' => 'Teacher account not found.'], 404);
        }

        $teacherId = $account->PersonID;

        $planning = Planning::where('Isarchived', 0)->first();

        if (!$planning) {
            return response()->json(['message' => 'No active planning found.'], 404);
        }

        $classes = DB::table('Class')
            ->join('TeacherClass', 'Class.ClassID', '=', 'TeacherClass.ClassID')
            ->where('TeacherClass.TeacherID', $teacherId)
            ->where('Class.PlanningID', $planning->PlanningID)
            ->select('Class.ClassID', 'Class.Name')
            ->get();

        $data = [];

        foreach ($classes as $class) {
            $students = DB::table('Child')
                ->join('ChildClass', 'Child.ChildID', '=', 'ChildClass.ChildID')
                ->where('ChildClass.ClassID', $class->ClassID)
                ->select(
                    'Child.ChildID as id',
                    'Child.Firstname as first_name',
                    'Child.Lastname as last_name',
                    'Child.Birthdate as birthdate'
                )
                ->get();

            $data[] = [
                'id' => $class->ClassID,
                'name' => $class->Name,
                'students' => $students
            ];
        }

        $planningStart = ($planning->Startdate ?? date('Y-09-01')) . 'T00:00:00.000000Z';
        $planningEnd = ($planning->Enddate ?? date('Y-06-30', strtotime('+1 year'))) . 'T23:59:59.000000Z';

        return response()->json([
            'planning_start' => $planningStart,
            'planning_end' => $planningEnd,
            'data' => $data
        ]);
    }

    /**
     * Get Students by Class
     *
     * Retrieves the students for a specific class.
     *
     * @authenticated
     * @urlParam classId int required The ID of the class (ClassID). Example: 1
     * 
     * @response 200 {
     *   "data": {
     *     "students": [
     *       {
     *         "id": 45,
     *         "first_name": "Alice",
     *         "last_name": "Dupont",
     *         "birthdate": "2020-05-15"
     *       }
     *     ]
     *   }
     * }
     */
    public function students($classId)
    {
        $students = DB::table('Child')
            ->join('ChildClass', 'Child.ChildID', '=', 'ChildClass.ChildID')
            ->where('ChildClass.ClassID', $classId)
            ->select(
                'Child.ChildID as id',
                'Child.Firstname as first_name',
                'Child.Lastname as last_name',
                'Child.Birthdate as birthdate'
            )
            ->get();

        return response()->json([
            'data' => [
                'students' => $students
            ]
        ]);
    }
}
