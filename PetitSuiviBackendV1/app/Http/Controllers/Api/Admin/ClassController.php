<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Exception;
use Illuminate\Validation\Rule;

/**
 * @group Admin - Classes
 *
 * APIs for managing classes (Preschool & Kindergarten).
 */
class ClassController extends Controller
{
    /**
     * List Classes
     *
     * Retrieves all classes with their type, assigned teachers (via TeacherClass pivot),
     * and enrolled students (via ChildClass pivot). The frontend filters by type name
     * (preschool / kindergarten) client-side.
     *
     * @authenticated
     *
     * @response 200 {
     *   "success": true,
     *   "data": [
     *     {
     *       "id": 1,
     *       "name": "Preschool Section A",
     *       "year": 2025,
     *       "capacity": 20,
     *       "is_archived": false,
     *       "type": { "id": 2, "name": "Preschool" },
     *       "teachers": [
     *         { "id": "11112222", "cin": "11112222", "firstName": "Mohamed", "lastName": "Test" }
     *       ],
     *       "students": [
     *         { "id": 1, "firstName": "Alice", "lastName": "Smith", "birthdate": "2020-01-01", "parent_id": "P987" }
     *       ]
     *     }
     *   ]
     * }
     */
    public function index(Request $request): JsonResponse
    {
        // Get all classes with their types
        $classes = DB::table('Class')
            ->leftJoin('Classtype', 'Class.ClasstypeID', '=', 'Classtype.ClasstypeID')
            ->leftJoin('Planning', 'Class.PlanningID', '=', 'Planning.PlanningID')
            ->select(
                'Class.ClassID',
                'Class.Name',
                'Class.Year',
                'Class.Capacity',
                'Class.Isarchived',
                'Class.ClasstypeID',
                'Class.PlanningID',
                'Planning.Startdate as PlanningStartdate',
                'Planning.Enddate as PlanningEnddate',
                'Planning.Isarchived as PlanningIsarchived',
                'Classtype.Name as TypeName'
            )
            ->get();

        $result = $classes->map(function ($cls) {
            // Get teachers for this class via TeacherClass pivot
            $teachers = DB::table('TeacherClass')
                ->join('Account', function ($join) {
                    $join->on('TeacherClass.TeacherID', '=', 'Account.PersonID')
                         ->where('Account.RoleID', '=', 1);
                })
                ->where('TeacherClass.ClassID', $cls->ClassID)
                ->select(
                    'Account.Cin as cin',
                    'Account.Firstname as firstName',
                    'Account.Lastname as lastName',
                    'Account.Is_archived as is_archived'
                )
                ->get()
                ->map(function ($t) {
                    return [
                        'id' => (string) $t->cin,
                        'cin' => (string) $t->cin,
                        'firstName' => $t->firstName,
                        'lastName' => $t->lastName,
                        'is_archived' => (bool) $t->is_archived,
                    ];
                });

            // Get enrolled students for this class via ChildClass pivot
            $students = DB::table('ChildClass')
                ->join('Child', 'ChildClass.ChildID', '=', 'Child.ChildID')
                ->where('ChildClass.ClassID', $cls->ClassID)
                ->select(
                    'Child.ChildID',
                    'Child.Firstname',
                    'Child.Lastname',
                    'Child.Birthdate',
                    'Child.ParentID'
                )
                ->get()
                ->map(function ($s) {
                    // Resolve parent CIN
                    $parentCin = null;
                    if ($s->ParentID) {
                        $parentAccount = DB::table('Account')
                            ->where('PersonID', $s->ParentID)
                            ->where('RoleID', 3)
                            ->select('Cin')
                            ->first();
                        $parentCin = $parentAccount ? (string) $parentAccount->Cin : null;
                    }
                    return [
                        'id' => $s->ChildID,
                        'firstName' => $s->Firstname,
                        'lastName' => $s->Lastname,
                        'birthdate' => $s->Birthdate,
                        'parent_id' => $parentCin ?: '-',
                    ];
                });

            return [
                'id' => $cls->ClassID,
                'name' => $cls->Name,
                'year' => $cls->Year,
                'capacity' => $cls->Capacity,
                'is_archived' => (bool) $cls->Isarchived,
                'planning_id' => $cls->PlanningID,
                'planning_start_date' => $cls->PlanningStartdate,
                'planning_end_date' => $cls->PlanningEnddate,
                'planning_is_archived' => (bool) ($cls->PlanningIsarchived ?? false),
                'type' => [
                    'id' => $cls->ClasstypeID,
                    'name' => $cls->TypeName,
                ],
                'teachers' => $teachers->values(),
                'students' => $students->values(),
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $result->values()
        ]);
    }

    /**
     * Create Class
     *
     * Creates a new class and assigns teachers via the TeacherClass pivot table.
     * The frontend sends a type_id to differentiate Preschool vs Kindergarten.
     *
     * @authenticated
     *
     * @bodyParam name string required The name of the class. Example: Petite Section A
     * @bodyParam year int required The starting academic year. Example: 2025
     * @bodyParam capacity int The maximum capacity. Example: 20
     * @bodyParam type_id int required The ClasstypeID (1=Kindergarten, 2=Preschool). Example: 2
     * @bodyParam teacher_ids string[] Array of teacher CINs to assign. Example: ["11112222"]
     *
     * @response 201 {
     *   "success": true,
     *   "message": "Class created.",
     *   "data": null
     * }
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'name' => [
                'required', 'string', 'max:50'
            ],
            'year' => 'required|integer',
            'capacity' => 'nullable|integer|min:0|max:100',
            'type_id' => 'required|integer|exists:Classtype,ClasstypeID',
            'teacher_ids' => 'nullable|array',
        ]);

        $planning = DB::table('Planning')->whereYear('Startdate', $request->year)->first();
        $exists = DB::table('Class')
            ->where('Name', $request->name)
            ->where('PlanningID', $planning ? $planning->PlanningID : null)
            ->where('ClasstypeID', $request->type_id)
            ->exists();

        if ($exists) {
            return response()->json([
                'success' => false,
                'message' => 'The given data was invalid.',
                'errors' => [
                    'name' => ['The name has already been taken.']
                ]
            ], 422);
        }

        try {
            DB::beginTransaction();

            // Resolve PlanningID from the year
            $planning = DB::table('Planning')
                ->whereYear('Startdate', $request->year)
                ->first();

            $classId = DB::table('Class')->insertGetId([
                'Name' => $request->name,
                'Year' => $request->year,
                'Capacity' => $request->capacity,
                'Isarchived' => 0,
                'ClasstypeID' => $request->type_id,
                'PlanningID' => $planning ? $planning->PlanningID : null,
            ]);

            // Attach teachers via pivot
            if ($request->filled('teacher_ids') && is_array($request->teacher_ids)) {
                foreach ($request->teacher_ids as $cin) {
                    $account = DB::table('Account')
                        ->where('Cin', $cin)
                        ->where('RoleID', 1)
                        ->first();
                    if ($account) {
                        DB::table('TeacherClass')->insert([
                            'TeacherID' => $account->PersonID,
                            'ClassID' => $classId,
                        ]);
                    }
                }
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Class created.',
                'data' => null
            ], 201);
        } catch (Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Error creating class.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get Class Details
     *
     * Retrieves details for a specific class by its ClassID.
     *
     * @authenticated
     *
     * @urlParam id int required The ClassID. Example: 1
     *
     * @response 200 {
     *   "success": true,
     *   "data": {
     *     "id": 1,
     *     "name": "Preschool Section A",
     *     "year": 2025,
     *     "capacity": 20
     *   }
     * }
     */
    public function show(int $id): JsonResponse
    {
        $cls = DB::table('Class')
            ->leftJoin('Classtype', 'Class.ClasstypeID', '=', 'Classtype.ClasstypeID')
            ->where('Class.ClassID', $id)
            ->select(
                'Class.ClassID',
                'Class.Name',
                'Class.Year',
                'Class.Capacity',
                'Class.Isarchived',
                'Classtype.Name as TypeName',
                'Classtype.ClasstypeID'
            )
            ->first();

        if (!$cls) {
            return response()->json(['success' => false, 'message' => 'Class not found.'], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $cls->ClassID,
                'name' => $cls->Name,
                'year' => $cls->Year,
                'capacity' => $cls->Capacity,
                'is_archived' => (bool) $cls->Isarchived,
                'type' => [
                    'id' => $cls->ClasstypeID,
                    'name' => $cls->TypeName,
                ],
            ]
        ]);
    }

    /**
     * Update Class
     *
     * Updates class details and syncs assigned teachers in the TeacherClass pivot.
     *
     * @authenticated
     *
     * @urlParam id int required The ClassID. Example: 1
     * @bodyParam name string The new class name. Example: Petite Section B
     * @bodyParam year int The starting academic year. Example: 2025
     * @bodyParam capacity int The capacity. Example: 25
     * @bodyParam teacher_ids string[] Array of teacher CINs to sync. Example: ["11112222"]
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Class updated.",
     *   "data": null
     * }
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $cls = DB::table('Class')->where('ClassID', $id)->first();
        if (!$cls) {
            return response()->json(['success' => false, 'message' => 'Class not found.'], 404);
        }

        $request->validate([
            'name' => [
                'sometimes', 'string', 'max:50'
            ],
            'year' => 'nullable|integer',
            'capacity' => 'nullable|integer|min:0|max:100',
            'teacher_ids' => 'nullable|array',
        ]);

        if ($request->filled('name')) {
            $year = $request->filled('year') ? $request->year : $cls->Year;
            $planning = DB::table('Planning')->whereYear('Startdate', $year)->first();
            
            $exists = DB::table('Class')
                ->where('Name', $request->name)
                ->where('PlanningID', $planning ? $planning->PlanningID : null)
                ->where('ClasstypeID', $cls->ClasstypeID)
                ->where('ClassID', '!=', $id)
                ->exists();

            if ($exists) {
                return response()->json([
                    'success' => false,
                    'message' => 'The given data was invalid.',
                    'errors' => [
                        'name' => ['The name has already been taken.']
                    ]
                ], 422);
            }
        }

        try {
            DB::beginTransaction();

            $updateData = [];
            if ($request->filled('name')) $updateData['Name'] = $request->name;
            if ($request->filled('year')) {
                $updateData['Year'] = (int) $request->year;
                // Also resolve PlanningID
                $planning = DB::table('Planning')
                    ->whereYear('Startdate', (int) $request->year)
                    ->first();
                if ($planning) {
                    $updateData['PlanningID'] = $planning->PlanningID;
                }
            }
            if ($request->has('capacity')) $updateData['Capacity'] = $request->capacity;

            if (!empty($updateData)) {
                DB::table('Class')->where('ClassID', $id)->update($updateData);
            }

            // Sync teachers: remove old, insert new
            if ($request->has('teacher_ids')) {
                DB::table('TeacherClass')->where('ClassID', $id)->delete();

                $teacherIds = $request->teacher_ids;
                if (is_array($teacherIds)) {
                    foreach ($teacherIds as $cin) {
                        $account = DB::table('Account')
                            ->where('Cin', $cin)
                            ->where('RoleID', 1)
                            ->first();
                        if ($account) {
                            DB::table('TeacherClass')->insertOrIgnore([
                                'TeacherID' => $account->PersonID,
                                'ClassID' => $id,
                            ]);
                        }
                    }
                }
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Class updated.',
                'data' => null
            ]);
        } catch (Exception $e) {
            DB::rollBack();
            \Illuminate\Support\Facades\Log::error('Class update error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Toggle Archive Class
     *
     * Toggles the Isarchived status of a class (0 ↔ 1).
     *
     * @authenticated
     *
     * @urlParam id int required The ClassID. Example: 1
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Class archive status toggled.",
     *   "data": null
     * }
     */
    public function toggleArchive(int $id): JsonResponse
    {
        $cls = DB::table('Class')->where('ClassID', $id)->first();
        if (!$cls) {
            return response()->json(['success' => false, 'message' => 'Class not found.'], 404);
        }

        DB::table('Class')->where('ClassID', $id)->update([
            'Isarchived' => $cls->Isarchived ? 0 : 1,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Class archive status toggled.',
            'data' => null
        ]);
    }

    /**
     * Delete Class
     *
     * Permanently deletes a class and its TeacherClass and ChildClass associations.
     *
     * @authenticated
     *
     * @urlParam id int required The ClassID. Example: 1
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Class removed.",
     *   "data": null
     * }
     */
    public function destroy(int $id): JsonResponse
    {
        $cls = DB::table('Class')->where('ClassID', $id)->first();
        if (!$cls) {
            return response()->json(['success' => false, 'message' => 'Class not found.'], 404);
        }

        try {
            DB::beginTransaction();

            // Delete Plandayactivity records for all Plandays belonging to this class
            $plandayIds = DB::table('Planday')->where('ClassID', $id)->pluck('PlandayID');
            if ($plandayIds->isNotEmpty()) {
                DB::table('Plandayactivity')->whereIn('PlandayID', $plandayIds)->delete();
            }
            // Delete Planday records for this class
            DB::table('Planday')->where('ClassID', $id)->delete();

            DB::table('TeacherClass')->where('ClassID', $id)->delete();
            DB::table('ChildClass')->where('ClassID', $id)->delete();
            DB::table('Class')->where('ClassID', $id)->delete();

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Class removed.',
                'data' => null
            ]);
        } catch (Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Error deleting class.',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
