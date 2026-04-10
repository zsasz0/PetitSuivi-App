<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Teacher extends Model
{
    protected $table = 'Teacher';
    protected $primaryKey = 'TeacherID';
    public $timestamps = false;
}
