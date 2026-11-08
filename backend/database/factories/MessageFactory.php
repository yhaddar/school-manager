<?php

namespace Database\Factories;

use App\Models\Message;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Message>
 */
class MessageFactory extends Factory
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
            'sender_id' => 1,
            'subject' => $this->faker->sentence,
            'message' => $this->faker->paragraph,
            'type' => $this->faker->randomElement(['announcement', 'parent-teacher', 'admin-staff']),
            'recipient_type' => $this->faker->randomElement(['parent', 'teacher', 'student']),
            'recipient_id' => null,
            'data' => [],
            'is_read' => false,
        ];
    }
}
