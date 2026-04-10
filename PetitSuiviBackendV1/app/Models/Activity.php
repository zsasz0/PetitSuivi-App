<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Activity extends Model
{
    protected $table = 'Activity';
    protected $primaryKey = 'ActivityID';
    public $timestamps = false;

    protected $fillable = [
        'Description',
        'Title'
    ];
}
