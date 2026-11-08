<?php

namespace Database\Factories;

use App\Models\CalendarEvent;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<CalendarEvent>
 */
class CalendarEventFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $startDate = $this->faker->dateTimeBetween('now', '+60 days');
        return [
            'institution_id' => 1,
            'title' => $this->faker->sentence,
            'description' => $this->faker->paragraph,
            'type' => $this->faker->randomElement(['holiday', 'exam', 'sports', 'cultural', 'assembly']),
            'starts_at' => $startDate,
            'ends_at' => $startDate->modify('+4 hours'),
            'all_day' => false,
            'data' => [],
        ];
    }
}
