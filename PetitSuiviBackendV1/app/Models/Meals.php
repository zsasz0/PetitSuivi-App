<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Meals extends Model
{
    protected $table = 'Meals';
    protected $primaryKey = 'MealsID';
    public $timestamps = false;

    protected $fillable = [
        'Name',
        'MealscategoryID'
    ];
}
