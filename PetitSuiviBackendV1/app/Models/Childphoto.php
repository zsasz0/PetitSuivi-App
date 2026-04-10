<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Childphoto extends Model
{
    protected $table = 'Childphoto';
    protected $primaryKey = 'ChildphotoID';
    public $timestamps = false;

    protected $fillable = [
        'Expiresat',
        'Filepath',
        'TeacherID'
    ];
}
