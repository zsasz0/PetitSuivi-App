<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;

class ReportAnalysisController extends Controller
{
    /**
     * Get Planning Report (Behavioral Incidents Aggregation)
     *
     * Aggregates all classes linked to a given planning year, their enrolled
     * children (via ChildClass pivot), and each child's signalements through
     * the chain: Evaluation (ChildID + SignalementID) → Signalement.
     *
     * Data chain: Planning → Class (PlanningID) → ChildClass → Child
     *             → Evaluation (ChildID, SignalementID) → Signalement
     *
     * The teacher who reported is resolved by looking up the TeacherClass
     * pivot for the child's class, then joining to Account for the name.
     *
     * @group Admin - Reports & AI Analysis
     * @authenticated
     *
     * @urlParam id integer required The PlanningID of the academic year. Example: 2
     *
     * @response 200 {
     *   "classes": [
     *     {
     *       "class_id": 5,
     *       "class_name": "Moyenne Section B",
     *       "children": [
     *         {
     *           "child_id": 102,
     *           "child_name": "Youssef Mejri",
     *           "signalements": [
     *             {
     *               "id": 1,
     *               "alert_type": "Comportement",
     *               "comment": "Comportement agressif envers un camarade.",
     *               "incident_time": "2026-01-15",
     *               "teacher_name": "Fatma Mrad"
     *             }
     *           ]
     *         }
     *       ]
     *     }
     *   ]
     * }
     */
    public function getReport(int $id): JsonResponse
    {
        $planning = DB::table('Planning')->where('PlanningID', $id)->first();
        if (!$planning) {
            return response()->json([
                'classes' => []
            ]);
        }

        $planningStart = $planning->Startdate ?? null;
        $planningEnd = $planning->Enddate ?? null;

        // 1. Get all classes for the given planning (including archived if it's an old planning)
        $classes = DB::table('Class')
            ->where('PlanningID', $id)
            ->select('ClassID', 'Name')
            ->get();

        $result = [];

        foreach ($classes as $class) {
            // 2. Get all children enrolled in this class via ChildClass pivot
            $children = DB::table('ChildClass')
                ->join('Child', 'ChildClass.ChildID', '=', 'Child.ChildID')
                ->where('ChildClass.ClassID', $class->ClassID)
                ->select('Child.ChildID', 'Child.Firstname', 'Child.Lastname')
                ->get();

            // 3. Get the teacher(s) assigned to this class for teacher_name resolution
            $teachers = DB::table('TeacherClass')
                ->join('Account', function ($join) {
                    $join->on('TeacherClass.TeacherID', '=', 'Account.PersonID')
                         ->where('Account.RoleID', 1);
                })
                ->where('TeacherClass.ClassID', $class->ClassID)
                ->select('Account.Firstname as teacher_first', 'Account.Lastname as teacher_last')
                ->get();

            $teacherName = $teachers->isNotEmpty()
                ? $teachers->first()->teacher_first . ' ' . $teachers->first()->teacher_last
                : 'Enseignant inconnu';

            $childrenData = [];

            foreach ($children as $child) {
                // 4. Get signalements for this child via Evaluation → Signalement chain
                $signalementsQuery = DB::table('Evaluation')
                    ->join('Signalement', 'Evaluation.SignalementID', '=', 'Signalement.SignalementID')
                    ->where('Evaluation.ChildID', $child->ChildID)
                    ->whereNotNull('Evaluation.SignalementID')
                    ->select(
                        'Signalement.SignalementID as id',
                        'Signalement.Comment as comment',
                        'Signalement.Incident_date as incident_time',
                        'Evaluation.Activtitytitlesnapshot as alert_type',
                        'Signalement.ReportanalysishistoryID'
                    );

                if ($planningStart && $planningEnd) {
                    $signalementsQuery->whereBetween('Signalement.Incident_date', [$planningStart, $planningEnd]);
                }

                $signalements = $signalementsQuery
                    ->orderBy('Signalement.Incident_date', 'desc')
                    ->get()
                    ->map(function ($sig) use ($teacherName) {
                        return [
                            'id' => $sig->id,
                            'alert_type' => $sig->alert_type ?: 'Signalement',
                            'comment' => $sig->comment,
                            'incident_time' => $sig->incident_time,
                            'teacher_name' => $teacherName,
                        ];
                    });

                $childrenData[] = [
                    'child_id' => $child->ChildID,
                    'child_name' => $child->Firstname . ' ' . $child->Lastname,
                    'signalements' => $signalements->values()->toArray(),
                ];
            }

            $result[] = [
                'class_id' => $class->ClassID,
                'class_name' => $class->Name,
                'children' => $childrenData,
            ];
        }

        return response()->json([
            'classes' => $result
        ]);
    }

    /**
     * Get Analysis History
     *
     * Retrieves previously saved AI behavioral analysis results from the
     * Reportanalysishistory table. The link goes through:
     * Signalement.ReportanalysishistoryID → Reportanalysishistory.
     *
     * For a given planning, we find all signalements of children enrolled in
     * that planning's classes, collect the distinct ReportanalysishistoryIDs,
     * and return those analysis results.
     *
     * The frontend uses `analyzed_signalement_ids` to track which signalements
     * have already been processed by AI.
     *
     * @group Admin - Reports & AI Analysis
     * @authenticated
     *
     * @queryParam planning_id integer required The PlanningID to filter by. Example: 2
     *
     * @response 200 {
     *   "data": [
     *     {
     *       "id": 1,
     *       "analysis_result": "{\"nom\":\"Youssef\",\"synthese\":\"...\",\"recommandations\":\"...\"}",
     *       "analyzed_signalement_ids": [1, 3, 7],
     *       "date": "2026-01-20"
     *     }
     *   ]
     * }
     */
    public function getAnalysisHistory(Request $request): JsonResponse
    {
        $planningId = $request->query('planning_id');

        if (!$planningId) {
            return response()->json(['data' => []]);
        }

        $planning = DB::table('Planning')->where('PlanningID', $planningId)->first();
        if (!$planning) {
            return response()->json(['data' => []]);
        }

        $planningStart = $planning->Startdate ?? null;
        $planningEnd = $planning->Enddate ?? null;

        // Find all children in classes of this planning
        $childIds = DB::table('ChildClass')
            ->join('Class', 'ChildClass.ClassID', '=', 'Class.ClassID')
            ->where('Class.PlanningID', $planningId)
            ->pluck('ChildClass.ChildID')
            ->unique();

        if ($childIds->isEmpty()) {
            return response()->json(['data' => []]);
        }

        // Find all signalements for those children via Evaluation and grab Child details
        $signalementsQuery = DB::table('Evaluation')
            ->join('Signalement', 'Evaluation.SignalementID', '=', 'Signalement.SignalementID')
            ->join('Child', 'Evaluation.ChildID', '=', 'Child.ChildID')
            ->whereIn('Evaluation.ChildID', $childIds)
            ->whereNotNull('Signalement.ReportanalysishistoryID')
            ->select(
                'Signalement.ReportanalysishistoryID',
                'Signalement.SignalementID',
                'Child.ChildID as child_id',
                'Child.Firstname as child_first_name',
                'Child.Lastname as child_last_name'
            );

        if ($planningStart && $planningEnd) {
            $signalementsQuery->whereBetween('Signalement.Incident_date', [$planningStart, $planningEnd]);
        }

        $signalements = $signalementsQuery->get();

        // Group signalement IDs by their analysis history entry
        $grouped = $signalements->groupBy('ReportanalysishistoryID');

        if ($grouped->isEmpty()) {
            return response()->json(['data' => []]);
        }

        // Fetch the actual analysis history rows
        $historyIds = $grouped->keys()->toArray();
        $histories = DB::table('Reportanalysishistory')
            ->whereIn('ReportanalysishistoryID', $historyIds)
            ->get();

        $data = $histories->map(function ($h) use ($grouped) {
            $sigs = $grouped->get($h->ReportanalysishistoryID, collect());
            $sigIds = $sigs->pluck('SignalementID')->values()->toArray();
            
            // All signalements grouped under the same history row belong to the exact same child,
            // so we safely read details from the first matching evaluation.
            $firstSig = $sigs->first();

            return [
                'id' => $h->ReportanalysishistoryID,
                'child_id' => $firstSig ? $firstSig->child_id : null,
                'child_first_name' => $firstSig ? $firstSig->child_first_name : null,
                'child_last_name' => $firstSig ? $firstSig->child_last_name : null,
                'analysis_result' => $h->Analysisresult,
                'analyzed_signalement_ids' => $sigIds,
                'date' => $h->Date,
            ];
        });

        return response()->json([
            'data' => $data->values()->toArray()
        ]);
    }

    /**
     * Store Analysis History
     *
     * Saves one child's AI behavioral analysis result to the
     * Reportanalysishistory table. Then links the specified SignalementIDs
     * to that history row via Signalement.ReportanalysishistoryID FK.
     *
     * DB Tables:
     *   Reportanalysishistory: ReportanalysishistoryID (PK), Analysisresult (text), Date
     *   Signalement: ReportanalysishistoryID (FK → Reportanalysishistory)
     *
     * @group Admin - Reports & AI Analysis
     * @authenticated
     *
     * @bodyParam planning_id integer required The PlanningID scope. Example: 2
     * @bodyParam child_id integer required The ChildID analyzed. Example: 102
     * @bodyParam analysis_result string required Serialized JSON of AI analysis. Example: {"nom":"Youssef","synthese":"...","recommandations":"..."}
     * @bodyParam analyzed_signalement_ids array required Array of SignalementIDs included. Example: [1, 3, 7]
     *
     * @response 201 {
     *   "success": true,
     *   "data": {
     *     "ReportanalysishistoryID": 5,
     *     "Analysisresult": "{\"nom\":\"Youssef\",\"synthese\":\"...\",\"recommandations\":\"...\"}",
     *     "Date": "2026-04-06"
     *   }
     * }
     */
    public function storeAnalysisHistory(Request $request): JsonResponse
    {
        $request->validate([
            'analysis_result' => 'required|string',
            'analyzed_signalement_ids' => 'nullable|array',
            'analyzed_signalement_ids.*' => 'integer',
        ]);

        DB::beginTransaction();
        try {
            // 1. Create the analysis history entry
            $historyId = DB::table('Reportanalysishistory')->insertGetId([
                'Analysisresult' => $request->input('analysis_result'),
                'Date' => now()->toDateString(),
            ]);

            // 2. Link signalements to this analysis history via ReportanalysishistoryID FK
            $sigIds = $request->input('analyzed_signalement_ids', []);
            if (!empty($sigIds)) {
                DB::table('Signalement')
                    ->whereIn('SignalementID', $sigIds)
                    ->update(['ReportanalysishistoryID' => $historyId]);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'data' => [
                    'ReportanalysishistoryID' => $historyId,
                    'Analysisresult' => $request->input('analysis_result'),
                    'Date' => now()->toDateString(),
                ]
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Error saving analysis: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * AI Analyze Reports
     *
     * Forwards aggregated behavioral incident text to the local Copilot AI
     * proxy server (Node.js at localhost:3000) for structured pedagogical
     * analysis. The AI returns a JSON string containing per-student synthesis
     * and recommendations.
     *
     * @group Admin - Reports & AI Analysis
     * @authenticated
     *
     * @bodyParam childrenText string required Aggregated text of children and signalements. Example: "Élève: Youssef (Classe: MSB)\n  Signalements:\n  - Type: Warning | \"Agressif\" (01/15/2026)"
     * @bodyParam max_tokens integer optional Maximum tokens for the AI response. Example: 3500
     *
     * @response 200 {
     *   "output": "{\"eleves\":[{\"nom\":\"Youssef\",\"classe\":\"MSB\",\"synthese\":\"Comportement impulsif récurrent.\",\"recommandations\":\"Suivi psychologique recommandé.\"}],\"remarques\":[\"Augmentation globale des incidents ce trimestre.\"]}"
     * }
     */
    public function analyzeReports(Request $request): JsonResponse
    {
        $request->validate([
            'childrenText' => 'required|string',
            'max_tokens' => 'nullable|integer',
        ]);

        $prompt = "Tu es un assistant pédagogique expert en petite enfance. Analyse les signalements comportementaux suivants et génère un rapport structuré en JSON avec le format exact:\n"
            . "{\"eleves\": [{\"nom\": \"...\", \"classe\": \"...\", \"synthese\": \"...\", \"recommandations\": \"...\"}], \"remarques\": [\"...\"]}\n\n"
            . "Voici les données:\n\n"
            . $request->input('childrenText');

        $copilotUrl = rtrim((string) config('services.copilot.url', 'http://localhost:4141'), '/') . '/v1/chat/completions';

        try {
            $response = Http::timeout(60)
                ->acceptJson()
                ->post($copilotUrl, [
                    'model' => 'gpt-4.1',
                    'messages' => [
                        [
                            'role' => 'user',
                            'content' => $prompt,
                        ],
                    ],
                ]);

            if ($response->successful()) {
                $output = trim((string) data_get($response->json(), 'choices.0.message.content', ''));
                return response()->json([
                    'output' => $output,
                ]);
            }

            return response()->json([
                'output' => json_encode(['eleves' => [], 'remarques' => []]),
                'message' => 'AI server returned an error.',
            ], 500);

        } catch (\Exception $e) {
            return response()->json([
                'output' => json_encode(['eleves' => [], 'remarques' => []]),
                'message' => 'Could not connect to AI proxy: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get Dashboard Statistics
     *
     * Aggregates configuration flags and specific system parameters required
     * by the dashboard to show alerts (like the end of year archiving banner).
     *
     * @group Admin - Report Analysis
     * @authenticated
     *
     * @response 200 {
     *   "data": {
     *     "year_ended": true,
     *     "year_ended_message": "L'année scolaire est terminée. Veuillez archiver.",
     *     "year_archived": false
     *   }
     * }
     */
    public function getDashboardStats(Request $request): JsonResponse
    {
        $activeYear = DB::table('Planning')
            ->where('Isarchived', 0)->first();

        return response()->json([
            'data' => [
                'year_ended' => $activeYear ? false : true,
                'year_ended_message' => $activeYear ? null : "L'année scolaire est terminée.",
                'year_archived' => false,
            ]
        ]);
    }

    /**
     * List Report Analyses (Legacy)
     *
     * Retrieves all AI-generated behavioral report analyses from the
     * Reportanalysishistory table ordered by date descending.
     *
     * @group Admin - Report Analysis
     * @authenticated
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Report analysis history retrieved.",
     *   "data": []
     * }
     */
    public function index(Request $request): JsonResponse
    {
        $histories = DB::table('Reportanalysishistory')
            ->orderBy('Date', 'desc')
            ->get()
            ->map(function ($h) {
                return [
                    'id' => $h->ReportanalysishistoryID,
                    'analysis_result' => $h->Analysisresult,
                    'date' => $h->Date,
                ];
            });

        return response()->json([
            'success' => true,
            'message' => 'Report analysis history retrieved.',
            'data' => $histories->values()->toArray()
        ]);
    }

    /**
     * Show Report Analysis Detail (Legacy)
     *
     * Retrieves a specific AI behavioral report analysis by its
     * ReportanalysishistoryID, including the linked signalement IDs.
     *
     * @group Admin - Report Analysis
     * @authenticated
     *
     * @urlParam id integer required The ReportanalysishistoryID. Example: 1
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Report analysis details.",
     *   "data": {
     *     "ReportanalysishistoryID": 1,
     *     "Analysisresult": "{...}",
     *     "Date": "2026-01-20",
     *     "signalement_ids": [1, 3]
     *   }
     * }
     */
    public function show(int $id): JsonResponse
    {
        $history = DB::table('Reportanalysishistory')
            ->where('ReportanalysishistoryID', $id)
            ->first();

        if (!$history) {
            return response()->json([
                'success' => false,
                'message' => 'Analysis not found.',
                'data' => null
            ], 404);
        }

        // Get the linked signalement IDs
        $sigIds = DB::table('Signalement')
            ->where('ReportanalysishistoryID', $id)
            ->pluck('SignalementID')
            ->toArray();

        return response()->json([
            'success' => true,
            'message' => 'Report analysis details.',
            'data' => [
                'ReportanalysishistoryID' => $history->ReportanalysishistoryID,
                'Analysisresult' => $history->Analysisresult,
                'Date' => $history->Date,
                'signalement_ids' => $sigIds,
            ]
        ]);
    }
}
