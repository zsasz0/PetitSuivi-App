<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RegistrationController extends Controller
{
    /**
     * List Registrations (Inscriptions)
     *
     * Retrieves all registrations including nested child and class relationships.
     * Used to calculate approved children and display recent inscription activity.
     *
     * @group Admin - Registrations
     * @authenticated
     *
     * @response 200 {
     *   "data": [
     *     {
     *       "RegistrationID": 88,
     *       "inscription_date": "2025-08-15",
     *       "status": "approved",
     *       "child_full_name": "Youssef Mejri",
     *       "ChildID": 102,
     *       "child": {
     *         "ChildID": 102,
     *         "firstName": "Youssef",
     *         "lastName": "Mejri"
     *       },
     *       "ClassID": 5,
     *       "class": {
     *         "ClassID": 5,
     *         "name": "Moyenne Section B"
     *       }
     *     }
     *   ]
     * }
     */
    public function index(Request $request): JsonResponse
    {
        $inscriptions = \Illuminate\Support\Facades\DB::table('Inscription')
            ->leftJoin('Payment', 'Inscription.InscriptionID', '=', 'Payment.InscriptionID')
            ->leftJoin('Child', 'Payment.ChildID', '=', 'Child.ChildID')
            ->select('Inscription.*', 'Child.Firstname', 'Child.Lastname', 'Child.ChildID')
            ->get()->map(function($insc) {
                $insc->child_full_name = trim(($insc->Firstname ?? '') . ' ' . ($insc->Lastname ?? ''));
                $insc->inscription_date = $insc->Date;
                $insc->status = 'approved';
                return $insc;
            });
            
        return response()->json([
            'success' => true,
            'data' => $inscriptions
        ]);
    }

    /**
     * Show details of a specific enrollment.
     */
    public function show(int $id): JsonResponse
    {
        // TODO: Delegate to RegistrationService->findById($id)

        return response()->json([
            'success' => true,
            'message' => 'Registration details.',
            'data' => null
        ]);
    }

    /**
     * Approve a child enrollment.
     * Expected business logic: change status in registrations table,
     * create a new record in students table.
     */
    public function approve(Request $request, int $id): JsonResponse
    {
        // TODO: Delegate to RegistrationService->approveRegistration($id)

        return response()->json([
            'success' => true,
            'message' => 'Registration successfully approved and student record created.',
            'data' => null
        ]);
    }

    /**
     * Reject a child enrollment.
     */
    public function reject(int $id): JsonResponse
    {
        // TODO: Delegate to RegistrationService->rejectRegistration($id)

        return response()->json([
            'success' => true,
            'message' => 'Registration rejected.',
            'data' => null
        ]);
    }
}
