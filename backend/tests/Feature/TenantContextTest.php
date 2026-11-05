<?php

namespace Tests\Feature;

use App\Models\Institution;
use App\Models\InstitutionMembership;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TenantContextTest extends TestCase
{
    use RefreshDatabase;

    public function test_tenant_context_comes_from_the_server_side_active_membership(): void
    {
        $activeInstitution = Institution::create(['name' => 'Active School']);
        $attemptedInstitution = Institution::create(['name' => 'Other School']);
        $user = User::factory()->create(['active_institution_id' => $activeInstitution->id]);
        InstitutionMembership::create([
            'institution_id' => $activeInstitution->id,
            'user_id' => $user->id,
            'role' => 'administrator',
        ]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $user->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $this->withToken($token)
            ->withHeader('X-Institution-Id', $attemptedInstitution->id)
            ->getJson('/api/v1/tenant-context')
            ->assertOk()
            ->assertJsonPath('data.institution_id', $activeInstitution->id);
    }

    public function test_tenant_context_denies_users_without_an_active_membership(): void
    {
        $user = User::factory()->create();
        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $user->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $this->withToken($token)
            ->getJson('/api/v1/tenant-context')
            ->assertForbidden();
    }
}
