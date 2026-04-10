<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ChildClass extends Model
{
    protected $table = 'ChildClass';
    public $timestamps = false;

    protected $fillable = [
        'ChildID',
        'ClassID'
    ];
}
