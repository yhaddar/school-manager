<?php

namespace Tests\Feature\SuperAdmin;

use App\Models\Institution;
use App\Models\InstitutionSubscription;
use App\Models\SubscriptionPlan;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SubscriptionControllerTest extends TestCase
{
    use RefreshDatabase;

    private function createSuperAdmin(): array
    {
        $user = User::factory()->create(['user_type' => 'staff']);
        $institution = Institution::create(['name' => 'Platform', 'status' => 'active']);
        $user->forceFill(['active_institution_id' => $institution->id])->save();
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

    private function createNonSuperAdminUser(): array
    {
        $user = User::factory()->create(['user_type' => 'staff']);
        $institution = Institution::create(['name' => 'Platform', 'status' => 'active']);
        $user->forceFill(['active_institution_id' => $institution->id])->save();

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $user->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        return [$user, $token, $institution];
    }

    public function test_super_admin_can_list_subscription_plans(): void
    {
        [$user, $token] = $this->createSuperAdmin();

        SubscriptionPlan::factory()->create(['name' => 'Basic Plan', 'tier' => 'basic']);
        SubscriptionPlan::factory()->create(['name' => 'Enterprise Plan', 'tier' => 'enterprise']);

        $this->withToken($token)
            ->getJson('/api/v1/super-admin/subscriptions')
            ->assertOk()
            ->assertJsonCount(2, 'data');
    }

    public function test_non_super_admin_cannot_list_subscription_plans(): void
    {
        [$user, $token] = $this->createNonSuperAdminUser();

        $this->withToken($token)
            ->getJson('/api/v1/super-admin/subscriptions')
            ->assertForbidden();
    }

    public function test_super_admin_can_create_subscription_plan(): void
    {
        [$user, $token] = $this->createSuperAdmin();

        $this->withToken($token)
            ->postJson('/api/v1/super-admin/subscriptions', [
                'name' => 'New Plan',
                'tier' => 'basic',
                'price_monthly' => 9.99,
                'price_yearly' => 99.99,
            ])
            ->assertCreated()
            ->assertJsonPath('data.name', 'New Plan');
    }

    public function test_super_admin_can_update_subscription_plan(): void
    {
        [$user, $token] = $this->createSuperAdmin();
        $plan = SubscriptionPlan::factory()->create(['tier' => 'basic', 'name' => 'Basic']);

        $this->withToken($token)
            ->putJson('/api/v1/super-admin/subscriptions/' . $plan->id, [
                'name' => 'Updated Basic Plan',
                'is_active' => false,
            ])
            ->assertOk()
            ->assertJsonPath('data.name', 'Updated Basic Plan')
            ->assertJsonPath('data.is_active', false);
    }

    public function test_super_admin_can_delete_subscription_plan(): void
    {
        [$user, $token] = $this->createSuperAdmin();
        $plan = SubscriptionPlan::factory()->create();

        $this->withToken($token)
            ->deleteJson('/api/v1/super-admin/subscriptions/' . $plan->id)
            ->assertNoContent();

        $this->assertDatabaseMissing('subscription_plans', ['id' => $plan->id]);
    }

    public function test_cannot_delete_subscription_plan_with_assignments(): void
    {
        [$user, $token] = $this->createSuperAdmin();
        $plan = SubscriptionPlan::factory()->create();
        $institution = Institution::factory()->create();
        InstitutionSubscription::factory()->create(['plan_id' => $plan->id, 'institution_id' => $institution->id]);

        $this->withToken($token)
            ->deleteJson('/api/v1/super-admin/subscriptions/' . $plan->id)
            ->assertUnprocessable();
    }

    public function test_super_admin_can_show_subscription_plan(): void
    {
        [$user, $token] = $this->createSuperAdmin();
        $plan = SubscriptionPlan::factory()->create();

        $this->withToken($token)
            ->getJson('/api/v1/super-admin/subscriptions/' . $plan->id)
            ->assertOk()
            ->assertJsonPath('data.id', $plan->id);
    }

    public function test_super_admin_can_assign_plan_to_institution(): void
    {
        [$user, $token] = $this->createSuperAdmin();
        $plan = SubscriptionPlan::factory()->create();
        $institution = Institution::factory()->create();

        $this->withToken($token)
            ->postJson('/api/v1/super-admin/institutions/' . $institution->id . '/subscription', [
                'plan_id' => $plan->id,
                'start_date' => now()->format('Y-m-d'),
                'end_date' => now()->addYear()->format('Y-m-d'),
                'billing_cycle' => 'yearly',
            ])
            ->assertCreated()
            ->assertJsonPath('data.plan_id', $plan->id)
            ->assertJsonPath('data.institution_id', $institution->id);
    }

    public function test_super_admin_can_renew_subscription(): void
    {
        [$user, $token] = $this->createSuperAdmin();
        $institution = Institution::factory()->create();
        $subscription = InstitutionSubscription::factory()->create([
            'institution_id' => $institution->id,
            'status' => 'expired',
        ]);

        $this->withToken($token)
            ->postJson('/api/v1/super-admin/institutions/' . $institution->id . '/subscription/renew', [
                'new_end_date' => now()->addYear()->format('Y-m-d'),
                'notes' => 'Renewed subscription',
            ])
            ->assertOk()
            ->assertJsonPath('data.status', 'active');
    }

    public function test_super_admin_can_list_institution_subscriptions(): void
    {
        [$user, $token] = $this->createSuperAdmin();
        InstitutionSubscription::factory()->create(['status' => 'active']);
        InstitutionSubscription::factory()->create(['status' => 'expired']);

        $this->withToken($token)
            ->getJson('/api/v1/super-admin/subscriptions/list')
            ->assertOk();
    }

    public function test_super_admin_can_get_subscription_history(): void
    {
        [$user, $token, $institution] = $this->createSuperAdmin();
        $subscription = InstitutionSubscription::factory()->create(['institution_id' => $institution->id]);

        $this->withToken($token)
            ->getJson('/api/v1/super-admin/institutions/' . $institution->id . '/subscription/history')
            ->assertOk();
    }

    public function test_super_admin_can_filter_subscriptions_by_status(): void
    {
        [$user, $token] = $this->createSuperAdmin();
        InstitutionSubscription::factory()->create(['status' => 'active']);
        InstitutionSubscription::factory()->create(['status' => 'expired']);

        $this->withToken($token)
            ->getJson('/api/v1/super-admin/subscriptions/list?status=active')
            ->assertOk();
    }
}
