<?php

namespace Database\Seeders;

use App\Enums\UserAccountType;
use App\Models\Institution;
use App\Models\InstitutionMembership;
use App\Models\ParentChild;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class InstitutionSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        $institution = Institution::create([
            'name' => 'Test School',
            'status' => 'active',
        ]);

        // Create admin user
        $admin = User::create([
            'name' => 'Admin User',
            'email' => 'admin@testschool.com',
            'username' => 'admin',
            'password' => Hash::make('password'),
            'user_type' => UserAccountType::Staff,
            'is_active' => true,
            'active_institution_id' => $institution->id,
            'activated_at' => now(),
        ]);

        InstitutionMembership::create([
            'institution_id' => $institution->id,
            'user_id' => $admin->id,
            'role' => 'administrator',
            'is_active' => true,
        ]);

        $this->command->info('Created: 1 institution, 1 admin');

        // Create teacher users
        $teacherRole = 'teacher';
        for ($i = 1; $i <= 3; $i++) {
            $teacher = User::create([
                'name' => "Teacher {$i}",
                'email' => "teacher{$i}@testschool.com",
                'username' => "teacher{$i}",
                'password' => Hash::make('password'),
                'user_type' => UserAccountType::Staff,
                'is_active' => true,
                'active_institution_id' => $institution->id,
                'activated_at' => now(),
            ]);

            InstitutionMembership::create([
                'institution_id' => $institution->id,
                'user_id' => $teacher->id,
                'role' => $teacherRole,
                'is_active' => true,
            ]);
        }
        $this->command->info('Created: 3 teachers');

        // Create student users
        $students = [];
        for ($i = 1; $i <= 10; $i++) {
            $student = User::create([
                'name' => "Student {$i}",
                'email' => "student{$i}@testschool.com",
                'username' => "student{$i}",
                'password' => Hash::make('password'),
                'user_type' => UserAccountType::Student,
                'is_active' => true,
                'active_institution_id' => $institution->id,
                'activated_at' => now(),
            ]);
            $students[] = $student;
            $this->command->info("Created student {$i}: {$student->email}");

            InstitutionMembership::create([
                'institution_id' => $institution->id,
                'user_id' => $student->id,
                'role' => 'student',
                'is_active' => true,
            ]);
        }

        // Create parent users with parent-child relationships
        for ($i = 1; $i <= 4; $i++) {
            $parent = User::create([
                'name' => "Parent {$i}",
                'email' => "parent{$i}@testschool.com",
                'username' => "parent{$i}",
                'password' => Hash::make('password'),
                'user_type' => UserAccountType::Parent,
                'is_active' => true,
                'active_institution_id' => $institution->id,
                'activated_at' => now(),
            ]);

            InstitutionMembership::create([
                'institution_id' => $institution->id,
                'user_id' => $parent->id,
                'role' => 'parent',
                'is_active' => true,
            ]);

            // Link parent to 1-2 students
            $linkedStudents = collect($students)->random(min(2, count($students)));
            foreach ($linkedStudents as $student) {
                ParentChild::create([
                    'institution_id' => $institution->id,
                    'parent_user_id' => $parent->id,
                    'child_user_id' => $student->id,
                    'invitation_id' => null,
                    'is_active' => true,
                ]);
            }
        }

        $this->command->info('Seeded: 1 institution, 1 admin, 3 teachers, 10 students, 4 parents');
    }
}
