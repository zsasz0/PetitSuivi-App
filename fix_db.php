<?php
require 'PetitSuiviBackendV1/vendor/autoload.php';
$app = require_once 'PetitSuiviBackendV1/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\DB;

try {
    DB::statement("ALTER TABLE Signalement CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
    DB::statement("ALTER TABLE Signalement MODIFY Comment TEXT");

    DB::statement("ALTER TABLE Notification CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
    DB::statement("ALTER TABLE Notification MODIFY Message TEXT");
    DB::statement("ALTER TABLE Notification MODIFY Data TEXT");
    DB::statement("ALTER TABLE Notification MODIFY Title VARCHAR(500)");

    DB::statement("ALTER TABLE Evaluation CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
    DB::statement("ALTER TABLE Evaluation MODIFY Activtitytitlesnapshot VARCHAR(255)");
    DB::statement("ALTER TABLE Evaluation MODIFY Activitydescriptionsnapshot TEXT");

    echo "Database tables successfully updated to support Arabic (utf8mb4) and longer texts.\n";
} catch (\Exception $e) {
    echo "Error updating database: " . $e->getMessage() . "\n";
}
