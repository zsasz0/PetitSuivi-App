<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Childphotorecipient extends Model
{
    protected $table = 'Childphotorecipient';
    protected $primaryKey = 'ChildphotorecipientID';
    public $timestamps = false;

    protected $fillable = [
        'Downloadtime',
        'ChildphotoID',
        'ChildID'
    ];
}
