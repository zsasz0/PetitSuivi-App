<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Planday extends Model
{
    protected $table = 'Planday';
    protected $primaryKey = 'PlandayID';
    public $timestamps = false;

    protected $fillable = [
        'Date',
        'PlanningID',
        'ClassID'
    ];

    public function schoolClass()
    {
        return $this->belongsTo(\App\Models\SchoolClass::class, 'ClassID', 'ClassID');
    }
}
