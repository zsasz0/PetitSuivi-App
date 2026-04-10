<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Laravel\Sanctum\HasApiTokens;

class Account extends Model
{
    use HasApiTokens;
    protected $table = 'Account';
    protected $primaryKey = 'AccountID';
    public $timestamps = false;

    protected $fillable = [
        'Adresse',
        'Approval_status',
        'Birthdate',
        'Cin',
        'Email',
        'Firstname',
        'Inscriptiondate',
        'Is_archived',
        'Lastname',
        'Password',
        'Phone',
        'RoleID',
        'PersonID'
    ];
}
