<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\Auth\AuthController;

// Public Authentication
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);
Route::post('/register/check-email', [AuthController::class, 'checkRegistrationEmail']);

// Mobile Auth
Route::post('/login/teacher', [AuthController::class, 'teacherLogin']);
Route::post('/login/parent', [AuthController::class, 'parentLogin']);

// Public registration endpoints
Route::get('/parameters', [\App\Http\Controllers\Api\Mobile\Parent\ParentSupportController::class, 'index']);
Route::get('/payment-methods', [\App\Http\Controllers\Api\Mobile\Parent\ParentPaymentMethodsController::class, 'index']);

// Public planning status check (no auth required)
Route::get('/plannings/active-check', function () {
    $hasActive = \Illuminate\Support\Facades\DB::table('Planning')
        ->where('Isarchived', 0)
        ->exists();

    return response()->json(['has_active' => $hasActive]);
});

// Authenticated Shared Routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);

    // Mobile: Classes & Presences
    Route::get('/teachers/{cin}/classes/by-planning', [\App\Http\Controllers\Api\Mobile\ManageClassesController::class, 'classesByPlanning']);
    Route::get('/teachers/{cin}/classes', [\App\Http\Controllers\Api\Mobile\ManageClassesController::class, 'classesByPlanning']); // Alias
    Route::get('/teachers/{cin}/classes/{classId}/activities', [\App\Http\Controllers\Api\Mobile\Teacher\DailyPlanController::class, 'activitiesByClass']);
    Route::patch('/teachers/{cin}/classes/{classId}/activities/{activityId}/status', function (\Illuminate\Http\Request $request, $cin, $classId, $activityId) {
        return app(\App\Http\Controllers\Api\Mobile\Teacher\DailyPlanController::class)->updateStatus($request, $activityId);
    });
    
    Route::get('/classes/{classId}/presences', [\App\Http\Controllers\Api\Mobile\ClassAttendanceController::class, 'index']);
    Route::post('/classes/{classId}/presences', [\App\Http\Controllers\Api\Mobile\ClassAttendanceController::class, 'store']);
    Route::put('/classes/{classId}/presences/{presenceId}', [\App\Http\Controllers\Api\Mobile\ClassAttendanceController::class, 'update']);
    
    // Mobile: Evaluations
    Route::get('/classes/{classId}/students', [\App\Http\Controllers\Api\Mobile\ManageClassesController::class, 'students']);
    Route::get('/classes/{classId}/activities/date/{date}', [\App\Http\Controllers\Api\Mobile\ClassEvaluationController::class, 'activitiesByDate']);
    Route::get('/children/{id}/evaluations/date/{date}', [\App\Http\Controllers\Api\Mobile\ClassEvaluationController::class, 'evaluationsByDate']);
    Route::get('/children/{id}/evaluations/parent-view', [\App\Http\Controllers\Api\Mobile\ClassEvaluationController::class, 'parentViewChildEvaluations']);
    Route::post('/evaluations', [\App\Http\Controllers\Api\Mobile\ClassEvaluationController::class, 'storeSingle']);
    Route::post('/evaluations/bulk', [\App\Http\Controllers\Api\Mobile\ClassEvaluationController::class, 'storeBulk']);

    // Mobile: Signalements (Alerts)
    Route::get('/children/{id}/signalements', [\App\Http\Controllers\Api\Mobile\SignalementController::class, 'getByChild']);
    Route::patch('/children/{id}/signalements/read', [\App\Http\Controllers\Api\Mobile\SignalementController::class, 'markAsRead']);
    Route::get('/children/{childId}/ai-summaries', [\App\Http\Controllers\Api\Mobile\SignalementController::class, 'aiSummaries']);
    Route::post('/signalements', [\App\Http\Controllers\Api\Mobile\SignalementController::class, 'store']);

    // ── Parent Mobile Routes ──
    Route::get('/parents/{cin}/children', [\App\Http\Controllers\Api\Mobile\Parent\ParentChildrenController::class, 'index']);
    Route::post('/parents/{cin}/children', [\App\Http\Controllers\Api\Mobile\Parent\ParentChildrenController::class, 'store']);
    Route::post('/parents/{cin}/children/{childId}/re-register', [\App\Http\Controllers\Api\Mobile\Parent\ParentChildrenController::class, 'reRegister']);
    Route::get('/parents/{cin}/profile', [\App\Http\Controllers\Api\Mobile\Parent\ParentProfileController::class, 'show']);
    Route::put('/parents/{cin}/profile', [\App\Http\Controllers\Api\Mobile\Parent\ParentProfileController::class, 'update']);
    Route::get('/parents/{cin}/payments', [\App\Http\Controllers\Api\Mobile\Parent\ParentPaymentsController::class, 'index']);
    Route::get('/children/{childId}/presences', [\App\Http\Controllers\Api\Mobile\Parent\ParentPresenceController::class, 'index']);
    Route::get('/children/{childId}/photos', [\App\Http\Controllers\Api\Mobile\Parent\ParentPhotosController::class, 'index']);
    Route::get('/photos/{photoId}/download', [\App\Http\Controllers\Api\Mobile\Parent\ParentPhotosController::class, 'download']);
    Route::post('/notifications/pickup', [\App\Http\Controllers\Api\Mobile\Parent\ParentPickupController::class, 'store']);
    Route::get('/parents/notifications', [\App\Http\Controllers\Api\Mobile\Parent\ParentNotificationsController::class, 'index']);
    Route::patch('/parents/notifications/mark-all-read', [\App\Http\Controllers\Api\Mobile\Parent\ParentNotificationsController::class, 'markAllAsRead']);
    Route::patch('/parents/notifications/{id}/read', [\App\Http\Controllers\Api\Mobile\Parent\ParentNotificationsController::class, 'markAsRead']);
    Route::get('/parents/notifications/unread-count', [\App\Http\Controllers\Api\Mobile\Parent\ParentNotificationsController::class, 'unreadCount']);
    Route::post('/password/change', [\App\Http\Controllers\Api\Mobile\Parent\ParentPasswordController::class, 'change']);
});

// Role-specific Route Files
Route::prefix('admin')->group(function () {
    require __DIR__ . '/admin.php';
});

Route::prefix('teacher')->group(function () {
    require __DIR__ . '/teacher.php';
});


