<?php

namespace Tests\Feature;

use App\Enums\InstitutionRole;
use App\Models\Institution;
use App\Models\InstitutionMembership;
use App\Models\ParentInvitation;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class ParentInvitationTest extends TestCase
{
    use RefreshDatabase;

    private function adminWithInstitution(): array
    {
        $institution = Institution::create(['name' => 'School']);
        $user = User::factory()->create([
            'active_institution_id' => $institution->id,
            'is_active' => true,
        ]);
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

        return [$user, $token, $institution];
    }

    private function student(string $email = 'student@school.test'): array
    {
        [$admin, $token, $institution] = $this->adminWithInstitution();
        $student = User::factory()->create([
            'name' => 'Test Student',
            'email' => $email,
            'user_type' => 'student',
            'is_active' => true,
            'active_institution_id' => $institution->id,
        ]);
        InstitutionMembership::create([
            'institution_id' => $institution->id,
            'user_id' => $student->id,
            'role' => InstitutionRole::Student->value,
            'is_active' => true,
        ]);

        return [$admin, $token, $institution, $student];
    }

    public function test_administrator_can_issue_parent_invitation(): void
    {
        [$admin, $token, $institution, $student] = $this->student();

        $response = $this->withToken($token)->postJson('/api/v1/management/parent-invitations', [
            'student_email' => $student->email,
        ]);

        $response->assertCreated()
            ->assertJsonStructure([
                'data' => [
                    'invitation_id',
                    'student' => ['id', 'name', 'email'],
                    'invitation_code',
                    'expires_at',
                ],
            ]);

        $data = $response->json('data');
        $this->assertNotEmpty($data['invitation_code']);
        $this->assertEquals(8, strlen($data['invitation_code']));
        $this->assertStringContainsString('T', $data['expires_at']);

        $this->assertDatabaseHas('parent_invitations', [
            'institution_id' => $institution->id,
            'student_id' => $student->id,
            'issued_by' => $admin->id,
        ]);

        $this->assertDatabaseHas('audit_events', [
            'actor_id' => $admin->id,
            'event_type' => 'parent.invitation_issued',
            'outcome' => 'success',
        ]);
    }

    public function test_issuing_duplicate_invitation_returns_existing(): void
    {
        [$admin, $token, $institution, $student] = $this->student();

        $first = $this->withToken($token)->postJson('/api/v1/management/parent-invitations', [
            'student_email' => $student->email,
        ])->assertCreated();

        $second = $this->withToken($token)->postJson('/api/v1/management/parent-invitations', [
            'student_email' => $student->email,
        ])->assertOk();

        $firstCode = $first->json('data.invitation_code');
        $secondCode = $second->json('data.invitation_code');

        // Second request should not return a new code (already delivered)
        $this->assertNull($secondCode);
        $this->assertDatabaseCount('parent_invitations', 1);
    }

    public function test_teacher_can_issue_parent_invitation(): void
    {
        $institution = Institution::create(['name' => 'School']);
        $teacher = User::factory()->create(['active_institution_id' => $institution->id, 'is_active' => true]);
        InstitutionMembership::create([
            'institution_id' => $institution->id,
            'user_id' => $teacher->id,
            'role' => InstitutionRole::Teacher->value,
            'is_active' => true,
        ]);
        $student = User::factory()->create([
            'name' => 'Test Student',
            'email' => 'student@school.test',
            'user_type' => 'student',
            'is_active' => true,
            'active_institution_id' => $institution->id,
        ]);
        InstitutionMembership::create([
            'institution_id' => $institution->id,
            'user_id' => $student->id,
            'role' => InstitutionRole::Student->value,
            'is_active' => true,
        ]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $teacher->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $response = $this->withToken($token)->postJson('/api/v1/management/parent-invitations', [
            'student_email' => $student->email,
        ]);

        $response->assertCreated();
    }

    public function test_student_cannot_issue_parent_invitation(): void
    {
        $institution = Institution::create(['name' => 'School']);
        $student = User::factory()->create(['active_institution_id' => $institution->id, 'is_active' => true]);
        InstitutionMembership::create([
            'institution_id' => $institution->id,
            'user_id' => $student->id,
            'role' => InstitutionRole::Student->value,
            'is_active' => true,
        ]);

        $targetStudent = User::factory()->create([
            'name' => 'Target Student',
            'email' => 'target@school.test',
            'user_type' => 'student',
            'is_active' => true,
            'active_institution_id' => $institution->id,
        ]);
        InstitutionMembership::create([
            'institution_id' => $institution->id,
            'user_id' => $targetStudent->id,
            'role' => InstitutionRole::Student->value,
            'is_active' => true,
        ]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $student->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $response = $this->withToken($token)->postJson('/api/v1/management/parent-invitations', [
            'student_email' => $targetStudent->email,
        ]);

        $response->assertForbidden();
    }

    public function test_invitation_rejects_student_from_other_institution(): void
    {
        [$admin, $token, $institution] = $this->adminWithInstitution();
        $otherInstitution = Institution::create(['name' => 'Other School']);
        $otherStudent = User::factory()->create([
            'name' => 'Other Student',
            'email' => 'other@school.test',
            'user_type' => 'student',
            'is_active' => true,
            'active_institution_id' => $otherInstitution->id,
        ]);
        InstitutionMembership::create([
            'institution_id' => $otherInstitution->id,
            'user_id' => $otherStudent->id,
            'role' => InstitutionRole::Student->value,
            'is_active' => true,
        ]);

        $response = $this->withToken($token)->postJson('/api/v1/management/parent-invitations', [
            'student_email' => $otherStudent->email,
        ]);

        $response->assertNotFound();
    }

    public function test_invitation_rejects_non_student_account(): void
    {
        [$admin, $token, $institution] = $this->adminWithInstitution();
        $staff = User::factory()->create([
            'name' => 'Staff',
            'email' => 'staff@school.test',
            'user_type' => 'staff',
            'is_active' => true,
            'active_institution_id' => $institution->id,
        ]);
        InstitutionMembership::create([
            'institution_id' => $institution->id,
            'user_id' => $staff->id,
            'role' => InstitutionRole::Teacher->value,
            'is_active' => true,
        ]);

        $response = $this->withToken($token)->postJson('/api/v1/management/parent-invitations', [
            'student_email' => $staff->email,
        ]);

        $response->assertNotFound();
    }

    public function test_parent_can_accept_invitation(): void
    {
        [$admin, $token, $institution, $student] = $this->student();

        $invitationResponse = $this->withToken($token)->postJson('/api/v1/management/parent-invitations', [
            'student_email' => $student->email,
        ])->assertCreated();

        $code = $invitationResponse->json('data.invitation_code');

        $acceptResponse = $this->postJson('/api/v1/auth/parent-invitations/accept', [
            'invitation_code' => $code,
            'parent_name' => 'Test Parent',
            'parent_email' => 'parent@test.com',
            'password' => 'Personal#123456',
            'password_confirmation' => 'Personal#123456',
        ]);

        $acceptResponse->assertCreated()
            ->assertJsonStructure([
                'data' => [
                    'parent' => ['id', 'name', 'email'],
                    'child' => ['id', 'name'],
                ],
            ]);

        $data = $acceptResponse->json('data');
        $this->assertEquals('Test Parent', $data['parent']['name']);
        $this->assertEquals('parent@test.com', $data['parent']['email']);
        $this->assertEquals($student->id, $data['child']['id']);

        $parent = User::query()->where('email', 'parent@test.com')->first();
        $this->assertNotNull($parent);
        $this->assertEquals('parent', $parent->user_type->value);
        $this->assertTrue($parent->is_active);
        $this->assertTrue(Hash::check('Personal#123456', $parent->password));

        $this->assertDatabaseHas('parent_children', [
            'parent_user_id' => $parent->id,
            'child_user_id' => $student->id,
            'institution_id' => $institution->id,
        ]);

        $invitation = ParentInvitation::query()->where('id', $invitationResponse->json('data.invitation_id'))->first();
        $this->assertNotNull($invitation->accepted_at);

        $this->assertDatabaseHas('audit_events', [
            'actor_id' => $parent->id,
            'event_type' => 'parent.accepted',
            'outcome' => 'success',
        ]);
    }

    public function test_accepting_invalid_code_returns_422(): void
    {
        $response = $this->postJson('/api/v1/auth/parent-invitations/accept', [
            'invitation_code' => 'INVALIDCODE',
            'parent_name' => 'Test Parent',
            'parent_email' => 'parent@test.com',
            'password' => 'Personal#123456',
            'password_confirmation' => 'Personal#123456',
        ]);

        $response->assertUnprocessable()
            ->assertJsonPath('message', 'Invalid or expired invitation code.');
    }

    public function test_accepting_expired_invitation_returns_422(): void
    {
        [$admin, $token, $institution, $student] = $this->student();

        $invitation = ParentInvitation::query()->create([
            'institution_id' => $institution->id,
            'student_id' => $student->id,
            'issued_by' => $admin->id,
            'code_hash' => hash('sha256', 'EXPIRED'),
            'expires_at' => now()->subDay(),
        ]);

        $response = $this->postJson('/api/v1/auth/parent-invitations/accept', [
            'invitation_code' => 'EXPIRED',
            'parent_name' => 'Test Parent',
            'parent_email' => 'parent@test.com',
            'password' => 'Personal#123456',
            'password_confirmation' => 'Personal#123456',
        ]);

        $response->assertUnprocessable();
    }

    public function test_accepting_already_accepted_invitation_returns_422(): void
    {
        [$admin, $token, $institution, $student] = $this->student();

        $invitation = ParentInvitation::query()->create([
            'institution_id' => $institution->id,
            'student_id' => $student->id,
            'issued_by' => $admin->id,
            'code_hash' => hash('sha256', 'ACCEPTED'),
            'expires_at' => now()->addDays(3),
            'accepted_at' => now()->subHour(),
        ]);

        $response = $this->postJson('/api/v1/auth/parent-invitations/accept', [
            'invitation_code' => 'ACCEPTED',
            'parent_name' => 'Test Parent',
            'parent_email' => 'parent@test.com',
            'password' => 'Personal#123456',
            'password_confirmation' => 'Personal#123456',
        ]);

        $response->assertUnprocessable();
    }

    public function test_accepting_revoked_invitation_returns_422(): void
    {
        [$admin, $token, $institution, $student] = $this->student();

        $invitation = ParentInvitation::query()->create([
            'institution_id' => $institution->id,
            'student_id' => $student->id,
            'issued_by' => $admin->id,
            'code_hash' => hash('sha256', 'REVOKED'),
            'expires_at' => now()->addDays(3),
            'revoked_at' => now()->subHour(),
        ]);

        $response = $this->postJson('/api/v1/auth/parent-invitations/accept', [
            'invitation_code' => 'REVOKED',
            'parent_name' => 'Test Parent',
            'parent_email' => 'parent@test.com',
            'password' => 'Personal#123456',
            'password_confirmation' => 'Personal#123456',
        ]);

        $response->assertUnprocessable();
    }

    public function test_acceptance_throttles_invalid_attempts(): void
    {
        [$admin, $token, $institution, $student] = $this->student();

        $invitation = ParentInvitation::query()->create([
            'institution_id' => $institution->id,
            'student_id' => $student->id,
            'issued_by' => $admin->id,
            'code_hash' => hash('sha256', 'THROTTLE'),
            'expires_at' => now()->addDays(3),
        ]);

        $payload = [
            'invitation_code' => 'WRONG',
            'parent_name' => 'Test Parent',
            'parent_email' => 'parent@test.com',
            'password' => 'Personal#123456',
            'password_confirmation' => 'Personal#123456',
        ];

        // First 4 attempts should be 422 (rate limiter hit but not exceeded)
        foreach (range(1, 4) as $attempt) {
            $this->postJson('/api/v1/auth/parent-invitations/accept', $payload)
                ->assertUnprocessable()
                ->assertJsonPath('message', 'Invalid or expired invitation code.');
        }

        // 5th attempt should be throttled (429)
        $this->postJson('/api/v1/auth/parent-invitations/accept', $payload)
            ->assertTooManyRequests()
            ->assertJsonPath('message', 'Too many acceptance attempts.');
    }

    public function test_admin_can_list_pending_invitations(): void
    {
        [$admin, $token, $institution, $student] = $this->student();

        $this->withToken($token)->postJson('/api/v1/management/parent-invitations', [
            'student_email' => $student->email,
        ])->assertCreated();

        $response = $this->withToken($token)->getJson('/api/v1/management/parent-invitations');

        $response->assertOk()->assertJsonStructure([
            'data' => [
                '*' => ['id', 'student' => ['id', 'name', 'email'], 'issued_by', 'expires_at'],
            ],
        ]);

        $data = $response->json('data');
        $this->assertCount(1, $data);
        $this->assertEquals($student->email, $data[0]['student']['email']);
    }

    public function test_admin_can_revoke_invitation(): void
    {
        [$admin, $token, $institution, $student] = $this->student();

        $invitationResponse = $this->withToken($token)->postJson('/api/v1/management/parent-invitations', [
            'student_email' => $student->email,
        ])->assertCreated();

        $invitationId = $invitationResponse->json('data.invitation_id');

        $response = $this->withToken($token)->deleteJson("/api/v1/management/parent-invitations/{$invitationId}");

        $response->assertNoContent();

        $invitation = ParentInvitation::query()->find($invitationId);
        $this->assertNotNull($invitation->revoked_at);

        $this->assertDatabaseHas('audit_events', [
            'actor_id' => $admin->id,
            'event_type' => 'parent.invitation_revoked',
            'outcome' => 'success',
        ]);
    }

    public function test_revoking_already_accepted_invitation_fails(): void
    {
        [$admin, $token, $institution, $student] = $this->student();

        $invitation = ParentInvitation::query()->create([
            'institution_id' => $institution->id,
            'student_id' => $student->id,
            'issued_by' => $admin->id,
            'code_hash' => hash('sha256', 'ACCEPTED2'),
            'expires_at' => now()->addDays(3),
            'accepted_at' => now()->subHour(),
        ]);

        $response = $this->withToken($token)->deleteJson("/api/v1/management/parent-invitations/{$invitation->id}");

        $response->assertUnprocessable()
            ->assertJsonPath('message', 'Invitation already accepted.');
    }

    public function test_parent_can_list_their_children(): void
    {
        [$admin, $token, $institution, $student] = $this->student();

        $invitationResponse = $this->withToken($token)->postJson('/api/v1/management/parent-invitations', [
            'student_email' => $student->email,
        ])->assertCreated();

        $code = $invitationResponse->json('data.invitation_code');

        $this->postJson('/api/v1/auth/parent-invitations/accept', [
            'invitation_code' => $code,
            'parent_name' => 'Test Parent',
            'parent_email' => 'parent@test.com',
            'password' => 'Personal#123456',
            'password_confirmation' => 'Personal#123456',
        ])->assertCreated();

        $parentToken = $this->postJson('/api/v1/auth/sessions', [
            'email' => 'parent@test.com',
            'password' => 'Personal#123456',
        ])->assertCreated()->json('data.access_token');

        $response = $this->withToken($parentToken)->getJson('/api/v1/management/parent-links');

        $response->assertOk()->assertJsonStructure([
            'data' => [
                '*' => ['id', 'child' => ['id', 'name', 'email', 'username'], 'is_active'],
            ],
        ]);

        $data = $response->json('data');
        $this->assertCount(1, $data);
        $this->assertEquals($student->id, $data[0]['child']['id']);
    }

    public function test_student_can_list_their_parents(): void
    {
        [$admin, $token, $institution, $student] = $this->student();

        $invitationResponse = $this->withToken($token)->postJson('/api/v1/management/parent-invitations', [
            'student_email' => $student->email,
        ])->assertCreated();

        $code = $invitationResponse->json('data.invitation_code');

        $this->postJson('/api/v1/auth/parent-invitations/accept', [
            'invitation_code' => $code,
            'parent_name' => 'Test Parent',
            'parent_email' => 'parent@test.com',
            'password' => 'Personal#123456',
            'password_confirmation' => 'Personal#123456',
        ])->assertCreated();

        $studentToken = $this->postJson('/api/v1/auth/sessions', [
            'email' => $student->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $response = $this->withToken($studentToken)->getJson('/api/v1/management/parent-links');

        $response->assertOk()->assertJsonStructure([
            'data' => [
                '*' => ['id', 'parent' => ['id', 'name', 'email', 'username'], 'is_active'],
            ],
        ]);

        $data = $response->json('data');
        $this->assertCount(1, $data);
    }

    public function test_teacher_cannot_list_parent_links(): void
    {
        $institution = Institution::create(['name' => 'School']);
        $teacher = User::factory()->create(['active_institution_id' => $institution->id, 'is_active' => true]);
        InstitutionMembership::create([
            'institution_id' => $institution->id,
            'user_id' => $teacher->id,
            'role' => InstitutionRole::Teacher->value,
            'is_active' => true,
        ]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $teacher->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $response = $this->withToken($token)->getJson('/api/v1/management/parent-links');

        $response->assertForbidden();
    }
}
