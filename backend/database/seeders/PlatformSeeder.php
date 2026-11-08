<?php

namespace Database\Seeders;

use App\Enums\InstitutionRole;
use App\Enums\UserAccountType;
use App\Models\Institution;
use App\Models\InstitutionMembership;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class PlatformSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        // Create platform super-admin user
        $platformInstitution = Institution::create([
            'name' => 'Platform Management',
            'status' => 'active',
        ]);

        $superAdminUser = User::create([
            'name' => 'Super Admin',
            'email' => 'superadmin@schoolmanager.test',
            'username' => 'superadmin',
            'password' => Hash::make('password'),
            'user_type' => UserAccountType::Staff,
            'is_active' => true,
            'active_institution_id' => $platformInstitution->id,
        ]);

        $platformInstitution->memberships()->create([
            'user_id' => $superAdminUser->id,
            'role' => 'super-admin',
            'is_active' => true,
        ]);

        $this->command->info('Platform Super Admin created: superadmin@schoolmanager.test / password');
    }
}
