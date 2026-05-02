<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/**
 * @group Admin - Plannings
 *
 * APIs for managing academic years and cascading archival logic.
 */
class PlanningController extends Controller
{
    /**
     * List Academic Plannings
     *
     * Retrieves configured academic years to indicate the active operational year.
     *
     * @authenticated
     *
     * @response 200 {
     *   "data": [
     *     {
     *       "id": 2,
     *       "label": "2025-2026",
     *       "start_year": 2025,
     *       "end_year": 2026,
     *       "start_date": "2025-09-01",
     *       "end_date": "2026-06-30",
     *       "is_archived": false
     *     }
     *   ]
     * }
     */
    public function index(Request $request): JsonResponse
    {
        $classCounts = DB::table('Class')
            ->selectRaw('PlanningID, COUNT(*) as usage_count')
            ->groupBy('PlanningID')
            ->pluck('usage_count', 'PlanningID');

        $plandayCounts = DB::table('Planday')
            ->selectRaw('PlanningID, COUNT(*) as usage_count')
            ->groupBy('PlanningID')
            ->pluck('usage_count', 'PlanningID');

        $plannings = DB::table('Planning')
            ->orderByDesc('Startdate')
            ->get()
            ->map(function ($p) use ($classCounts, $plandayCounts) {
                $startDate = $p->Startdate ?? date('Y-m-d');
                $endDate   = $p->Enddate ?? date('Y-m-d');
                $startYear = (int) date('Y', strtotime($startDate));
                $endYear   = (int) date('Y', strtotime($endDate));
                $deleteMeta = $this->getPlanningDeleteMeta(
                    (int) $p->PlanningID,
                    (bool) ($p->Isarchived ?? false),
                    (int) ($classCounts[$p->PlanningID] ?? 0),
                    (int) ($plandayCounts[$p->PlanningID] ?? 0),
                );

                return [
                    'id'          => $p->PlanningID,
                    'label'       => $p->Label ?? ($startYear . '/' . $endYear),
                    'start_year'  => $startYear,
                    'end_year'    => $endYear,
                    'start_date'  => $startDate,
                    'end_date'    => $endDate,
                    'is_archived' => (bool) ($p->Isarchived ?? false),
                    'classes_count' => $deleteMeta['classes_count'],
                    'plandays_count' => $deleteMeta['plandays_count'],
                    'is_deletable' => $deleteMeta['is_deletable'],
                    'delete_blockers' => $deleteMeta['delete_blockers'],
                ];
            });

        return response()->json([
            'data' => $plannings
        ]);
    }

    /**
     * Create Academic Planning
     *
     * Creates a new academic year mapping.
     *
     * @authenticated
     * @bodyParam startDate date required The starting date.
     * @bodyParam endDate date required The ending date.
     * @bodyParam label string The label defining this academic year (e.g. 2024-2025).
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'startDate' => 'required|date',
            'endDate'   => 'required|date',
            'label'     => 'nullable|string',
        ]);

        $planningId = DB::table('Planning')->insertGetId([
            'Startdate'  => $validated['startDate'],
            'Enddate'    => $validated['endDate'],
            'Label'      => $validated['label'] ?? null,
            'Isarchived' => 0,
        ]);

        $planning = DB::table('Planning')->where('PlanningID', $planningId)->first();

        return response()->json([
            'success' => true,
            'message' => 'Planning created.',
            'data'    => $this->mapPlanning($planning)
        ], 201);
    }

    /**
     * Show Academic Planning
     *
     * Provides details of a specific planning.
     *
     * @authenticated
     * @urlParam id int required The ID of the planning.
     */
    public function show(int $id): JsonResponse
    {
        $planning = DB::table('Planning')->where('PlanningID', $id)->first();
        if (!$planning) {
            return response()->json(['message' => 'Planning not found'], 404);
        }

        return response()->json([
            'success' => true,
            'data'    => $this->mapPlanning($planning)
        ]);
    }

    /**
     * Update Academic Planning
     *
     * Applies changes to an existing planning configuration.
     *
     * @authenticated
     * @urlParam id int required The ID of the planning.
     * @bodyParam startDate date required The starting date.
     * @bodyParam endDate date required The ending date.
     * @bodyParam label string The label defining this academic year.
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $validated = $request->validate([
            'startDate' => 'required|date',
            'endDate'   => 'required|date',
            'label'     => 'nullable|string',
        ]);

        DB::table('Planning')
            ->where('PlanningID', $id)
            ->update([
                'Startdate' => $validated['startDate'],
                'Enddate'   => $validated['endDate'],
                'Label'     => $validated['label'] ?? null,
            ]);

        $planning = DB::table('Planning')->where('PlanningID', $id)->first();

        return response()->json([
            'success' => true,
            'message' => 'Planning updated.',
            'data'    => $this->mapPlanning($planning)
        ]);
    }

    /**
     * Delete Academic Planning
     *
     * Completely removes a planning mapping.
     *
     * @authenticated
     * @urlParam id int required The ID of the planning.
     */
    public function destroy(int $id): JsonResponse
    {
        $planning = DB::table('Planning')->where('PlanningID', $id)->first();
        if (!$planning) {
            return response()->json(['success' => false, 'message' => 'Planning not found.'], 404);
        }

        $deleteMeta = $this->getPlanningDeleteMeta(
            $id,
            (bool) ($planning->Isarchived ?? false),
            (int) DB::table('Class')->where('PlanningID', $id)->count(),
            (int) DB::table('Planday')->where('PlanningID', $id)->count(),
        );

        if (!$deleteMeta['is_deletable']) {
            return response()->json([
                'success' => false,
                'message' => $this->getDeleteBlockedMessage($deleteMeta['delete_blockers']),
                'delete_blockers' => $deleteMeta['delete_blockers'],
            ], 409);
        }

        DB::table('Planning')->where('PlanningID', $id)->delete();

        return response()->json([
            'success' => true,
            'message' => 'Planning deleted.'
        ]);
    }

    /**
     * Archive Current School Year
     *
     * Effectively concludes the active school year. It identifies the operational planning
     * (Isarchived = 0), and securely updates both associated Classes and active Inscriptions
     * to reflect the archival before closing the overall Planning state.
     *
     * @authenticated
     */
    public function archiveCurrentYear(Request $request): JsonResponse
    {
        $activePlanning = DB::table('Planning')->where('Isarchived', 0)->first();

        if (!$activePlanning) {
            return response()->json([
                'message' => 'Aucune année scolaire active à archiver.'
            ], 404);
        }

        $stats = [
            'classes_archived' => 0,
            'inscriptions_archived' => 0
        ];

        $planningId = $activePlanning->PlanningID;

        DB::transaction(function () use ($planningId, &$stats) {
            // Close active classes attached to this planning
            $stats['classes_archived'] = DB::table('Class')
                ->where('PlanningID', $planningId)
                ->where('Isarchived', 0)
                ->update(['Isarchived' => 1]);

            // Close all active inscriptions generally linked to the current era
            $stats['inscriptions_archived'] = DB::table('Inscription')
                ->where('Isarchived', 0)
                ->update(['Isarchived' => 1]);

            // Flag the planning itself as archived
            DB::table('Planning')
                ->where('PlanningID', $planningId)
                ->update(['Isarchived' => 1]);
        });

        return response()->json([
            'success' => true,
            'message' => 'Année scolaire archivée avec succès.',
            'stats'   => $stats
        ]);
    }

    /**
     * Helper mapping entity to JSON response format.
     */
    private function mapPlanning($p): array
    {
        $startDate = $p->Startdate ?? date('Y-m-d');
        $endDate   = $p->Enddate ?? date('Y-m-d');
        $startYear = (int) date('Y', strtotime($startDate));
        $endYear   = (int) date('Y', strtotime($endDate));

        return [
            'id'          => $p->PlanningID,
            'label'       => $p->Label ?? ($startYear . '/' . $endYear),
            'start_year'  => $startYear,
            'end_year'    => $endYear,
            'start_date'  => $startDate,
            'end_date'    => $endDate,
            'is_archived' => (bool) ($p->Isarchived ?? false),
        ];
    }

    private function getPlanningDeleteMeta(int $planningId, bool $isArchived, int $classesCount, int $plandaysCount): array
    {
        $deleteBlockers = [];

        if ($isArchived) {
            $deleteBlockers[] = 'archived';
        }

        if ($classesCount > 0) {
            $deleteBlockers[] = 'has_classes';
        }

        if ($plandaysCount > 0) {
            $deleteBlockers[] = 'has_plandays';
        }

        return [
            'planning_id' => $planningId,
            'classes_count' => $classesCount,
            'plandays_count' => $plandaysCount,
            'is_deletable' => count($deleteBlockers) === 0,
            'delete_blockers' => $deleteBlockers,
        ];
    }

    private function getDeleteBlockedMessage(array $deleteBlockers): string
    {
        if (in_array('archived', $deleteBlockers, true)) {
            return 'Impossible de supprimer une année scolaire archivée.';
        }

        if (in_array('has_classes', $deleteBlockers, true)) {
            return 'Impossible de supprimer cette année scolaire car des classes y sont rattachées.';
        }

        if (in_array('has_plandays', $deleteBlockers, true)) {
            return 'Impossible de supprimer cette année scolaire car des jours planifiés y sont rattachés.';
        }

        return 'Impossible de supprimer cette année scolaire.';
    }
}
