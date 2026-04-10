<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Gradestatus extends Model
{
    protected $table = 'Gradestatus';
    protected $primaryKey = 'GradestatusID';
    public $timestamps = false;

    protected $fillable = [
        'Name'
    ];
}
