<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use App\Mail\EventNotificationMail;
use App\Models\Events;
use App\Models\Notification;
use App\Models\NotificationAccount;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;

class EventController extends Controller
{
    private function buildEventNotificationData(Events $event): string
    {
        return json_encode([
            'event_id' => $event->EventsID,
            'event_name' => $event->Name,
            'event_description' => $event->Description,
            'event_date' => $event->Date,
            'event_start_time' => $event->Starttime,
            'event_end_time' => $event->Endtime,
            'status' => $event->Status,
        ], JSON_UNESCAPED_UNICODE);
    }

    private function resolveParentRecipientCins(array $targets): array
    {
        $classIds = collect($targets['classes'] ?? [])->filter()->map(fn ($id) => (int) $id)->values();
        $childIds = collect($targets['children'] ?? [])->filter()->map(fn ($id) => (int) $id)->values();

        $parentIds = collect();

        if ($classIds->isNotEmpty()) {
            $classParentIds = DB::table('ChildClass')
                ->join('Child', 'ChildClass.ChildID', '=', 'Child.ChildID')
                ->whereIn('ChildClass.ClassID', $classIds)
                ->whereNotNull('Child.ParentID')
                ->pluck('Child.ParentID');

            $parentIds = $parentIds->merge($classParentIds);
        }

        if ($childIds->isNotEmpty()) {
            $childParentIds = DB::table('Child')
                ->whereIn('ChildID', $childIds)
                ->whereNotNull('ParentID')
                ->pluck('ParentID');

            $parentIds = $parentIds->merge($childParentIds);
        }

        if ($parentIds->isEmpty()) {
            return [];
        }

        return DB::table('Account')
            ->where('RoleID', 3)
            ->whereIn('PersonID', $parentIds->unique()->values())
            ->whereNotNull('Cin')
            ->pluck('Cin')
            ->map(fn ($cin) => (string) $cin)
            ->unique()
            ->values()
            ->all();
    }

    private function resolveTeacherAccounts(array $targets)
    {
        $teacherCins = collect($targets['teachers'] ?? [])->filter()->map(fn ($cin) => (string) $cin)->values();

        if ($teacherCins->isEmpty()) {
            return collect();
        }

        return DB::table('Account')
            ->where('RoleID', 1)
            ->whereIn('Cin', $teacherCins)
            ->select('AccountID', 'Cin')
            ->get();
    }

    private function dispatchEventNotifications(Events $event, array $targets, bool $isUpdate = false): void
    {
        $data = $this->buildEventNotificationData($event);
        $title = 'Evenement scolaire';
        $message = sprintf(
            '%s le %s de %s a %s.',
            $event->Name,
            $event->Date,
            substr((string) $event->Starttime, 0, 5),
            substr((string) $event->Endtime, 0, 5)
        );

        foreach ($this->resolveParentRecipientCins($targets) as $parentCin) {
            Notification::create([
                'Recipientcin' => $parentCin,
                'Recipientrole' => 'parent',
                'EventsID' => $event->EventsID,
                'Title' => $title,
                'Message' => $message,
                'Type' => 'event',
                'Data' => $data,
                'Isread' => 0,
            ]);

            $parentEmail = DB::table('Account')
                ->where('RoleID', 3)
                ->where('Cin', $parentCin)
                ->value('Email');

            if (!empty($parentEmail)) {
                try {
                    Mail::to($parentEmail)->send(new EventNotificationMail($event));
                } catch (\Exception $mailException) {
                    Log::warning('Event email failed for parent: ' . $mailException->getMessage(), [
                        'parent_cin' => $parentCin,
                        'event_id' => $event->EventsID,
                    ]);
                }
            }
        }

        foreach ($this->resolveTeacherAccounts($targets) as $teacherAccount) {
            $notification = Notification::create([
                'Recipientcin' => $teacherAccount->Cin,
                'Recipientrole' => 'teacher',
                'EventsID' => $event->EventsID,
                'Title' => $title,
                'Message' => $message,
                'Type' => 'event',
                'Data' => $data,
                'Isread' => 0,
            ]);

            NotificationAccount::create([
                'AccountID' => $teacherAccount->AccountID,
                'NotificationID' => $notification->NotificationID,
            ]);

            $teacherEmail = DB::table('Account')
                ->where('RoleID', 1)
                ->where('Cin', $teacherAccount->Cin)
                ->value('Email');

            if (!empty($teacherEmail)) {
                try {
                    Mail::to($teacherEmail)->send(new EventNotificationMail($event));
                } catch (\Exception $mailException) {
                    Log::warning('Event email failed for teacher: ' . $mailException->getMessage(), [
                        'teacher_cin' => $teacherAccount->Cin,
                        'event_id' => $event->EventsID,
                    ]);
                }
            }
        }
    }

    /**
     * Get All Events
     *
     * Retrieves all events configured in the school.
     *
     * @group Admin - Events
     * @authenticated
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Events retrieved.",
     *   "data": [
     *     {
     *       "id": 1,
     *       "name": "Kermesse de fin d'année",
     *       "description": "Fête de fin d'année avec les parents.",
     *       "date": "2026-06-30",
     *       "start_time": "09:00:00",
     *       "end_time": "14:00:00",
     *       "status": "pending",
     *       "notifications_sent": false
     *     }
     *   ]
     * }
     */
    public function index(Request $request): JsonResponse
    {
        $events = Events::all()->map(function($e) {
            return [
                'id' => $e->EventsID,
                'name' => $e->Name,
                'description' => $e->Description,
                'date' => $e->Date,
                'start_time' => $e->Starttime,
                'end_time' => $e->Endtime,
                'status' => $e->Status,
                'notifications_sent' => (bool)$e->Notificationsend
            ];
        });

        return response()->json([
            'success' => true,
            'message' => 'Events retrieved.',
            'data' => $events
        ]);
    }

    /**
     * Create Event
     *
     * Creates a new school event. Returns warning if conflict.
     *
     * @group Admin - Events
     * @authenticated
     *
     * @bodyParam name string required The name of the event. Example: Kermesse
     * @bodyParam description string The description of the event. Example: Fête de fin d'année
     * @bodyParam date date required The date of the event (YYYY-MM-DD). Example: 2026-06-30
     * @bodyParam start_time string required The start time (HH:MM). Example: 09:00
     * @bodyParam end_time string required The end time (HH:MM). Example: 14:00
     * @bodyParam send_notifications boolean optional Flag to indicate if notifications should be sent to targeted parents/teachers. Example: false
     * @bodyParam notification_targets object optional JSON object with classes, teachers, and children arrays if send_notifications is true.
     *
     * @response 201 {
     *   "success": true,
     *   "message": "Event created.",
     *   "data": {
     *     "id": 2,
     *     "name": "Kermesse",
     *     "description": "Fête de fin d'année",
     *     "date": "2026-06-30",
     *     "start_time": "09:00",
     *     "end_time": "14:00",
     *     "status": "pending",
     *     "notifications_sent": false
     *   }
     * }
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'name' => 'required|string',
            'date' => 'required|date',
            'start_time' => 'required',
            'end_time' => 'required'
        ]);

        DB::beginTransaction();
        try {
            $event = Events::create([
                'Name' => $request->name,
                'Description' => $request->description,
                'Date' => $request->date,
                'Starttime' => $request->start_time,
                'Endtime' => $request->end_time,
                'Status' => 'pending',
                'Notificationsend' => $request->boolean('send_notifications') ? 1 : 0
            ]);

            if ($request->boolean('send_notifications')) {
                $this->dispatchEventNotifications(
                    $event,
                    (array) $request->input('notification_targets', []),
                    false
                );
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Event created.',
                'data' => [
                    'id' => $event->EventsID,
                    'name' => $event->Name,
                    'description' => $event->Description,
                    'date' => $event->Date,
                    'start_time' => $event->Starttime,
                    'end_time' => $event->Endtime,
                    'status' => $event->Status,
                    'notifications_sent' => (bool)$event->Notificationsend
                ]
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * Update Event
     *
     * Updates an existing school event and optionally dispatches notifications.
     *
     * @group Admin - Events
     * @authenticated
     *
     * @urlParam id integer required The ID of the event to update. Example: 1
     * @bodyParam name string required The name of the event. Example: Kermesse
     * @bodyParam description string The description of the event. Example: Fête de fin d'année
     * @bodyParam date date required The date of the event (YYYY-MM-DD). Example: 2026-06-30
     * @bodyParam start_time string required The start time (HH:MM). Example: 09:00
     * @bodyParam end_time string required The end time (HH:MM). Example: 14:00
     * @bodyParam send_notifications boolean optional Flag to indicate if notifications should be sent to targeted parents/teachers. Example: true
     * @bodyParam notification_targets object optional JSON object with classes, teachers, and children arrays if send_notifications is true.
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Event updated.",
     *   "data": {
     *     "id": 1,
     *     "name": "Kermesse",
     *     "description": "Fête de fin d'année",
     *     "date": "2026-06-30",
     *     "start_time": "09:00",
     *     "end_time": "14:00",
     *     "status": "pending",
     *     "notifications_sent": true
     *   }
     * }
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $request->validate([
            'name' => 'required|string',
            'date' => 'required|date',
            'start_time' => 'required',
            'end_time' => 'required'
        ]);

        DB::beginTransaction();
        try {
            $event = Events::findOrFail($id);
            $event->update([
                'Name' => $request->name,
                'Description' => $request->description,
                'Date' => $request->date,
                'Starttime' => $request->start_time,
                'Endtime' => $request->end_time,
                'Notificationsend' => $request->boolean('send_notifications') ? 1 : $event->Notificationsend
            ]);

            if ($request->boolean('send_notifications')) {
                $this->dispatchEventNotifications(
                    $event,
                    (array) $request->input('notification_targets', []),
                    true
                );
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Event updated.',
                'data' => [
                    'id' => $event->EventsID,
                    'name' => $event->Name,
                    'description' => $event->Description,
                    'date' => $event->Date,
                    'start_time' => $event->Starttime,
                    'end_time' => $event->Endtime,
                    'status' => $event->Status,
                    'notifications_sent' => (bool)$event->Notificationsend
                ]
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * Delete Event
     *
     * Deletes an event from the database.
     *
     * @group Admin - Events
     * @authenticated
     *
     * @urlParam id integer required The ID of the event. Example: 1
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Event removed.",
     *   "data": null
     * }
     */
    public function destroy(int $id): JsonResponse
    {
        DB::beginTransaction();
        try {
            $notificationIds = Notification::where('EventsID', $id)->pluck('NotificationID');

            if ($notificationIds->isNotEmpty()) {
                NotificationAccount::whereIn('NotificationID', $notificationIds)->delete();
                Notification::whereIn('NotificationID', $notificationIds)->delete();
            }

            $event = Events::findOrFail($id);
            $event->delete();
            
            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Event removed.',
                'data' => null
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * Toggle Event Status
     *
     * Flips the status between "pending" and "executed".
     *
     * @group Admin - Events
     * @authenticated
     *
     * @urlParam id integer required The ID of the event. Example: 1
     * @bodyParam status string required The new status ('pending' or 'executed'). Example: executed
     *
     * @response 200 {
     *   "success": true,
     *   "message": "Status updated.",
     *   "data": null
     * }
     */
    public function updateStatus(Request $request, int $id): JsonResponse
    {
        $request->validate([
            'status' => 'required|in:pending,executed'
        ]);

        $event = Events::findOrFail($id);
        $event->update(['Status' => $request->status]);

        return response()->json([
            'success' => true,
            'message' => 'Status updated.',
            'data' => null
        ]);
    }

    /**
     * Check Conflict
     *
     * Checks if the given date and time range overlaps with any existing activities or events.
     *
     * @group Admin - Events
     * @authenticated
     *
     * @queryParam date required The date of the new event. Example: 2026-06-30
     * @queryParam start_time required The start time. Example: 09:00
     * @queryParam end_time required The end time. Example: 14:00
     * @queryParam exclude_event_id integer optional The ID of the event being edited to ignore it in conflict check. Example: 1
     *
     * @response 200 {
     *   "has_conflict": false,
     *   "activity_conflicts": [],
     *   "event_conflicts": []
     * }
     */
    public function checkConflict(Request $request): JsonResponse
    {
        $request->validate([
            'date' => 'required|date',
            'start_time' => 'required',
            'end_time' => 'required'
        ]);

        $date = $request->date;
        $start = $request->start_time;
        $end = $request->end_time;
        $excludeId = $request->exclude_event_id;

        $eventQuery = Events::where('Date', $date)
            ->where(function($q) use ($start, $end) {
                $q->where('Starttime', '<', $end)
                  ->where('Endtime', '>', $start);
            });
            
        if ($excludeId) {
            $eventQuery->where('EventsID', '!=', $excludeId);
        }

        $eventConflicts = $eventQuery->get()->map(function($e) {
            return [
                'name' => $e->Name,
                'start_time' => $e->Starttime,
                'end_time' => $e->Endtime
            ];
        });

        $activityConflicts = DB::table('Plandayactivity as pa')
            ->join('Planday as pd', 'pa.PlandayID', '=', 'pd.PlandayID')
            ->join('Activity as a', 'pa.ActivityID', '=', 'a.ActivityID')
            ->where('pd.Date', '=', $date)
            ->where('pa.Starttime', '<', $end)
            ->where('pa.Endtime', '>', $start)
            ->select('a.Title as title', 'pa.Starttime as startTime', 'pa.Endtime as endTime')
            ->get();

        $hasConflict = $eventConflicts->isNotEmpty() || $activityConflicts->isNotEmpty();

        return response()->json([
            'has_conflict' => $hasConflict,
            'activity_conflicts' => $activityConflicts,
            'event_conflicts' => $eventConflicts
        ]);
    }

    /**
     * Get Upcoming Events
     *
     * Retrieves upcoming academic and extra-curricular scheduled events.
     *
     * @group Admin - Events
     * @authenticated
     *
     * @response 200 {
     *   "data": [
     *     {
     *       "EventID": 44,
     *       "name": "Kermesse Annuelle",
     *       "date": "2026-06-15",
     *       "start_time": "09:00:00",
     *       "end_time": "14:00:00",
     *       "status": "pending"
     *     }
     *   ]
     * }
     */
    public function upcoming(Request $request): JsonResponse
    {
        $events = Events::where('Date', '>=', now()->toDateString())
            ->get()->map(function($e) {
                return [
                    'EventID' => $e->EventsID,
                    'name' => $e->Name ?? 'Événement scolaire',
                    'date' => $e->Date,
                    'status' => $e->Status,
                    'start_time' => $e->Starttime ?? '08:00:00',
                    'end_time' => $e->Endtime ?? '12:00:00'
                ];
            });

        return response()->json([
            'data' => $events
        ]);
    }
}
