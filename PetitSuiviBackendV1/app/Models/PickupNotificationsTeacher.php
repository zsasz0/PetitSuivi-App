<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PickupNotificationsTeacher extends Model
{
    protected $table = 'PickupNotificationsTeacher';
    public $timestamps = false;

    protected $fillable = [
        'TeacherID',
        'PickupnotificationsID'
    ];
}
