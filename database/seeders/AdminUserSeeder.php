<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class AdminUserSeeder extends Seeder
{
    public function run(): void
    {
        User::updateOrCreate(
            ['email' => 'mo.askary@gmail.com'],
            [
                'name' => 'Mohamed Al-Askary',
                'email' => 'mo.askary@gmail.com',
                'password' => bcrypt('newpassword'),
                'role' => 'admin',
                'status' => 'active',
                'verification_status' => 'verified',
                'email_verified_at' => now(),
            ]
        );
    }
}
