<?php

namespace Database\Factories;

use App\Models\Event;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Event>
 */
class EventFactory extends Factory
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
            'title' => $this->faker->sentence,
            'description' => $this->faker->paragraph,
            'type' => $this->faker->randomElement(['holiday', 'exam', 'sports', 'cultural', 'assembly']),
            'start_date' => $this->faker->dateTimeBetween('now', '+30 days')->format('Y-m-d'),
            'end_date' => $this->faker->optional()->dateTimeBetween('now', '+60 days')->format('Y-m-d'),
            'start_time' => $this->faker->optional()->time('H:i:s'),
            'end_time' => $this->faker->optional()->time('H:i:s'),
            'all_day' => false,
            'data' => [],
            'status' => $this->faker->randomElement(['upcoming', 'ongoing', 'completed', 'cancelled']),
        ];
    }
}
