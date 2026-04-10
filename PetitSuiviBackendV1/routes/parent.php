<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\Parent\DashboardController;
use App\Http\Controllers\Api\Parent\ChildProfileController;
use App\Http\Controllers\Api\Parent\FinanceController;
use App\Http\Controllers\Api\Parent\PickupAlertController;
use App\Http\Controllers\Api\Parent\FoodExceptionController;
use App\Http\Controllers\Api\Parent\EventNotificationController;

Route::middleware(['auth:sanctum', 'role:parent'])->prefix('parent')->group(function () {

    // Dashboard
    Route::get('dashboard', [DashboardController::class, 'index']);

    // Child Profile Management
    Route::get('children', [ChildProfileController::class, 'index']);
    Route::get('children/{id}', [ChildProfileController::class, 'show']);
    Route::put('children/{id}', [ChildProfileController::class, 'update']);

    // Finances (Read-only)
    Route::get('finances', [FinanceController::class, 'index']);
    Route::get('finances/{id}', [FinanceController::class, 'show']);

    // Pickups
    Route::post('pickup-alerts', [PickupAlertController::class, 'store']);
    Route::get('pickup-alerts/{id}', [PickupAlertController::class, 'show']);

    // Dietary
    Route::post('food-exceptions', [FoodExceptionController::class, 'store']);
    Route::delete('food-exceptions/{id}', [FoodExceptionController::class, 'destroy']);

    // Events and Notifications
    Route::get('events-notifications', [EventNotificationController::class, 'index']);
    Route::patch('notifications/{id}/read', [EventNotificationController::class, 'markAsRead']);

});
