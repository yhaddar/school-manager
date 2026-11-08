<?php

namespace Database\Factories;

use App\Models\Import;
use Illuminate\Database\Eloquent\Factories\Factory;

class ImportFactory extends Factory
{
    protected $model = Import::class;

    public function definition(): array
    {
        return [
            'institution_id' => 1,
            'title' => $this->faker->sentence(),
            'entity_type' => $this->faker->randomElement(['students', 'teachers', 'courses', 'enrollments', 'grades', 'attendance']),
            'format' => $this->faker->randomElement(['excel', 'csv']),
            'status' => $this->faker->randomElement(['pending', 'validating', 'processing', 'completed', 'failed']),
            'file_path' => $this->faker->word(),
            'original_file_name' => $this->faker->word() . '.csv',
            'file_size' => $this->faker->numberBetween(1000, 5000000),
            'total_rows' => $this->faker->numberBetween(1, 1000),
            'processed_rows' => 0,
            'successful_rows' => 0,
            'failed_rows' => 0,
            'validation_errors' => [],
            'import_errors' => [],
            'started_at' => null,
            'completed_at' => null,
            'requested_by' => 1,
        ];
    }
}
