<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CriteriaActivity extends Model
{
    protected $table = 'CriteriaActivity';
    public $timestamps = false;

    protected $fillable = [
        'ActivityID',
        'CriteriaID'
    ];
}
