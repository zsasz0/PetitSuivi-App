<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Healthcomment extends Model
{
    protected $table = 'Healthcomment';
    protected $primaryKey = 'HealthcommentID';
    public $timestamps = false;

    protected $fillable = [
        'Healthcomment'
    ];
}
