<?php

namespace Tests\Feature;

use App\Models\ApiSession;
use App\Models\AuditEvent;
use App\Models\Institution;
use App\Models\InstitutionMembership;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthSessionTest extends TestCase
{
    use RefreshDatabase;

    public function test_login_issues_a_hashed_session_and_authorizes_the_tenant_context(): void
    {
        $institution = Institution::create(['name' => 'School']);
        $user = User::factory()->create(['active_institution_id' => $institution->id]);
        InstitutionMembership::create([
            'institution_id' => $institution->id,
            'user_id' => $user->id,
            'role' => 'administrator',
        ]);

        $response = $this->withHeader('X-Request-Id', str_repeat('a', 120))->postJson('/api/v1/auth/sessions', [
            'email' => strtoupper($user->email),
            'password' => 'password',
        ])->assertCreated()
            ->assertJsonStructure(['data' => ['access_token', 'refresh_token', 'access_expires_at', 'refresh_expires_at']]);

        $token = $response->json('data.access_token');

        $this->assertDatabaseCount('api_sessions', 1);
        $this->assertDatabaseMissing('api_sessions', ['access_token_hash' => $token]);
        $this->assertDatabaseHas('audit_events', [
            'actor_id' => $user->id,
            'event_type' => 'auth.session_created',
            'outcome' => 'success',
        ]);
        $this->assertSame(100, strlen(AuditEvent::query()->sole()->request_id));

        $this->withToken($token)
            ->getJson('/api/v1/tenant-context')
            ->assertOk()
            ->assertJsonPath('data.institution_id', $institution->id);
    }

    public function test_refresh_rotation_detects_reuse_and_revokes_the_session(): void
    {
        $user = User::factory()->create();
        $login = $this->postJson('/api/v1/auth/sessions', [
            'email' => $user->email,
            'password' => 'password',
        ])->assertCreated();

        $originalRefreshToken = $login->json('data.refresh_token');
        $refreshed = $this->postJson('/api/v1/auth/sessions/refresh', [
            'refresh_token' => $originalRefreshToken,
        ])->assertOk();

        $this->assertNotSame($login->json('data.access_token'), $refreshed->json('data.access_token'));

        $this->postJson('/api/v1/auth/sessions/refresh', [
            'refresh_token' => $originalRefreshToken,
        ])->assertUnauthorized();

        $session = ApiSession::query()->sole();
        $this->assertNotNull($session->revoked_at);
        $this->assertDatabaseHas('audit_events', ['event_type' => 'auth.refresh_reused', 'outcome' => 'denied']);

        $this->withToken($refreshed->json('data.access_token'))
            ->getJson('/api/v1/tenant-context')
            ->assertUnauthorized();
    }

    public function test_logout_revokes_the_current_session(): void
    {
        $user = User::factory()->create();
        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $user->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $this->withToken($token)
            ->deleteJson('/api/v1/auth/sessions/current')
            ->assertNoContent();

        $this->withToken($token)
            ->deleteJson('/api/v1/auth/sessions/current')
            ->assertUnauthorized();

        $this->assertDatabaseHas('audit_events', ['event_type' => 'auth.session_revoked', 'outcome' => 'success']);
    }

    public function test_invalid_credentials_are_throttled(): void
    {
        $user = User::factory()->create();

        foreach (range(1, 5) as $attempt) {
            $this->postJson('/api/v1/auth/sessions', [
                'email' => $user->email,
                'password' => 'wrong-password',
            ])->assertUnprocessable();
        }

        $this->postJson('/api/v1/auth/sessions', [
            'email' => $user->email,
            'password' => 'wrong-password',
        ])->assertStatus(429);
    }
}
