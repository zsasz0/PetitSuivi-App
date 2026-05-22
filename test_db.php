<?php
require 'PetitSuiviBackendV1/vendor/autoload.php';
$app = require_once 'PetitSuiviBackendV1/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
$form = DB::table('Medicalform')->orderBy('MedicalformID', 'desc')->first();
echo $form->Formdata;
