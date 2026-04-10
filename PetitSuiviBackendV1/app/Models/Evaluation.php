<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Evaluation extends Model
{
    protected $table = 'Evaluation';
    protected $primaryKey = 'EvaluationID';
    public $timestamps = false;

    protected $fillable = [
        'Activitydescriptionsnapshot',
        'Activtitytitlesnapshot',
        'Date',
        'ActivityID',
        'SignalementID',
        'ChildID'
    ];
}
