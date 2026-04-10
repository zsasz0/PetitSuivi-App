<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Inscriptiontype extends Model
{
    protected $table = 'Inscriptiontype';
    protected $primaryKey = 'InscriptiontypeID';
    public $timestamps = false;

    protected $fillable = [
        'Name'
    ];
}
