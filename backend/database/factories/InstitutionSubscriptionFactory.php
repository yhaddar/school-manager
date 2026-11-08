<?php

namespace Database\Factories;

use App\Models\Institution;
use App\Models\InstitutionSubscription;
use App\Models\SubscriptionPlan;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class InstitutionSubscriptionFactory extends Factory
{
    protected $model = InstitutionSubscription::class;

    public function definition(): array
    {
        return [
            'institution_id' => Institution::factory(),
            'plan_id' => SubscriptionPlan::factory(),
            'start_date' => now()->subYear(),
            'end_date' => now()->addYear(),
            'billing_cycle' => $this->faker->randomElement(['monthly', 'yearly']),
            'status' => $this->faker->randomElement(['active', 'pending', 'expired', 'suspended']),
            'notes' => $this->faker->optional()->sentence(),
            'created_by' => User::factory(),
        ];
    }
}
