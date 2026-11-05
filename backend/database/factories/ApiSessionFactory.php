<?php

namespace Database\Factories;

use App\Models\ApiSession;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<ApiSession>
 */
class ApiSessionFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'access_token_hash' => hash('sha256', fake()->uuid()),
            'refresh_token_hash' => hash('sha256', fake()->uuid()),
            'access_expires_at' => now()->addMinutes(15),
            'refresh_expires_at' => now()->addDays(30),
        ];
    }
}
