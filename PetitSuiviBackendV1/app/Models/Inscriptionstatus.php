<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Inscriptionstatus extends Model
{
    protected $table = 'Inscriptionstatus';
    protected $primaryKey = 'InscriptionstatusID';
    public $timestamps = false;

    protected $fillable = [
        'Name'
    ];
}
