<?php

namespace Database\Factories;

use App\Models\Attendance;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Attendance>
 */
class AttendanceFactory extends Factory
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
            'enrollment_id' => 1,
            'timetable_id' => null,
            'date' => now()->format('Y-m-d'),
            'check_in_time' => null,
            'check_out_time' => null,
            'status' => 'present',
            'justification' => null,
            'is_justified' => false,
            'justified_by' => null,
            'justified_at' => null,
        ];
    }

    public function present(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'present',
        ]);
    }

    public function absent(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'absent',
        ]);
    }

    public function late(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'late',
        ]);
    }

    public function excused(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'excused',
        ]);
    }
}
