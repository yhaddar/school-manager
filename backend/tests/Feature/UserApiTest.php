<?php

namespace Tests\Feature;

use App\Models\Institution;
use App\Models\InstitutionMembership;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class UserApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
    }

    public function test_user_show_returns_authenticated_user_data(): void
    {
        $institution = Institution::create(['name' => 'Test School']);
        $user = User::factory()->student()->create([
            'active_institution_id' => $institution->id,
            'email_verified_at' => now(),
        ]);
        InstitutionMembership::create([
            'institution_id' => $institution->id,
            'user_id' => $user->id,
            'role' => 'student',
            'is_active' => true,
        ]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $user->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $response = $this->withToken($token)
            ->getJson('/api/v1/user')
            ->assertOk();

        $userData = $response->json('data');
        $this->assertEquals($user->email, $userData['email']);
        $this->assertEquals('student', $userData['user_type']);
        $this->assertEquals('student', $userData['membership_role']);
    }

    public function test_user_show_returns_null_member_role_when_not_member(): void
    {
        $institution = Institution::create(['name' => 'Test School']);
        $user = User::factory()->student()->create([
            'active_institution_id' => $institution->id,
            'email_verified_at' => now(),
        ]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $user->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $response = $this->withToken($token)
            ->getJson('/api/v1/user')
            ->assertOk();

        $this->assertNull($response->json('data.membership_role'));
    }

    public function test_tenant_context_endpoint_returns_institution(): void
    {
        $institution = Institution::create(['name' => 'Test School']);
        $user = User::factory()->create([
            'active_institution_id' => $institution->id,
            'email_verified_at' => now(),
        ]);
        InstitutionMembership::create([
            'institution_id' => $institution->id,
            'user_id' => $user->id,
            'role' => 'administrator',
            'is_active' => true,
        ]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $user->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $this->withToken($token)
            ->getJson('/api/v1/tenant-context')
            ->assertOk()
            ->assertJsonPath('data.institution_id', $institution->id);
    }

    public function test_unauthenticated_user_cannot_access_user_endpoint(): void
    {
        $this->getJson('/api/v1/user')
            ->assertStatus(401);
    }

    public function test_user_api_with_admin_user(): void
    {
        $institution = Institution::create(['name' => 'Test School']);
        $user = User::factory()->create([
            'active_institution_id' => $institution->id,
            'email_verified_at' => now(),
        ]);
        InstitutionMembership::create([
            'institution_id' => $institution->id,
            'user_id' => $user->id,
            'role' => 'administrator',
            'is_active' => true,
        ]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $user->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $response = $this->withToken($token)
            ->getJson('/api/v1/user')
            ->assertOk();

        $this->assertEquals('staff', $response->json('data.user_type'));
        $this->assertEquals('administrator', $response->json('data.membership_role'));
    }

    public function test_user_api_with_teacher_user(): void
    {
        $institution = Institution::create(['name' => 'Test School']);
        $user = User::factory()->create([
            'active_institution_id' => $institution->id,
            'email_verified_at' => now(),
        ]);
        InstitutionMembership::create([
            'institution_id' => $institution->id,
            'user_id' => $user->id,
            'role' => 'teacher',
            'is_active' => true,
        ]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $user->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $response = $this->withToken($token)
            ->getJson('/api/v1/user')
            ->assertOk();

        $this->assertEquals('staff', $response->json('data.user_type'));
        $this->assertEquals('teacher', $response->json('data.membership_role'));
    }

    public function test_user_api_with_parent_user(): void
    {
        $institution = Institution::create(['name' => 'Test School']);
        $user = User::factory()->parent()->create([
            'active_institution_id' => $institution->id,
            'email_verified_at' => now(),
        ]);
        InstitutionMembership::create([
            'institution_id' => $institution->id,
            'user_id' => $user->id,
            'role' => 'parent',
            'is_active' => true,
        ]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $user->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $response = $this->withToken($token)
            ->getJson('/api/v1/user')
            ->assertOk();

        $this->assertEquals('parent', $response->json('data.user_type'));
        $this->assertEquals('parent', $response->json('data.membership_role'));
    }
}
