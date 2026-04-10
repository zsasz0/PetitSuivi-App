<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Plandayactivity extends Model
{
    protected $table = 'Plandayactivity';
    protected $primaryKey = 'PlandayactivityID';
    public $timestamps = false;

    protected $fillable = [
        'Endtime',
        'Starttime',
        'Status',
        'ActivityID',
        'PlandayID'
    ];
}
