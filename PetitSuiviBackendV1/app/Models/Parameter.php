<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Parameter extends Model
{
    protected $table = 'Parameter';
    protected $primaryKey = 'ParameterID';
    public $timestamps = false;

    protected $fillable = [
        'Name',
        'Value'
    ];
}
