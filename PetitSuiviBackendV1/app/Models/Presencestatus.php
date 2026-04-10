<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Presencestatus extends Model
{
    protected $table = 'Presencestatus';
    protected $primaryKey = 'PresencestatusID';
    public $timestamps = false;

    protected $fillable = [
        'Name'
    ];
}
