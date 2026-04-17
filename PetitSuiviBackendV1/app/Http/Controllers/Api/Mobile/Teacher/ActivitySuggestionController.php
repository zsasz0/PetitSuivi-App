<?php

namespace App\Http\Controllers\Api\Mobile\Teacher;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * @group Teacher — Activity Suggestions
 *
 * Endpoints for teachers to list previous activity suggestions
 * and submit new proposals for administrative approval.
 */
class ActivitySuggestionController extends Controller
{
    /**
     * List teacher's activity suggestions.
     *
     * Returns all activity suggestions previously submitted by the
     * authenticated teacher, with their approval status and class info.
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Suggestions retrieved.",
     *   "data": [
     *     {
     *       "id": "42",
     *       "title": "Atelier musique",
     *       "description": "Session découverte instruments",
     *       "date": "2026-04-10",
     *       "start_time": "10:00",
     *       "end_time": "11:00",
     *       "status": "en_cours",
     *       "classes": [
     *         { "name": "Moyenne Section B" }
     *       ]
     *     }
     *   ]
     * }
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        $teacherId = $user->PersonID;

        // Suggestions mapped as Plandayactivity with status logic
        $suggestions = \Illuminate\Support\Facades\DB::table('Plandayactivity')
            ->join('Activity', 'Plandayactivity.ActivityID', '=', 'Activity.ActivityID')
            ->join('Planday', 'Plandayactivity.PlandayID', '=', 'Planday.PlandayID')
            ->join('TeacherClass', 'Planday.ClassID', '=', 'TeacherClass.ClassID')
            ->join('Class', 'Planday.ClassID', '=', 'Class.ClassID')
            ->where('TeacherClass.TeacherID', $teacherId)
            ->whereIn('Plandayactivity.Status', ['propose', 'en_cours'])
            ->select(
                'Plandayactivity.PlandayactivityID as id',
                'Activity.Title as title',
                'Activity.Description as description',
                'Planday.Date as date',
                'Plandayactivity.Starttime as start_time',
                'Plandayactivity.Endtime as end_time',
                'Plandayactivity.Status as status',
                'Class.Name as class_name'
            )
            ->get();

        $formatted = [];
        foreach ($suggestions as $s) {
            $formatted[] = [
                'id' => (string) $s->id,
                'title' => $s->title,
                'description' => $s->description,
                'date' => $s->date,
                'start_time' => $s->start_time,
                'end_time' => $s->end_time,
                'status' => $s->status,
                'classes' => [['name' => $s->class_name]]
            ];
        }

        return response()->json([
            'success' => true,
            'message' => 'Suggestions retrieved.',
            'data' => $formatted
        ]);
    }

    /**
     * Submit a new activity suggestion.
     *
     * Creates a new activity proposal that will be reviewed by admin.
     * The suggestion is linked to one or more classes.
     *
     * @bodyParam title string required The activity title. Example: Atelier musique
     * @bodyParam description string required Detailed description. Example: Session découverte instruments
     * @bodyParam date string required ISO date. Example: 2026-04-10
     * @bodyParam start_time string required Start time HH:MM. Example: 10:00
     * @bodyParam end_time string required End time HH:MM. Example: 11:00
     * @bodyParam class_ids array required List of ClassIDs. Example: [1, 2]
     *
     * @response 201 {
     *   "success": true,
     *   "message": "Suggestion created."
     * }
     *
     * @response 422 {
     *   "success": false,
     *   "message": "Validation failed.",
     *   "errors": { "title": ["The title field is required."] }
     * }
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'title' => 'required|string|max:50',
            'description' => 'required|string|max:50',
            'date' => 'required|date',
            'start_time' => 'required|string',
            'end_time' => 'required|string',
            'class_ids' => 'required|array',
            'class_ids.*' => 'integer'
        ]);

        \Illuminate\Support\Facades\DB::beginTransaction();
        try {
            // 1. Create the activity
            $activityId = \Illuminate\Support\Facades\DB::table('Activity')->insertGetId([
                'Title' => $validated['title'],
                'Description' => $validated['description']
            ]);

            // 2. Loop through classes
            foreach ($validated['class_ids'] as $classId) {
                // Find active planning for class
                $planning = \Illuminate\Support\Facades\DB::table('Class')->where('ClassID', $classId)->first('PlanningID');
                
                // Get or create Planday
                $planDayId = \Illuminate\Support\Facades\DB::table('Planday')
                    ->where('Date', $validated['date'])
                    ->where('ClassID', $classId)
                    ->value('PlandayID');

                if (!$planDayId) {
                    $planDayId = \Illuminate\Support\Facades\DB::table('Planday')->insertGetId([
                        'Date' => $validated['date'],
                        'ClassID' => $classId,
                        'PlanningID' => $planning ? $planning->PlanningID : null
                    ]);
                }

                // Insert into Plandayactivity as 'propose'
                \Illuminate\Support\Facades\DB::table('Plandayactivity')->insert([
                    'PlandayID' => $planDayId,
                    'ActivityID' => $activityId,
                    'Starttime' => $validated['start_time'],
                    'Endtime' => $validated['end_time'],
                    'Status' => 'propose'
                ]);
            }

            \Illuminate\Support\Facades\DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Suggestion created.'
            ], 201);
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Server Error: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get AI-generated activity suggestions.
     *
     * Returns AI-powered recommendations for activities based on
     * the class composition, age group, and curriculum progress.
     *
     * @response 200 {
     *   "success": true,
     *   "message": "AI Activity suggestions retrieved.",
     *   "data": []
     * }
     */
    public function suggest(Request $request): JsonResponse
    {
        // Mock AI suggestions for now
        $suggestions = [
            [
                'title' => 'Atelier peinture nature',
                'description' => 'Peindre avec des feuilles et couleurs de saison.',
                'target_age' => '3-5 ans',
                'duration' => 45
            ],
            [
                'title' => 'Parcours motricité',
                'description' => 'Développer l’équilibre et la coordination.',
                'target_age' => '4-6 ans',
                'duration' => 30
            ]
        ];

        return response()->json([
            'success' => true,
            'message' => 'AI Activity suggestions retrieved.',
            'data' => $suggestions
        ]);
    }
}
