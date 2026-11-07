<?php

namespace Database\Factories;

use App\Models\Institution;
use App\Models\ParentInvitation;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<ParentInvitation>
 */
class ParentInvitationFactory extends Factory
{
    /**
     * The current password being used by the factory.
     */
    protected static ?string $password;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'institution_id' => Institution::factory(),
            'student_id' => User::factory()->state(['user_type' => 'student']),
            'issued_by' => User::factory()->state(['user_type' => 'parent']),
            'code_hash' => hash('sha256', Str::upper(Str::random(8))),
            'expires_at' => now()->addDays(3),
            'accepted_at' => null,
            'revoked_at' => null,
        ];
    }
}
