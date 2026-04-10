<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ChildFoodExceptionMeals extends Model
{
    protected $table = 'ChildFoodExceptionMeals';
    public $timestamps = false;

    protected $fillable = [
        'ChildfoodexceptionID',
        'MealsID'
    ];
}
