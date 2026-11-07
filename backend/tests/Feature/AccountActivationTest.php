<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AccountActivationTest extends TestCase
{
    use RefreshDatabase;

    public function test_activation_replaces_the_temporary_password_and_issues_a_session(): void
    {
        $user = User::factory()->create([
            'username' => 'student.1001',
            'password' => Hash::make('Temporary#1001'),
            'is_active' => false,
            'activation_expires_at' => now()->addHour(),
        ]);

        $response = $this->postJson('/api/v1/auth/activation', [
            'username' => $user->username,
            'temporary_password' => 'Temporary#1001',
            'password' => 'Personal#1001',
            'password_confirmation' => 'Personal#1001',
        ]);

        $response->assertCreated()
            ->assertJsonStructure(['data' => ['access_token', 'refresh_token', 'access_expires_at', 'refresh_expires_at']]);

        $user->refresh();
        $this->assertTrue($user->is_active);
        $this->assertNotNull($user->activated_at);
        $this->assertNull($user->activation_expires_at);
        $this->assertTrue(Hash::check('Personal#1001', $user->password));
        $this->assertFalse(Hash::check('Temporary#1001', $user->password));
        $this->assertDatabaseHas('audit_events', [
            'actor_id' => $user->id,
            'event_type' => 'auth.account_activated',
            'outcome' => 'success',
        ]);
    }

    public function test_activation_returns_422_when_the_temporary_credential_is_expired(): void
    {
        $user = User::factory()->create([
            'username' => 'student.1002',
            'password' => Hash::make('Temporary#1002'),
            'is_active' => false,
            'activation_expires_at' => now()->subSecond(),
        ]);

        $response = $this->postJson('/api/v1/auth/activation', [
            'username' => $user->username,
            'temporary_password' => 'Temporary#1002',
            'password' => 'Personal#1002',
            'password_confirmation' => 'Personal#1002',
        ]);

        $response->assertUnprocessable()
            ->assertJsonPath('message', 'Invalid activation credentials.');

        $user->refresh();
        $this->assertFalse($user->is_active);
        $this->assertNull($user->activated_at);
        $this->assertTrue(Hash::check('Temporary#1002', $user->password));
        $this->assertDatabaseHas('audit_events', [
            'actor_id' => $user->id,
            'event_type' => 'auth.account_activation_denied',
            'outcome' => 'denied',
        ]);
    }

    public function test_activation_returns_422_when_the_temporary_credential_was_already_used(): void
    {
        $user = User::factory()->create([
            'username' => 'student.1003',
            'password' => Hash::make('Temporary#1003'),
            'is_active' => true,
            'activated_at' => now()->subMinute(),
        ]);

        $response = $this->postJson('/api/v1/auth/activation', [
            'username' => $user->username,
            'temporary_password' => 'Temporary#1003',
            'password' => 'Personal#1003',
            'password_confirmation' => 'Personal#1003',
        ]);

        $response->assertUnprocessable()
            ->assertJsonPath('message', 'Invalid activation credentials.');

        $this->assertDatabaseCount('api_sessions', 0);
    }

    public function test_activation_returns_429_after_five_invalid_attempts(): void
    {
        $user = User::factory()->create([
            'username' => 'student.1004',
            'password' => Hash::make('Temporary#1004'),
            'is_active' => false,
            'activation_expires_at' => now()->addHour(),
        ]);
        $payload = [
            'username' => $user->username,
            'temporary_password' => 'wrong-temporary-password',
            'password' => 'Personal#1004',
            'password_confirmation' => 'Personal#1004',
        ];

        foreach (range(1, 5) as $attempt) {
            $this->postJson('/api/v1/auth/activation', $payload)->assertUnprocessable();
        }

        $this->postJson('/api/v1/auth/activation', $payload)
            ->assertTooManyRequests()
            ->assertJsonPath('message', 'Too many activation attempts.');

        $user->refresh();
        $this->assertFalse($user->is_active);
        $this->assertDatabaseCount('api_sessions', 0);
    }

    public function test_activation_rejects_a_weak_personal_password(): void
    {
        $user = User::factory()->create([
            'username' => 'student.1005',
            'password' => Hash::make('Temporary#1005'),
            'is_active' => false,
            'activation_expires_at' => now()->addHour(),
        ]);

        $response = $this->postJson('/api/v1/auth/activation', [
            'username' => $user->username,
            'temporary_password' => 'Temporary#1005',
            'password' => 'weak',
            'password_confirmation' => 'weak',
        ]);

        $response->assertUnprocessable()->assertJsonValidationErrors('password');

        $user->refresh();
        $this->assertFalse($user->is_active);
        $this->assertDatabaseCount('api_sessions', 0);
    }

    public function test_login_returns_422_for_an_inactive_account(): void
    {
        $user = User::factory()->create([
            'password' => Hash::make('Temporary#1006'),
            'is_active' => false,
            'activation_expires_at' => now()->addHour(),
        ]);

        $response = $this->postJson('/api/v1/auth/sessions', [
            'email' => $user->email,
            'password' => 'Temporary#1006',
        ]);

        $response->assertUnprocessable()
            ->assertJsonPath('message', 'Invalid credentials.');

        $this->assertDatabaseCount('api_sessions', 0);
    }

    public function test_an_existing_session_returns_401_after_its_account_is_deactivated(): void
    {
        $user = User::factory()->create();
        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $user->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');
        $user->forceFill(['is_active' => false])->save();

        $this->withToken($token)
            ->deleteJson('/api/v1/auth/sessions/current')
            ->assertUnauthorized();
    }

    public function test_refresh_returns_401_after_its_account_is_deactivated(): void
    {
        $user = User::factory()->create();
        $refreshToken = $this->postJson('/api/v1/auth/sessions', [
            'email' => $user->email,
            'password' => 'password',
        ])->assertCreated()->json('data.refresh_token');
        $user->forceFill(['is_active' => false])->save();

        $this->postJson('/api/v1/auth/sessions/refresh', ['refresh_token' => $refreshToken])
            ->assertUnauthorized()
            ->assertJsonPath('message', 'Invalid refresh token.');
    }
}
