<?php

namespace Database\Factories;

use App\Models\SupportRequest;
use App\Models\SupportSession;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

class SupportSessionFactory extends Factory
{
    protected $model = SupportSession::class;

    public function definition(): array
    {
        return [
            'support_request_id' => SupportRequest::factory(),
            'accessor_id' => User::factory(),
            'session_token' => Str::random(64),
            'expires_at' => now()->addHours(2),
            'started_at' => now(),
            'ended_at' => null,
            'status' => 'active',
            'actions_logged' => null,
        ];
    }

    public function ended(): self
    {
        return $this->state(fn (array $attributes) => [
            'ended_at' => now()->subHour(),
            'status' => 'terminated',
        ]);
    }

    public function expired(): self
    {
        return $this->state(fn (array $attributes) => [
            'expires_at' => now()->subHour(),
            'status' => 'expired',
        ]);
    }
}
