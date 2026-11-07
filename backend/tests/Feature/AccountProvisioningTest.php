<?php

namespace Tests\Feature;

use App\Enums\InstitutionRole;
use App\Models\Institution;
use App\Models\InstitutionMembership;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AccountProvisioningTest extends TestCase
{
    use RefreshDatabase;

    private function provisioner(string $role = InstitutionRole::Administrator->value): array
    {
        $institution = Institution::create(['name' => 'School']);
        $user = User::factory()->create([
            'active_institution_id' => $institution->id,
            'is_active' => true,
        ]);
        InstitutionMembership::create([
            'institution_id' => $institution->id,
            'user_id' => $user->id,
            'role' => $role,
            'is_active' => true,
        ]);
        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $user->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        return [$user, $token, $institution];
    }

    public function test_administrator_can_provision_a_staff_account(): void
    {
        [$user, $token, $institution] = $this->provisioner();

        $response = $this->withToken($token)->postJson('/api/v1/management/accounts', [
            'name' => 'John Doe',
            'email' => 'john.doe@school.test',
            'user_type' => 'staff',
            'role' => 'teacher',
        ]);

        $response->assertCreated()
            ->assertJsonStructure([
                'data' => [
                    'user' => ['id', 'name', 'email', 'username', 'user_type'],
                    'temporary_password',
                    'activation_expires_at',
                ],
            ]);

        $data = $response->json('data');
        $this->assertEquals('staff', $data['user']['user_type']);
        $this->assertStringStartsWith('staff.', $data['user']['username']);
        $this->assertNotEmpty($data['temporary_password']);
        $this->assertStringContainsString('T', $data['activation_expires_at']); // ISO 8601 date

        $newUser = User::query()->where('email', 'john.doe@school.test')->first();
        $this->assertNotNull($newUser);
        $this->assertFalse($newUser->is_active);
        $this->assertNotNull($newUser->activation_expires_at);
        $this->assertTrue(Hash::check($data['temporary_password'], $newUser->password));
        $this->assertDatabaseHas('institution_memberships', [
            'user_id' => $newUser->id,
            'institution_id' => $institution->id,
            'role' => 'teacher',
        ]);

        $this->assertDatabaseHas('audit_events', [
            'actor_id' => $user->id,
            'event_type' => 'auth.account_provisioned',
            'outcome' => 'success',
        ]);
    }

    public function test_administrator_can_provision_a_student_account(): void
    {
        [$user, $token] = $this->provisioner();

        $response = $this->withToken($token)->postJson('/api/v1/management/accounts', [
            'name' => 'Jane Student',
            'email' => 'jane.student@school.test',
            'user_type' => 'student',
            'role' => 'student',
        ]);

        $response->assertCreated();

        $data = $response->json('data');
        $this->assertEquals('student', $data['user']['user_type']);
        $this->assertStringStartsWith('student.', $data['user']['username']);
    }

    public function test_administrator_can_supply_preferred_username(): void
    {
        [$user, $token] = $this->provisioner();

        $response = $this->withToken($token)->postJson('/api/v1/management/accounts', [
            'name' => 'Custom Name',
            'email' => 'custom@school.test',
            'username' => 'custom.name',
            'user_type' => 'staff',
            'role' => 'teacher',
        ]);

        $response->assertCreated();
        $data = $response->json('data');
        $this->assertEquals('custom.name', $data['user']['username']);
    }

    public function test_provisioning_generates_unique_username_when_collision(): void
    {
        [$user, $token] = $this->provisioner();

        // First provisioning
        $this->withToken($token)->postJson('/api/v1/management/accounts', [
            'name' => 'Same Name',
            'email' => 'same1@school.test',
            'username' => 'same.name',
            'user_type' => 'staff',
            'role' => 'teacher',
        ])->assertCreated();

        // Second provisioning with same username
        $response = $this->withToken($token)->postJson('/api/v1/management/accounts', [
            'name' => 'Same Name',
            'email' => 'same2@school.test',
            'username' => 'same.name',
            'user_type' => 'staff',
            'role' => 'teacher',
        ]);

        $response->assertCreated();
        $data = $response->json('data');
        $this->assertNotEquals('same.name', $data['user']['username']);
        $this->assertStringStartsWith('same.name-', $data['user']['username']);
    }

    public function test_provisioning_requires_accounts_provision_permission(): void
    {
        [$user, $token, $institution] = $this->provisioner(InstitutionRole::Teacher->value);

        $response = $this->withToken($token)->postJson('/api/v1/management/accounts', [
            'name' => 'John Doe',
            'email' => 'john.doe@school.test',
            'user_type' => 'staff',
            'role' => 'teacher',
        ]);

        $response->assertForbidden();
    }

    public function test_provisioning_rejects_invalid_user_type(): void
    {
        [$user, $token] = $this->provisioner();

        $response = $this->withToken($token)->postJson('/api/v1/management/accounts', [
            'name' => 'John Doe',
            'email' => 'john.doe@school.test',
            'user_type' => 'invalid',
            'role' => 'teacher',
        ]);

        $response->assertUnprocessable();
    }

    public function test_provisioning_rejects_inactive_institution(): void
    {
        $institution = Institution::create(['name' => 'Inactive School', 'status' => 'inactive']);
        $user = User::factory()->create(['active_institution_id' => $institution->id]);
        InstitutionMembership::create([
            'institution_id' => $institution->id,
            'user_id' => $user->id,
            'role' => InstitutionRole::Administrator->value,
            'is_active' => true,
        ]);
        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $user->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $response = $this->withToken($token)->postJson('/api/v1/management/accounts', [
            'name' => 'John Doe',
            'email' => 'john.doe@school.test',
            'user_type' => 'staff',
            'role' => 'teacher',
        ]);

        $response->assertForbidden();
    }

    public function test_username_availability_endpoint_returns_true_for_available(): void
    {
        [$user, $token] = $this->provisioner();

        $response = $this->withToken($token)->getJson('/api/v1/management/accounts/username-availability?username=available.name&user_type=staff');

        $response->assertOk()->assertJsonPath('data.available', true);
    }

    public function test_username_availability_endpoint_returns_false_for_taken(): void
    {
        [$user, $token] = $this->provisioner();
        User::factory()->create(['username' => 'taken.name', 'active_institution_id' => $user->active_institution_id]);

        $response = $this->withToken($token)->getJson('/api/v1/management/accounts/username-availability?username=taken.name&user_type=staff');

        $response->assertOk()->assertJsonPath('data.available', false);
    }

    public function test_username_availability_requires_permission(): void
    {
        [$user, $token] = $this->provisioner(InstitutionRole::Teacher->value);

        $response = $this->withToken($token)->getJson('/api/v1/management/accounts/username-availability?username=test&user_type=staff');

        $response->assertForbidden();
    }

    public function test_provisioned_account_can_activate_with_temporary_password(): void
    {
        [$admin, $token] = $this->provisioner();

        $provisionResponse = $this->withToken($token)->postJson('/api/v1/management/accounts', [
            'name' => 'Activatable User',
            'email' => 'activatable@school.test',
            'user_type' => 'staff',
            'role' => 'teacher',
        ])->assertCreated();

        $data = $provisionResponse->json('data');
        $tempPassword = $data['temporary_password'];
        $username = $data['user']['username'];

        $activationResponse = $this->postJson('/api/v1/auth/activation', [
            'username' => $username,
            'temporary_password' => $tempPassword,
            'password' => 'Personal#123456',
            'password_confirmation' => 'Personal#123456',
        ]);

        $activationResponse->assertCreated()
            ->assertJsonStructure(['data' => ['access_token', 'refresh_token']]);

        $user = User::query()->where('username', $username)->first();
        $this->assertTrue($user->is_active);
        $this->assertTrue(Hash::check('Personal#123456', $user->password));
    }
}
