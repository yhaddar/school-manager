<?php

namespace Database\Factories;

use App\Models\Export;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class ExportFactory extends Factory
{
    protected $model = Export::class;

    public function definition(): array
    {
        return [
            'institution_id' => 1,
            'title' => $this->faker->sentence(),
            'entity_type' => $this->faker->randomElement(['students', 'teachers', 'grades', 'attendance', 'enrollments', 'courses', 'messages', 'notifications', 'events', 'calendar_events']),
            'filters' => [],
            'columns' => [],
            'format' => $this->faker->randomElement(['excel', 'csv']),
            'status' => $this->faker->randomElement(['pending', 'processing', 'completed', 'failed']),
            'file_path' => $this->faker->word(),
            'file_name' => $this->faker->word(),
            'file_size' => $this->faker->numberBetween(1000, 5000000),
            'record_count' => $this->faker->numberBetween(1, 1000),
            'started_at' => null,
            'completed_at' => null,
            'expires_at' => null,
            'error_message' => null,
            'requested_by' => 1,
        ];
    }
}
