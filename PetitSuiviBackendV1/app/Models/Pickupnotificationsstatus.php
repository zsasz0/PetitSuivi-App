<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Pickupnotificationsstatus extends Model
{
    protected $table = 'Pickupnotificationsstatus';
    protected $primaryKey = 'PickupnotificationsstatusID';
    public $timestamps = false;

    protected $fillable = [
        'Name'
    ];
}
