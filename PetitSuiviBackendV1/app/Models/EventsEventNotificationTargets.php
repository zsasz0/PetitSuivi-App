<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class EventsEventNotificationTargets extends Model
{
    protected $table = 'EventsEventNotificationTargets';
    public $timestamps = false;

    protected $fillable = [
        'EventsID'
    ];
}
