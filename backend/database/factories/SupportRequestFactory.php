<?php

namespace Database\Factories;

use App\Models\Institution;
use App\Models\SupportRequest;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class SupportRequestFactory extends Factory
{
    protected $model = SupportRequest::class;

    public function definition(): array
    {
        return [
            'institution_id' => Institution::factory(),
            'requester_id' => User::factory(),
            'approver_id' => null,
            'subject' => $this->faker->sentence(),
            'description' => $this->faker->optional()->paragraph(),
            'priority' => $this->faker->randomElement(['low', 'medium', 'high', 'urgent']),
            'status' => $this->faker->randomElement(['pending', 'approved', 'denied', 'resolved']),
            'category' => $this->faker->optional()->word(),
            'requested_access' => null,
            'notes' => $this->faker->optional()->sentence(),
            'approved_at' => null,
            'denied_at' => null,
            'resolved_by' => null,
            'resolved_at' => null,
        ];
    }

    public function pending(): self
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'pending',
            'approver_id' => null,
            'approved_at' => null,
        ]);
    }

    public function approved(): self
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'approved',
            'approver_id' => User::factory(),
            'approved_at' => now(),
        ]);
    }

    public function highPriority(): self
    {
        return $this->state(fn (array $attributes) => [
            'priority' => 'high',
        ]);
    }
}
