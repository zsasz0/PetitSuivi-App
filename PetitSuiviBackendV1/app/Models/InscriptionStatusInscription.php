<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class InscriptionStatusInscription extends Model
{
    protected $table = 'InscriptionStatusInscription';
    public $timestamps = false;

    protected $fillable = [
        'InscriptionID',
        'StatusID',
        'InscriptionstatusID'
    ];
}
