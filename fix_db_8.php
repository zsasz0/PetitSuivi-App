<?php
$host = '127.0.0.1';
$db   = 'bkpetitsuivi8';
$user = 'root';
$pass = '';

$dsn = "mysql:host=$host;dbname=$db;charset=utf8mb4";
$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
];

try {
    $pdo = new PDO($dsn, $user, $pass, $options);
    
    $pdo->exec("ALTER TABLE Signalement CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
    $pdo->exec("ALTER TABLE Signalement MODIFY Comment TEXT");

    $pdo->exec("ALTER TABLE Notification CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
    $pdo->exec("ALTER TABLE Notification MODIFY Message TEXT");
    $pdo->exec("ALTER TABLE Notification MODIFY Data TEXT");
    $pdo->exec("ALTER TABLE Notification MODIFY Title VARCHAR(500)");

    $pdo->exec("ALTER TABLE Evaluation CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
    $pdo->exec("ALTER TABLE Evaluation MODIFY Activtitytitlesnapshot VARCHAR(255)");
    $pdo->exec("ALTER TABLE Evaluation MODIFY Activitydescriptionsnapshot TEXT");

    echo "bkpetitsuivi8 successfully updated.\n";
} catch (\PDOException $e) {
    echo "Error updating bkpetitsuivi8: " . $e->getMessage() . "\n";
}
