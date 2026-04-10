<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Classtype extends Model
{
    protected $table = 'Classtype';
    protected $primaryKey = 'ClasstypeID';
    public $timestamps = false;

    protected $fillable = [
        'Name'
    ];
}
