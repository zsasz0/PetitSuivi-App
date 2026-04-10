<?php

namespace App\Http\Controllers\Api\Teacher;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SignalementController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        $signalements = \Illuminate\Support\Facades\DB::table('Signalement')
            ->join('Child', 'Signalement.ChildID', '=', 'Child.ChildID')
            ->join('ChildClass', 'Child.ChildID', '=', 'ChildClass.ChildID')
            ->join('TeacherClass', 'ChildClass.ClassID', '=', 'TeacherClass.ClassID')
            ->where('TeacherClass.TeacherID', $user->PersonID)
            ->select(
                'Signalement.SignalementID as id',
                'Signalement.ChildID as child_id',
                'Signalement.Type as type',
                'Signalement.Description as description',
                'Signalement.Date as date',
                'Child.Firstname as child_first',
                'Child.Lastname as child_last'
            )
            ->orderBy('Signalement.Date', 'desc')
            ->get();

        $formatted = [];
        foreach ($signalements as $s) {
            $formatted[] = [
                'id' => (string) $s->id,
                'child_id' => $s->child_id,
                'child_name' => $s->child_first . ' ' . $s->child_last,
                'type' => $s->type,
                'description' => $s->description,
                'date' => $s->date
            ];
        }

        return response()->json([
            'success' => true,
            'message' => 'Signalements retrieved.',
            'data' => $formatted
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'child_id' => 'required|integer',
            'type' => 'required|string|max:50',
            'description' => 'required|string',
            'date' => 'required|date'
        ]);

        DB::transaction(function () use ($validated, $request) {
            DB::table('Signalement')->insert([
                'ChildID' => $validated['child_id'],
                'Type' => $validated['type'],
                'Description' => $validated['description'],
                'Date' => $validated['date'],
                'Duration' => 0,
                'AccountID' => $request->user() ? $request->user()->AccountID : null
            ]);

            $child = DB::table('Child')
                ->where('ChildID', $validated['child_id'])
                ->first(['ChildID', 'Firstname', 'Lastname', 'ParentID']);

            if (!$child || !$child->ParentID) {
                return;
            }

            $parentAccount = DB::table('Account')
                ->where('PersonID', $child->ParentID)
                ->where('RoleID', 3)
                ->first(['Cin']);

            if (!$parentAccount || empty($parentAccount->Cin)) {
                return;
            }

            $childName = trim(($child->Firstname ?? '') . ' ' . ($child->Lastname ?? ''));
            $title = 'Nouveau signalement';
            $message = $childName !== ''
                ? "Un signalement de type {$validated['type']} a ete ajoute pour {$childName}."
                : "Un signalement de type {$validated['type']} a ete ajoute pour votre enfant.";

            DB::table('Notification')->insert([
                'Recipientcin' => $parentAccount->Cin,
                'Recipientrole' => 'parent',
                'Type' => 'signalement',
                'Title' => $title,
                'Message' => $message,
                'Data' => json_encode([
                    'child_id' => $validated['child_id'],
                    'child_name' => $childName,
                    'signalement_type' => $validated['type'],
                    'signalement_date' => $validated['date'],
                ], JSON_UNESCAPED_UNICODE),
                'Isread' => 0,
            ]);
        });

        return response()->json([
            'success' => true,
            'message' => 'Incident reported successfully.',
            'data' => null
        ], 201);
    }
}
