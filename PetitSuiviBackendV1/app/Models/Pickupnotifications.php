<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Pickupnotifications extends Model
{
    protected $table = 'Pickupnotifications';
    protected $primaryKey = 'PickupnotificationsID';
    public $timestamps = false;

    protected $fillable = [
        'Duration',
        'ParentID',
        'StatusID',
        'PickupnotificationsstatusID'
    ];
}
