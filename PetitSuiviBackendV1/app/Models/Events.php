<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Events extends Model
{
    protected $table = 'Events';
    protected $primaryKey = 'EventsID';
    public $timestamps = false;

    protected $fillable = [
        'Date',
        'Description',
        'Endtime',
        'Name',
        'Notificationsend',
        'Starttime',
        'Status'
    ];
}
