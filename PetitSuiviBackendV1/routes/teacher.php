<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\Mobile\Teacher\AttendanceController;
use App\Http\Controllers\Api\Mobile\Teacher\DailyPlanController;
use App\Http\Controllers\Api\Mobile\Teacher\EvaluationController;
use App\Http\Controllers\Api\Mobile\Teacher\SignalementController;
use App\Http\Controllers\Api\Mobile\Teacher\ClassPhotoController;
use App\Http\Controllers\Api\Mobile\Teacher\PickupNotificationController;
use App\Http\Controllers\Api\Mobile\Teacher\ActivitySuggestionController;
use App\Http\Controllers\Api\Mobile\Teacher\ProfileController;

Route::middleware(['auth:sanctum', 'role:teacher'])->group(function () {

    // Attendance
    Route::post('attendance', [AttendanceController::class, 'store']);
    Route::patch('attendance/{id}', [AttendanceController::class, 'update']);
    Route::get('attendance/report', [AttendanceController::class, 'dailyReport']);

    // Daily Planning & Activities
    Route::get('daily-plan', [DailyPlanController::class, 'index']);
    Route::get('daily-plan/{id}', [DailyPlanController::class, 'show']);
    Route::patch('daily-plan/{id}/status', [DailyPlanController::class, 'updateStatus']);

    // Evaluations
    Route::apiResource('evaluations', EvaluationController::class)->except(['destroy']);

    // Incident Reporting (Signalements)
    Route::get('signalements', [SignalementController::class, 'index']);
    Route::post('signalements', [SignalementController::class, 'store']);

    // Media / Photo Sharing
    Route::get('photos', [ClassPhotoController::class, 'index']);
    Route::post('photos', [ClassPhotoController::class, 'store']);
    Route::delete('photos/{id}', [ClassPhotoController::class, 'destroy']);

    // Pickup Notifications
    Route::get('pickup-notifications', [PickupNotificationController::class, 'index']);
    Route::patch('pickup-notifications/{id}/complete', [PickupNotificationController::class, 'update']);

    // System Notifications
    Route::get('notifications', [PickupNotificationController::class, 'notifications']);
    Route::patch('notifications/mark-all-read', [PickupNotificationController::class, 'markAllRead']);
    Route::patch('notifications/{id}/read', [PickupNotificationController::class, 'markAsRead']);
    Route::get('notifications/unread-count', [PickupNotificationController::class, 'unreadCount']);

    // Activity Suggestions
    Route::get('activity-suggestions', [ActivitySuggestionController::class, 'index']);
    Route::post('activity-suggestions', [ActivitySuggestionController::class, 'store']);
    Route::get('activity-suggestions/ai', [ActivitySuggestionController::class, 'suggest']);

    // Profile Management
    Route::get('profile/{cin}', [ProfileController::class, 'show']);
    Route::put('profile/{cin}', [ProfileController::class, 'update']);
    Route::post('profile/change-password', [ProfileController::class, 'changePassword']);

});
