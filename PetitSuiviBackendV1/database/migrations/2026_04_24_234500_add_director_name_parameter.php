<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::table('Parameter')->updateOrInsert(
            ['Name' => 'director_name'],
            ['Value' => 'mahmoud']
        );
    }

    public function down(): void
    {
        DB::table('Parameter')->where('Name', 'director_name')->delete();
    }
};
