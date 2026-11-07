<?php

namespace Database\Factories;

use App\Models\Institution;
use App\Models\ParentChild;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<ParentChild>
 */
class ParentChildFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'institution_id' => Institution::factory(),
            'parent_user_id' => User::factory()->state(['user_type' => 'parent']),
            'child_user_id' => User::factory()->state(['user_type' => 'student']),
            'is_active' => true,
        ];
    }
}
