<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TeacherClass extends Model
{
    protected $table = 'TeacherClass';
    public $timestamps = false;
    public $incrementing = false;

    protected $fillable = [
        'TeacherID',
        'ClassID'
    ];
}
