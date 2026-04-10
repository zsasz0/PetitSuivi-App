<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Medicalform extends Model
{
    protected $table = 'Medicalform';
    protected $primaryKey = 'MedicalformID';
    public $timestamps = false;

    protected $fillable = [
        'Formdata',
        'DietarycommentID',
        'HealthcommentID',
        'InscriptionID'
    ];
}
