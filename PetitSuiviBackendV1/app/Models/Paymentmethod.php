<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Paymentmethod extends Model
{
    protected $table = 'Paymentmethod';
    protected $primaryKey = 'PaymentmethodID';
    public $timestamps = false;

    protected $fillable = [
        'Name'
    ];
}
