<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Childfoodexception extends Model
{
    protected $table = 'Childfoodexception';
    protected $primaryKey = 'ChildfoodexceptionID';
    public $timestamps = false;

    protected $fillable = [
        'Reason',
        'ChildID'
    ];
}
