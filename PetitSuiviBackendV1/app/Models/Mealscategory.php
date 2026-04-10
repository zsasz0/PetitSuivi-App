<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Mealscategory extends Model
{
    protected $table = 'Mealscategory';
    protected $primaryKey = 'MealscategoryID';
    public $timestamps = false;

    protected $fillable = [
        'Name'
    ];
}
