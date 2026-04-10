<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MealsChildFoodExceptionOverride extends Model
{
    protected $table = 'MealsChildFoodExceptionOverride';
    public $timestamps = false;

    protected $fillable = [
        'ChildfoodexceptionoverrideID',
        'replacement_meal'
    ];
}
