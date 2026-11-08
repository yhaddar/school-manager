<?php

namespace Database\Factories;

use App\Models\SubscriptionPlan;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class SubscriptionPlanFactory extends Factory
{
    protected $model = SubscriptionPlan::class;

    public function definition(): array
    {
        return [
            'name' => $this->faker->unique()->words(2, true),
            'tier' => $this->faker->unique()->slug(),
            'features' => null,
            'storage_limit_gb' => $this->faker->numberBetween(10, 1000),
            'user_limit' => $this->faker->optional()->numberBetween(50, 1000),
            'api_rate_limit' => $this->faker->optional()->numberBetween(1000, 50000),
            'price_monthly' => 0.00,
            'price_yearly' => 0.00,
            'is_active' => true,
            'created_by' => User::factory(),
        ];
    }
}
