<?php

namespace Tests\Feature\SuperAdmin;

use App\Models\Institution;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class InstitutionControllerTest extends TestCase
{
    use RefreshDatabase;

    private function createSuperAdmin(): array
    {
        $user = User::factory()->create([
            'user_type' => 'staff',
        ]);
        
        // For platform-level super-admin, we just need the user_type to be staff
        // and the platform-permission gate to check for super-admin role
        // Create a separate institution for the super-admin to exist in
        $institution = Institution::create(['name' => 'Platform', 'status' => 'active']);
        $user->forceFill(['active_institution_id' => $institution->id])->save();
        
        // Link with super-admin role
        $institution->memberships()->create([
            'user_id' => $user->id,
            'role' => 'super-admin',
            'is_active' => true,
        ]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $user->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        return [$user, $token, $institution];
    }

    public function test_super_admin_can_list_institutions(): void
    {
        [$user, $token] = $this->createSuperAdmin();
        
        Institution::create(['name' => 'School A', 'status' => 'active']);
        Institution::create(['name' => 'School B', 'status' => 'inactive']);

        $this->withToken($token)
            ->getJson('/api/v1/super-admin/institutions')
            ->assertOk()
            ->assertJsonCount(3, 'data');
    }

    public function test_non_super_admin_cannot_list_institutions(): void
    {
        $institution = Institution::create(['name' => 'Test School']);
        $user = User::factory()->create(['active_institution_id' => $institution->id]);
        
        $institution->memberships()->create([
            'user_id' => $user->id,
            'role' => 'administrator',
            'is_active' => true,
        ]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $user->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $this->withToken($token)
            ->getJson('/api/v1/super-admin/institutions')
            ->assertForbidden();
    }

    public function test_super_admin_can_create_institution(): void
    {
        [$user, $token] = $this->createSuperAdmin();

        $this->withToken($token)
            ->postJson('/api/v1/super-admin/institutions', [
                'name' => 'New School',
            ])
            ->assertCreated()
            ->assertJsonPath('data.name', 'New School');
    }

    public function test_super_admin_can_show_institution(): void
    {
        [$user, $token, $institution] = $this->createSuperAdmin();

        $this->withToken($token)
            ->getJson('/api/v1/super-admin/institutions/' . $institution->id)
            ->assertOk()
            ->assertJsonPath('data.name', $institution->name);
    }

    public function test_super_admin_can_update_institution(): void
    {
        [$user, $token, $institution] = $this->createSuperAdmin();

        $this->withToken($token)
            ->putJson('/api/v1/super-admin/institutions/' . $institution->id, [
                'name' => 'Updated School Name',
            ])
            ->assertOk()
            ->assertJsonPath('data.name', 'Updated School Name');
    }

    public function test_super_admin_can_deactivate_institution(): void
    {
        [$user, $token, $institution] = $this->createSuperAdmin();
        
        // Create another institution to deactivate
        $otherInstitution = Institution::create(['name' => 'Other School', 'status' => 'active']);

        // The current user's membership stays active (super-admin can manage other institutions)
        // Deactivate other memberships first
        $otherInstitution->memberships()->update(['is_active' => false]);

        $this->withToken($token)
            ->deleteJson('/api/v1/super-admin/institutions/' . $otherInstitution->id)
            ->assertOk()
            ->assertJsonPath('data.status', 'inactive');
    }

    public function test_super_admin_cannot_deactivate_institution_with_active_memberships(): void
    {
        [$user, $token, $institution] = $this->createSuperAdmin();
        
        $student = User::factory()->create([
            'active_institution_id' => $institution->id,
            'user_type' => 'student',
        ]);
        
        $institution->memberships()->create([
            'user_id' => $student->id,
            'role' => 'student',
            'is_active' => true,
        ]);

        $this->withToken($token)
            ->deleteJson('/api/v1/super-admin/institutions/' . $institution->id)
            ->assertUnprocessable();
    }

    public function test_non_super_admin_cannot_create_institution(): void
    {
        [$user, $token] = $this->createSuperAdmin();

        // Change role from super-admin to regular admin
        $user->institutionMemberships()->update(['role' => 'administrator']);

        $this->withToken($token)
            ->postJson('/api/v1/super-admin/institutions', [
                'name' => 'New School',
            ])
            ->assertForbidden();
    }
}
