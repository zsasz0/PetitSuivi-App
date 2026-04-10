<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Signalement extends Model
{
    protected $table = 'Signalement';
    protected $primaryKey = 'SignalementID';
    public $timestamps = false;

    protected $fillable = [
        'Comment',
        'Incident_date',
        'ReportanalysishistoryID'
    ];
}
