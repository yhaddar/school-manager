<?php

namespace Database\Factories;

use App\Models\Report;
use Illuminate\Database\Eloquent\Factories\Factory;

class ReportFactory extends Factory
{
    protected $model = Report::class;

    public function definition(): array
    {
        return [
            'institution_id' => 1,
            'title' => $this->faker->sentence(),
            'slug' => $this->faker->unique()->slug(),
            'description' => $this->faker->optional()->sentence(),
            'type' => $this->faker->randomElement(['academic', 'attendance', 'financial', 'enrollment', 'custom']),
            'parameters' => [],
            'columns' => [],
            'format' => $this->faker->randomElement(['pdf', 'excel', 'csv']),
            'status' => $this->faker->randomElement(['pending', 'generating', 'completed', 'failed']),
            'file_path' => $this->faker->optional()->word(),
            'file_name' => $this->faker->optional()->word(),
            'file_size' => $this->faker->optional()->numberBetween(1000, 5000000),
            'generated_at' => null,
            'expires_at' => null,
            'created_by' => 1,
        ];
    }
}
