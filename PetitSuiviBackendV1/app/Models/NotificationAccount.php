<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class NotificationAccount extends Model
{
    protected $table = 'NotificationAccount';
    public $timestamps = false;

    protected $fillable = [
        'AccountID',
        'NotificationID'
    ];
}
