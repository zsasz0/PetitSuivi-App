<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Notification extends Model
{
    protected $table = 'Notification';
    protected $primaryKey = 'NotificationID';
    public $timestamps = false;

    protected $fillable = [
        'Data',
        'Isread',
        'Message',
        'Recipientcin',
        'Recipientrole',
        'Title',
        'Type',
        'EventsID'
    ];
}
