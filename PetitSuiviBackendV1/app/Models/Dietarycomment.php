<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Dietarycomment extends Model
{
    protected $table = 'Dietarycomment';
    protected $primaryKey = 'DietarycommentID';
    public $timestamps = false;

    protected $fillable = [
        'Dietarycomment'
    ];
}
