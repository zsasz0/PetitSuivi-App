<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Criteria extends Model
{
    protected $table = 'Criteria';
    protected $primaryKey = 'CriteriaID';
    public $timestamps = false;

    protected $fillable = [
        'Name'
    ];
}
