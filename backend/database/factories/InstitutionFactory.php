<?php

namespace Database\Factories;

use App\Models\Institution;
use Illuminate\Database\Eloquent\Factories\Factory;

class InstitutionFactory extends Factory
{
    protected $model = Institution::class;

    public function definition(): array
    {
        return [
            'name' => $this->faker->company(),
            'status' => $this->faker->randomElement(['active', 'inactive', 'suspended', 'archived']),
            'archived_at' => null,
        ];
    }

    public function active(): self
    {
        return $this->state(fn (array $attributes) => ['status' => 'active']);
    }

    public function archived(): self
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'archived',
            'archived_at' => now(),
        ]);
    }
}
