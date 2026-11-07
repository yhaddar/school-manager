<?php

namespace Tests\Feature;

use App\Models\Institution;
use App\Models\InstitutionMembership;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class InstitutionRbacTest extends TestCase
{
    use RefreshDatabase;

    public function test_administrator_can_manage_accounts_inside_active_institution(): void
    {
        [$user, $token] = $this->member('administrator');

        $this->withToken($token)->getJson('/api/v1/management/accounts')->assertOk();
    }

    public function test_professor_cannot_manage_accounts(): void
    {
        [, $token] = $this->member('professor');

        $this->withToken($token)->getJson('/api/v1/management/accounts')->assertForbidden();
    }

    public function test_inactive_membership_cannot_manage_accounts(): void
    {
        [, $token, $membership] = $this->member('administrator');
        $membership->update(['is_active' => false]);

        $this->withToken($token)->getJson('/api/v1/management/accounts')->assertForbidden();
    }

    public function test_institution_header_cannot_change_permission_context(): void
    {
        [, $token] = $this->member('professor');
        $other = Institution::create(['name' => 'Other School']);

        $this->withToken($token)->withHeader('X-Institution-Id', $other->id)
            ->getJson('/api/v1/management/accounts')->assertForbidden();
    }

    public function test_inactive_account_cannot_use_management_permission(): void
    {
        [$user, $token] = $this->member('administrator');
        $user->forceFill(['is_active' => false])->save();

        $this->withToken($token)->getJson('/api/v1/management/accounts')->assertUnauthorized();
    }

    private function member(string $role): array
    {
        $institution = Institution::create(['name' => 'School']);
        $user = User::factory()->create(['active_institution_id' => $institution->id]);
        $membership = InstitutionMembership::create([
            'institution_id' => $institution->id,
            'user_id' => $user->id,
            'role' => $role,
        ]);
        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $user->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        return [$user, $token, $membership];
    }
}
