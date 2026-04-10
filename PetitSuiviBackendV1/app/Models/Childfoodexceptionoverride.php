<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Childfoodexceptionoverride extends Model
{
    protected $table = 'Childfoodexceptionoverride';
    protected $primaryKey = 'ChildfoodexceptionoverrideID';
    public $timestamps = false;

    protected $fillable = [
        'Dayindex',
        'Weekstartdate',
        'replacement_meal'
    ];
}
