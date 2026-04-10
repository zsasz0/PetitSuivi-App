<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Dailyplan extends Model
{
    protected $table = 'Dailyplan';
    protected $primaryKey = 'DailyplanID';
    public $timestamps = false;

    protected $fillable = [
        'Date',
        'MenuplanningID'
    ];
}
