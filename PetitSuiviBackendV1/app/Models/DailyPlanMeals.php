<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DailyPlanMeals extends Model
{
    protected $table = 'DailyPlanMeals';
    public $timestamps = false;

    protected $fillable = [
        'MealsID',
        'DailyplanID'
    ];
}
