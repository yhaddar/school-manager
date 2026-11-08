<?php

namespace Database\Factories;

use App\Models\Timetable;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Timetable>
 */
class TimetableFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'institution_id' => 1,
            'class_id' => 1,
            'room_id' => null,
            'course_id' => 1,
            'teacher_id' => null,
            'start_time' => '09:00:00',
            'end_time' => '10:00:00',
            'sequence' => 1,
            'day_of_week' => 'monday',
        ];
    }
}
