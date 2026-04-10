<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SchoolClass extends Model
{
    protected $table = 'Class';
    protected $primaryKey = 'ClassID';
    public $timestamps = false;

    protected $fillable = [
        'Capacity',
        'Isarchived',
        'Name',
        'Year',
        'ClasstypeID',
        'PlanningID'
    ];
}
