<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Menuplanning extends Model
{
    protected $table = 'Menuplanning';
    protected $primaryKey = 'MenuplanningID';
    public $timestamps = false;

    protected $fillable = [
        'Name'
    ];
}
