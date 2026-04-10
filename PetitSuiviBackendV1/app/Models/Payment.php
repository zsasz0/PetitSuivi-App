<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    protected $table = 'Payment';
    protected $primaryKey = 'PaymentID';
    public $timestamps = false;

    protected $fillable = [
        'Amount',
        'Date',
        'InscriptionID',
        'ChildID'
    ];
}
