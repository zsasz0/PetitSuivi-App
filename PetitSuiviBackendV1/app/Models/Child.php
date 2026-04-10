<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Child extends Model
{
    protected $table = 'Child';
    protected $primaryKey = 'ChildID';
    public $timestamps = false;

    protected $fillable = [
        'Birthdate',
        'Firstname',
        'Lastname',
        'ParentID'
    ];
}
