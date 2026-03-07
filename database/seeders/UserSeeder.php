<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        $users = [
            ['name' => 'Taher A.', 'email' => 'taher@example.com', 'password' => bcrypt('password'), 'rating' => 4.5],
            ['name' => 'Iman A.', 'email' => 'iman@example.com', 'password' => bcrypt('password'), 'rating' => 5.0],
            ['name' => 'أحمد ح.', 'email' => 'ahmed@example.com', 'password' => bcrypt('password'), 'rating' => 4.0],
            ['name' => 'ملك ن.', 'email' => 'malak@example.com', 'password' => bcrypt('password'), 'rating' => 5.0],
            ['name' => 'محمد س.', 'email' => 'mohamed.s@example.com', 'password' => bcrypt('password'), 'rating' => 4.0],
        ];

        foreach ($users as $u) {
            User::updateOrCreate(
                ['email' => $u['email']],
                array_merge($u, ['role' => 'user', 'status' => 'active', 'verification_status' => 'verified'])
            );
        }
    }
}
