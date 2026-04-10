<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ChildFoodExceptionOverrideMeals extends Model
{
    protected $table = 'ChildFoodExceptionOverrideMeals';
    public $timestamps = false;

    protected $fillable = [
        'original_meal',
        'ChildfoodexceptionoverrideID'
    ];
}
