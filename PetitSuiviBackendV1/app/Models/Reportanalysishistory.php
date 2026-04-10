<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Reportanalysishistory extends Model
{
    protected $table = 'Reportanalysishistory';
    protected $primaryKey = 'ReportanalysishistoryID';
    public $timestamps = false;

    protected $fillable = [
        'Analysisresult',
        'Date'
    ];
}
