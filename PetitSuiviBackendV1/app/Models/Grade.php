<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Grade extends Model
{
    protected $table = 'Grade';
    protected $primaryKey = 'GradeID';
    public $timestamps = false;

    protected $fillable = [
        'Criterianamesnapshot',
        'Status',
        'EvaluationID',
        'CriteriaID',
        'StatusID',
        'GradestatusID'
    ];
}
