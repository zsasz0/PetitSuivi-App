<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Presence extends Model
{
    protected $table = 'Presence';
    protected $primaryKey = 'PresenceID';
    public $timestamps = false;

    protected $fillable = [
        'Date',
        'ChildID',
        'PresencestatusID'
    ];
}
