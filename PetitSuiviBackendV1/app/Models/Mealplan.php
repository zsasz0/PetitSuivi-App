<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Mealplan extends Model
{
    protected $table = 'Mealplan';
    protected $primaryKey = 'MealplanID';
    public $timestamps = false;

    protected $fillable = [
        'Name'
    ];
}
