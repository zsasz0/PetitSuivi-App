<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Inscription extends Model
{
    protected $table = 'Inscription';
    protected $primaryKey = 'InscriptionID';
    public $timestamps = false;

    protected $fillable = [
        'Basefee',
        'Date',
        'Fraisinscriptionsnapshot',
        'Inscriptionfeespaymentamount',
        'Isarchived',
        'Mealplanfee',
        'Paymentmethod',
        'Totalamount',
        'MealplanID',
        'PaymentmethodID',
        'TypeID',
        'InscriptiontypeID'
    ];
}
