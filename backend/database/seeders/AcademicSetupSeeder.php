<?php

namespace Database\Seeders;

use App\Models\AcademicPeriod;
use App\Models\AcademicYear;
use App\Models\ClassModel;
use App\Models\Course;
use App\Models\Department;
use App\Models\Enrollment;
use App\Models\Group;
use App\Models\Institution;
use App\Models\Level;
use App\Models\Room;
use App\Models\Subject;
use App\Models\Track;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class AcademicSetupSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        // Get institution from existing data
        $institution = Institution::first();
        if (! $institution) {
            $this->command->error('No institution found. Run InstitutionSeeder first.');

            return;
        }

        // Create Academic Year (table uses is_current, not is_active, no slug)
        $academicYear = AcademicYear::create([
            'institution_id' => $institution->id,
            'name' => '2024-2025',
            'starts_at' => '2024-09-01',
            'ends_at' => '2025-06-30',
            'is_current' => true,
        ]);
        $this->command->info("Created academic year: {$academicYear->name}");

        // Create Periods (semesters)
        $period1 = AcademicPeriod::create([
            'institution_id' => $institution->id,
            'academic_year_id' => $academicYear->id,
            'name' => 'Semester 1',
            'type' => 'semester',
            'sequence' => 1,
            'starts_at' => '2024-09-01',
            'ends_at' => '2024-12-20',
            'is_grading_period' => true,
        ]);

        $period2 = AcademicPeriod::create([
            'institution_id' => $institution->id,
            'academic_year_id' => $academicYear->id,
            'name' => 'Semester 2',
            'type' => 'semester',
            'sequence' => 2,
            'starts_at' => '2025-01-06',
            'ends_at' => '2025-05-30',
            'is_grading_period' => true,
        ]);
        $this->command->info('Created 2 academic periods');

        // Create Levels
        $level1 = Level::create([
            'institution_id' => $institution->id,
            'name' => 'Grade 1',
            'code' => 'G1',
            'sequence' => 1,
        ]);

        $level2 = Level::create([
            'institution_id' => $institution->id,
            'name' => 'Grade 2',
            'code' => 'G2',
            'sequence' => 2,
        ]);

        $level3 = Level::create([
            'institution_id' => $institution->id,
            'name' => 'Grade 3',
            'code' => 'G3',
            'sequence' => 3,
        ]);
        $this->command->info('Created 3 levels');

        // Create Tracks (level_id is optional in migration)
        Track::create([
            'institution_id' => $institution->id,
            'name' => 'Science Stream',
            'code' => 'SCI',
        ]);

        Track::create([
            'institution_id' => $institution->id,
            'name' => 'Arts Stream',
            'code' => 'ART',
        ]);
        $this->command->info('Created 2 tracks');

        // Create Departments
        $mathDept = Department::create(['institution_id' => $institution->id, 'name' => 'Mathematics']);
        $scienceDept = Department::create(['institution_id' => $institution->id, 'name' => 'Sciences']);
        $langDept = Department::create(['institution_id' => $institution->id, 'name' => 'Language Arts']);
        $socStudiesDept = Department::create(['institution_id' => $institution->id, 'name' => 'Social Studies']);
        $this->command->info('Created 4 departments');

        // Create Subjects (each subject needs institution_id)
        $subjects = [
            ['name' => 'Mathematics', 'department_id' => $mathDept->id, 'code' => 'MATH'],
            ['name' => 'Physics', 'department_id' => $scienceDept->id, 'code' => 'PHYS'],
            ['name' => 'Chemistry', 'department_id' => $scienceDept->id, 'code' => 'CHEM'],
            ['name' => 'Biology', 'department_id' => $scienceDept->id, 'code' => 'BIOL'],
            ['name' => 'English', 'department_id' => $langDept->id, 'code' => 'ENG'],
            ['name' => 'French', 'department_id' => $langDept->id, 'code' => 'FRE'],
            ['name' => 'History', 'department_id' => $socStudiesDept->id, 'code' => 'HIST'],
            ['name' => 'Geography', 'department_id' => $socStudiesDept->id, 'code' => 'GEOG'],
        ];

        $createdSubjects = [];
        foreach ($subjects as $subjectData) {
            $createdSubjects[] = Subject::create(array_merge(['institution_id' => $institution->id], $subjectData));
        }
        $this->command->info('Created 8 subjects');

        // Create Courses for each semester (each course needs institution_id and academic_year_id)
        $courses = [];
        foreach ($createdSubjects as $subject) {
            foreach ([$period1, $period2] as $period) {
                $courses[] = Course::create([
                    'institution_id' => $institution->id,
                    'academic_year_id' => $academicYear->id,
                    'subject_id' => $subject->id,
                    'name' => $subject->name,
                    'code' => $subject->code.'-'.$period->sequence,
                ]);
            }
        }
        $this->command->info('Created '.count($courses).' courses');

        // Create Rooms
        $roomTypes = ['classroom', 'classroom', 'classroom', 'classroom', 'laboratory', 'auditorium'];
        $rooms = [];
        for ($i = 1; $i <= 6; $i++) {
            $room = Room::create([
                'institution_id' => $institution->id,
                'name' => "Room {$i}",
                'type' => $roomTypes[$i - 1],
                'capacity' => $i <= 5 ? 30 : 100,
                'is_active' => true,
            ]);
            $rooms[] = $room;
        }
        $this->command->info('Created 6 rooms');

        // Create Classes (set room_id with ULID)
        $testClass = ClassModel::create([
            'institution_id' => $institution->id,
            'academic_year_id' => $academicYear->id,
            'level_id' => $level3->id,
            'name' => 'Class 3A',
            'code' => '3A',
            'capacity' => 30,
            'is_active' => true,
        ]);

        $testClass2 = ClassModel::create([
            'institution_id' => $institution->id,
            'academic_year_id' => $academicYear->id,
            'level_id' => $level3->id,
            'name' => 'Class 3B',
            'code' => '3B',
            'capacity' => 30,
            'is_active' => true,
        ]);

        // Assign rooms to classes
        $testClass->update(['room_id' => $rooms[0]->id]);
        $testClass2->update(['room_id' => $rooms[1]->id]);

        $this->command->info('Created 2 classes');

        // Create Groups
        Group::create([
            'institution_id' => $institution->id,
            'class_id' => $testClass->id,
            'name' => 'Project Alpha',
            'code' => 'PA',
            'description' => 'Science project group',
            'is_active' => true,
        ]);

        Group::create([
            'institution_id' => $institution->id,
            'class_id' => $testClass->id,
            'name' => 'Art Club',
            'code' => 'AC',
            'description' => 'Art and design group',
            'is_active' => true,
        ]);
        $this->command->info('Created 2 groups');

        // Enroll students in classes
        $students = User::where('user_type', 'student')->where('is_active', true)->get();
        $classes = [$testClass, $testClass2];

        foreach ($students as $student) {
            $randomClass = collect($classes)->random();
            Enrollment::create([
                'institution_id' => $institution->id,
                'academic_year_id' => $academicYear->id,
                'student_id' => $student->id,
                'class_id' => $randomClass->id,
                'status' => 'active',
                'enrolled_at' => now(),
            ]);
        }

        $this->command->info('Enrolled '.$students->count().' students');
        $this->command->info('Seeded academic data: 1 year, 2 periods, 3 levels, 2 tracks, 4 departments, 8 subjects, 16 courses, 6 rooms, 2 classes, 2 groups');
    }
}
