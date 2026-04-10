<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Partialpayment extends Model
{
    protected $table = 'Partialpayment';
    protected $primaryKey = 'PartialpaymentID';
    public $timestamps = false;

    protected $fillable = [
        'Date',
        'Targetmonth',
        'Value',
        'PaymentID'
    ];
}
