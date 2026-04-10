<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Planning extends Model
{
    protected $table = 'Planning';
    protected $primaryKey = 'PlanningID';
    public $timestamps = false;

    protected $fillable = [
        'Startdate',
        'Enddate',
        'Isarchived',
        'Label'
    ];
}
