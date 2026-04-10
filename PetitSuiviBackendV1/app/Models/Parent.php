<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Parent extends Model
{
    protected $table = 'Parent';
    protected $primaryKey = 'ParentID';
    public $timestamps = false;
}
