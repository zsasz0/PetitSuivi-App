<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\Admin\AccountController;
use App\Http\Controllers\Api\Admin\TeacherController;
use App\Http\Controllers\Api\Admin\ChildController;
use App\Http\Controllers\Api\Admin\ClassController;
use App\Http\Controllers\Api\Admin\ClassTypeController;
use App\Http\Controllers\Api\Admin\InscriptionController;
use App\Http\Controllers\Api\Admin\PaymentController;
use App\Http\Controllers\Api\Admin\PartialPaymentController;
use App\Http\Controllers\Api\Admin\PlanningController;
use App\Http\Controllers\Api\Admin\ActivityController;
use App\Http\Controllers\Api\Admin\CriteriaController;
use App\Http\Controllers\Api\Admin\PlannedActivityController;
use App\Http\Controllers\Api\Admin\AiSuggestionController;
use App\Http\Controllers\Api\Admin\MealMenuController;
use App\Http\Controllers\Api\Admin\EventController;
use App\Http\Controllers\Api\Admin\NotificationController;
use App\Http\Controllers\Api\Admin\ParameterController;
use App\Http\Controllers\Api\Admin\ReportAnalysisController;
use App\Http\Controllers\Api\Admin\CopilotController;
use App\Http\Controllers\Api\Admin\FoodExceptionController;
use App\Http\Controllers\Api\Admin\MenuPlanningController;
use App\Http\Controllers\Api\Admin\ChildFoodExceptionOverrideController;

Route::middleware(['auth:sanctum', 'role:admin'])->group(function () {

    // Master Entities

    Route::apiResource('accounts', AccountController::class)->except(['destroy']);
    // crud operations on teachers
    Route::apiResource('teachers', TeacherController::class);
    // used to set teacher as archived or not
    Route::patch('teachers/{cin}/toggle-archive', [TeacherController::class, 'toggleArchive']);
    // Parents
    // crud operations on parents
    Route::get('parents', [\App\Http\Controllers\Api\Admin\ParentController::class, 'index']);
    Route::post('parents', [\App\Http\Controllers\Api\Admin\ParentController::class, 'store']);
    Route::put('parents/{cin}', [\App\Http\Controllers\Api\Admin\ParentController::class, 'update']);
    Route::delete('parents/{cin}', [\App\Http\Controllers\Api\Admin\ParentController::class, 'destroy']);
    // used to set parent as approved or not
    Route::patch('parents/{cin}/approval-status', [\App\Http\Controllers\Api\Admin\ParentController::class, 'updateApprovalStatus']);
    // used to set parent as archived or not
    Route::patch('parents/{cin}/toggle-archive', [\App\Http\Controllers\Api\Admin\ParentController::class, 'toggleArchive']);
    // crud operations on children
    Route::apiResource('children', ChildController::class)->except(['store', 'destroy']);
    


    // Classes
    // get all class types
    Route::get('class-types', [ClassTypeController::class, 'index']);
    // crud operations on classes
    Route::get('classes', [ClassController::class, 'index']);
    Route::post('classes', [ClassController::class, 'store']);
    Route::get('classes/{id}', [ClassController::class, 'show']);
    Route::put('classes/{id}', [ClassController::class, 'update']);
    Route::delete('classes/{id}', [ClassController::class, 'destroy']);
    // used to set class as archived or not
    Route::patch('classes/{id}/toggle-archive', [ClassController::class, 'toggleArchive']);

    // Inscriptions
    Route::get('inscriptions', [InscriptionController::class, 'index']);
    Route::get('registrations', [InscriptionController::class, 'index']);
    Route::get('inscriptions/{id}', [InscriptionController::class, 'show']);
    Route::patch('inscriptions/{id}/status', [InscriptionController::class, 'updateStatus']);
    Route::patch('inscriptions/{id}/toggle-archive', [InscriptionController::class, 'toggleArchive']);
    Route::put('inscriptions/{childId}/ai-comments', [InscriptionController::class, 'saveAiComments']);
    Route::post('inscriptions/{childId}/rescan-medical', [InscriptionController::class, 'rescanMedical']);
    Route::post('inscriptions/{childId}/scan-meals', [InscriptionController::class, 'scanMeals']);
    Route::post('inscriptions/{childId}/save-food-exceptions', [InscriptionController::class, 'saveFoodExceptions']);
    Route::post('inscriptions/custom-api', [InscriptionController::class, 'customApi']);

    // Finances
    Route::get('payments', [PaymentController::class, 'index']);
    Route::post('payments', [PaymentController::class, 'store']);
    Route::get('payments/{id}', [PaymentController::class, 'show']);
    Route::put('payments/{id}', [PaymentController::class, 'update']);
    Route::post('payments/{inscriptionId}/{childId}/transactions', [PartialPaymentController::class, 'storeTransaction']);
    Route::get('partials', [PartialPaymentController::class, 'index']);
    Route::patch('inscriptions/{id}/frais', [InscriptionController::class, 'toggleFrais']);
    Route::get('plannings/{id}/payment-report', [\App\Http\Controllers\Api\Admin\PaymentReportController::class, 'getPaymentReport']);
    Route::get('plannings/{id}/payment-report/month/{month}', [\App\Http\Controllers\Api\Admin\PaymentReportController::class, 'getMonthlyPaymentReport']);

    // Planning and Education
    Route::post('plannings/archive-current-year', [PlanningController::class, 'archiveCurrentYear']);
    Route::apiResource('plannings', PlanningController::class);

    // Activities and Evaluation
    Route::get('activities', [ActivityController::class, 'index']);
    Route::post('activities', [ActivityController::class, 'store']);
    Route::put('activities/{id}', [ActivityController::class, 'update']);
    Route::delete('activities/{id}', [ActivityController::class, 'destroy']);
    
    Route::get('criteria', [CriteriaController::class, 'index']);
    Route::post('criteria', [CriteriaController::class, 'store']);
    Route::delete('criteria/{id}', [CriteriaController::class, 'destroy']);
    
    Route::get('plannings/{id}/activities', [PlannedActivityController::class, 'index']);
    Route::post('plannings/{id}/activities', [PlannedActivityController::class, 'store']);
    Route::delete('plannings/{id}/activities/{activityId}', [PlannedActivityController::class, 'destroy']);
    Route::get('activities/by-date/{date}', [PlannedActivityController::class, 'getByDate']);
    
    Route::post('ai/suggest-activity-criteria', [AiSuggestionController::class, 'suggest']);

    // Meals
    Route::get('meals', [MealMenuController::class, 'index']);
    Route::post('meals', [MealMenuController::class, 'store']);
    Route::get('meals/by-week/{date}', [MealMenuController::class, 'getByWeek']);
    Route::post('meals/check-exceptions', [MealMenuController::class, 'checkExceptions']);
    Route::post('meals/save-exceptions', [MealMenuController::class, 'saveExceptions']);
    Route::delete('meals/{id}', [MealMenuController::class, 'destroy']);
    Route::get('food-exceptions', [FoodExceptionController::class, 'index']);
    Route::post('food-exceptions', [FoodExceptionController::class, 'store']);
    Route::delete('food-exceptions/{id}', [FoodExceptionController::class, 'destroy']);

    // Menu Planning Presets
    Route::get('menu-plannings', [MenuPlanningController::class, 'index']);
    Route::post('menu-plannings', [MenuPlanningController::class, 'store']);
    Route::post('menu-plannings/apply-week', [MenuPlanningController::class, 'applyWeek']);
    Route::get('menu-plannings/{id}', [MenuPlanningController::class, 'show']);
    Route::delete('menu-plannings/{id}', [MenuPlanningController::class, 'destroy']);

    // Child Food Exception Overrides
    Route::get('child-food-exception-overrides', [ChildFoodExceptionOverrideController::class, 'index']);
    Route::post('child-food-exception-overrides', [ChildFoodExceptionOverrideController::class, 'store']);

    // Communication & Settings
    Route::get('events/upcoming', [EventController::class, 'upcoming']);
    Route::get('events/check-conflict', [EventController::class, 'checkConflict']);
    Route::patch('events/{id}/status', [EventController::class, 'updateStatus']);
    Route::apiResource('events', EventController::class)->except(['show']);
    Route::get('notifications', [NotificationController::class, 'index']);
    Route::post('notifications', [NotificationController::class, 'store']);
    Route::get('parameters', [ParameterController::class, 'index']);
    Route::put('parameters', [ParameterController::class, 'updateBulk']);

    // AI integrations & Reports
    Route::get('dashboard/stats', [ReportAnalysisController::class, 'getDashboardStats']);
    Route::get('report-analysis', [ReportAnalysisController::class, 'index']);
    Route::get('report-analysis/{id}', [ReportAnalysisController::class, 'show']);
    Route::get('plannings/{id}/report', [ReportAnalysisController::class, 'getReport']);
    Route::get('reports/analysis-history', [ReportAnalysisController::class, 'getAnalysisHistory']);
    Route::post('reports/analysis-history', [ReportAnalysisController::class, 'storeAnalysisHistory']);
    Route::post('ai/analyze-reports', [ReportAnalysisController::class, 'analyzeReports']);
    Route::post('copilot/prompt', [CopilotController::class, 'prompt']);

});
