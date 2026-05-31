<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/**
 * @group Mobile - Signalements (Incident Reports)
 *
 * APIs for managing incident reports and pedagogical alerts for a child.
 */
class SignalementController extends Controller
{
    private function scopedSignalementEvaluations(int $childId)
    {
        $evaluationSchoolYearSql = "(CASE WHEN MONTH(Evaluation.Date) >= 7 THEN YEAR(Evaluation.Date) ELSE YEAR(Evaluation.Date) - 1 END)";
        $inscriptionSchoolYearSql = "(CASE WHEN MONTH(Inscription.Date) >= 7 THEN YEAR(Inscription.Date) ELSE YEAR(Inscription.Date) - 1 END)";

        return DB::table('Evaluation')
            ->join('Signalement', 'Evaluation.SignalementID', '=', 'Signalement.SignalementID')
            ->where('Evaluation.ChildID', $childId)
            ->whereNotNull('Evaluation.SignalementID')
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

    private function parseSignalementComment(?string $rawComment): array
    {
        $rawComment = trim((string) $rawComment);

        if ($rawComment !== '' && preg_match('/^\[(.+?)\]\s*(.*)$/', $rawComment, $matches)) {
            return [trim($matches[1]), trim($matches[2])];
        }

        return ['Standard', $rawComment];
    }

    private function matchesSignalementNotification(object $notif, array $signalement, int $childId): bool
    {
        $data = null;
        if (!empty($notif->Data)) {
            $decoded = json_decode($notif->Data, true);
            if (is_array($decoded)) {
                $data = $decoded;
            }
        }

        if (!$data) {
            return false;
        }

        if (($data['signalement_id'] ?? null) == $signalement['id']) {
            return true;
        }

        if (($data['child_id'] ?? null) != $childId) {
            return false;
        }

        if (($data['signalement_date'] ?? null) !== $signalement['incident_date']) {
            return false;
        }

        $notifType = trim((string) ($data['signalement_type'] ?? 'Standard'));
        $notifComment = trim((string) ($data['comment'] ?? ''));

        return strcasecmp($notifType, $signalement['alert_type']) === 0
            && strcmp($notifComment, $signalement['comment']) === 0;
    }

    /**
     * Get AI Medical Summaries by Child
     *
     * Returns the saved dietary and health AI summaries linked to the child's
     * medical form(s). If multiple forms exist, the newest non-empty comment is used.
     */
    public function aiSummaries($childId)
    {
        $medicalForms = DB::table('Medicalform')
            ->join('Payment', 'Medicalform.InscriptionID', '=', 'Payment.InscriptionID')
            ->leftJoin('Dietarycomment', 'Medicalform.DietarycommentID', '=', 'Dietarycomment.DietarycommentID')
            ->leftJoin('Healthcomment', 'Medicalform.HealthcommentID', '=', 'Healthcomment.HealthcommentID')
            ->where('Payment.ChildID', $childId)
            ->select(
                'Medicalform.MedicalformID',
                'Dietarycomment.Dietarycomment as dietary_comment',
                'Healthcomment.Healthcomment as health_comment'
            )
            ->orderByDesc('Medicalform.MedicalformID')
            ->get();

        $dietaryComment = $medicalForms
            ->pluck('dietary_comment')
            ->map(fn($value) => is_string($value) ? trim($value) : null)
            ->first(fn($value) => !empty($value));

        $healthComment = $medicalForms
            ->pluck('health_comment')
            ->map(fn($value) => is_string($value) ? trim($value) : null)
            ->first(fn($value) => !empty($value));

        return response()->json([
            'success' => true,
            'dietary_comment' => $dietaryComment,
            'health_comment' => $healthComment,
        ]);
    }

    /**
     * Get Signalements by Child
     *
     * Retrieves all incident reports associated with a specific child.
     *
     * @authenticated
     * @urlParam id int required The ID of the child. Example: 45
     * 
     * @response 200 {
     *   "success": true,
     *   "data": [
     *     {
     *       "id": 1,
     *       "child_id": 45,
     *       "teacher_id": 0,
     *       "activity_id": null,
     *       "alert_type": "Standard",
     *       "comment": "Blessure mineure",
     *       "incident_time": "2026-04-06 14:00:00",
     *       "activity": null,
     *       "teacher": null
     *     }
     *   ]
     * }
     */
    public function getByChild(Request $request, $childId)
    {
        $user = $request->user();
        $evals = $this->scopedSignalementEvaluations((int) $childId)
            ->orderByDesc('Evaluation.Date')
            ->get();

        $notifications = collect();
        if ($user && (int) ($user->RoleID ?? 0) === 3) {
            $notifications = DB::table('Notification')
                ->where('Recipientcin', $user->Cin)
                ->where('Recipientrole', 'parent')
                ->where('Type', 'signalement')
                ->orderByDesc('NotificationID')
                ->get();
        }

        $data = $evals->map(function ($ev) use ($notifications, $childId) {
            [$alertType, $comment] = $this->parseSignalementComment($ev->Comment);

            $signalement = [
                'id' => $ev->SignalementID,
                'child_id' => $ev->ChildID,
                'teacher_id' => 0, 
                'activity_id' => $ev->ActivityID,
                'alert_type' => $alertType,
                'comment' => $comment,
                'incident_time' => $ev->Incident_date,
                'incident_date' => $ev->Incident_date,
                'activity' => $ev->ActivityID ? [
                    'id' => $ev->ActivityID,
                    'title' => $ev->Activtitytitlesnapshot ?: 'Activité'
                ] : null,
                'teacher' => null
            ];

            $matchingNotifications = $notifications
                ->filter(fn($notif) => $this->matchesSignalementNotification($notif, $signalement, (int) $childId))
                ->values();

            $signalement['is_read'] = $matchingNotifications->isNotEmpty()
                && !$matchingNotifications->contains(fn($notif) => (int) $notif->Isread === 0);

            return $signalement;
        });

        if ($user && (int) ($user->RoleID ?? 0) === 3) {
            $data = $data->filter(fn($row) => !($row['is_read'] ?? false))->values();
        }

        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }

    public function markAsRead(Request $request, $childId)
    {
        $user = $request->user();
        if (!$user || (int) ($user->RoleID ?? 0) !== 3) {
            return response()->json(['success' => false, 'message' => 'Forbidden.'], 403);
        }

        $signalementIds = collect($request->input('signalement_ids', []))
            ->map(fn($id) => (int) $id)
            ->filter(fn($id) => $id > 0)
            ->values();

        if ($signalementIds->isEmpty()) {
            return response()->json(['success' => false, 'message' => 'No signalements provided.'], 422);
        }

        $childBelongsToParent = DB::table('Child')
            ->join('Account', 'Child.ParentID', '=', 'Account.PersonID')
            ->where('Child.ChildID', $childId)
            ->where('Account.Cin', $user->Cin)
            ->where('Account.RoleID', 3)
            ->exists();

        if (!$childBelongsToParent) {
            return response()->json(['success' => false, 'message' => 'Child not found.'], 404);
        }

        $signalements = $this->scopedSignalementEvaluations((int) $childId)
            ->whereIn('Evaluation.SignalementID', $signalementIds)
            ->get()
            ->map(function ($ev) {
                [$alertType, $comment] = $this->parseSignalementComment($ev->Comment);

                return [
                    'id' => (int) $ev->SignalementID,
                    'incident_date' => $ev->Incident_date,
                    'alert_type' => $alertType,
                    'comment' => $comment,
                ];
            })
            ->values();

        if ($signalements->isEmpty()) {
            return response()->json(['success' => false, 'message' => 'Signalements not found.'], 404);
        }

        $notifications = DB::table('Notification')
            ->where('Recipientcin', $user->Cin)
            ->where('Recipientrole', 'parent')
            ->where('Type', 'signalement')
            ->get();

        $notificationIds = $notifications
            ->filter(function ($notif) use ($signalements, $childId) {
                foreach ($signalements as $signalement) {
                    if ($this->matchesSignalementNotification($notif, $signalement, (int) $childId)) {
                        return true;
                    }
                }

                return false;
            })
            ->pluck('NotificationID')
            ->map(fn($id) => (int) $id)
            ->values();

        if ($notificationIds->isNotEmpty()) {
            DB::table('Notification')
                ->whereIn('NotificationID', $notificationIds)
                ->update(['Isread' => 1]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Signalements marked as read.',
        ]);
    }

    /**
     * Store Signalement
     *
     * Creates a new incident report for a child.
     *
     * @authenticated
     * @bodyParam child_id int required ID of the child. Example: 45
     * @bodyParam teacher_id int required Cin of the teacher. Example: 11112222
     * @bodyParam activity_id int optional ID of the related activity. Example: 1
     * @bodyParam alert_type string required Type of alert. Example: "Medical"
     * @bodyParam comment string optional Detail of the incident. Example: "Asthme"
     * @bodyParam incident_time string required Time of incident. Example: "2026-04-06T10:00:00"
     * 
     * @response 201 {
     *   "data": {
     *     "id": 1,
     *     "child_id": 45,
     *     "teacher_id": 11112222,
     *     "activity_id": 1,
     *     "alert_type": "Medical",
     *     "comment": "Asthme",
     *     "incident_time": "2026-04-06T10:00:00"
     *   }
     * }
     */
    public function store(Request $request)
    {
        $childId = $request->input('child_id');
        $activityId = $request->input('activity_id');
        $comment = $request->input('comment', '');
        $alertType = $request->input('alert_type', '');
        $date = $request->input('incident_time', date('Y-m-d H:i:s'));

        $fullComment = $alertType ? "[$alertType] $comment" : $comment;

        $sigId = DB::transaction(function () use ($childId, $activityId, $fullComment, $date, $alertType, $comment) {
            $signalementId = DB::table('Signalement')->insertGetId([
                'Comment' => $fullComment,
                'Incident_date' => date('Y-m-d', strtotime($date))
            ]);

            if ($activityId) {
                $activity = DB::table('Activity')->where('ActivityID', $activityId)->first();
                DB::table('Evaluation')->insert([
                    'ChildID' => $childId,
                    'ActivityID' => $activityId,
                    'SignalementID' => $signalementId,
                    'Date' => date('Y-m-d', strtotime($date)),
                    'Activtitytitlesnapshot' => $activity ? $activity->Title : ''
                ]);
            } else {
                DB::table('Evaluation')->insert([
                    'ChildID' => $childId,
                    'SignalementID' => $signalementId,
                    'Date' => date('Y-m-d', strtotime($date))
                ]);
            }

            $child = DB::table('Child')
                ->where('ChildID', $childId)
                ->first(['ChildID', 'Firstname', 'Lastname', 'ParentID']);

            if ($child && $child->ParentID) {
                $parentAccount = DB::table('Account')
                    ->where('PersonID', $child->ParentID)
                    ->where('RoleID', 3)
                    ->first(['Cin']);

                if ($parentAccount && !empty($parentAccount->Cin)) {
                    $childName = trim(($child->Firstname ?? '') . ' ' . ($child->Lastname ?? ''));
                    $trimmedComment = trim((string) $comment);
                    $message = $childName !== ''
                        ? "Un signalement de type {$alertType} a ete ajoute pour {$childName}."
                        : "Un nouveau signalement a ete ajoute pour votre enfant.";
                    if ($trimmedComment !== '') {
                        $message .= "\nDescription : {$trimmedComment}";
                    }

                     DB::table('Notification')->insert([
                         'Recipientcin' => $parentAccount->Cin,
                         'Recipientrole' => 'parent',
                        'Type' => 'signalement',
                        'Title' => 'Nouveau signalement',
                        'Message' => $message,
                         'Data' => json_encode([
                             'signalement_id' => $signalementId,
                             'child_id' => $childId,
                             'child_name' => $childName,
                             'signalement_type' => $alertType,
                            'comment' => $comment,
                            'signalement_date' => date('Y-m-d', strtotime($date)),
                        ]),
                        'Isread' => 0,
                    ]);
                }
            }

            return $signalementId;
        });

        return response()->json([
            'data' => [
                'id' => $sigId,
                'child_id' => $childId,
                'teacher_id' => $request->input('teacher_id'),
                'activity_id' => $activityId,
                'alert_type' => $alertType,
                'comment' => $comment,
                'incident_time' => $date
            ]
        ], 201);
    }
}
