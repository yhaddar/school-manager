<?php

namespace Tests\Feature;

use App\Models\Institution;
use App\Models\InstitutionMembership;
use App\Models\Report;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ReportControllerTest extends TestCase
{
    use RefreshDatabase;

    protected Institution $institution;
    protected User $admin;
    protected User $teacher;
    protected User $student;

    protected function setUp(): void
    {
        parent::setUp();

        $this->institution = Institution::create(['name' => 'Test School']);
        
        $this->admin = User::factory()->create([
            'active_institution_id' => $this->institution->id,
        ]);
        InstitutionMembership::create([
            'institution_id' => $this->institution->id,
            'user_id' => $this->admin->id,
            'role' => 'administrator',
        ]);

        $this->teacher = User::factory()->create([
            'active_institution_id' => $this->institution->id,
        ]);
        InstitutionMembership::create([
            'institution_id' => $this->institution->id,
            'user_id' => $this->teacher->id,
            'role' => 'teacher',
        ]);

        $this->student = User::factory()->create([
            'active_institution_id' => $this->institution->id,
        ]);
        InstitutionMembership::create([
            'institution_id' => $this->institution->id,
            'user_id' => $this->student->id,
            'role' => 'student',
        ]);
    }

    public function test_admin_can_create_report(): void
    {
        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $this->admin->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $this->withToken($token)
            ->postJson('/api/v1/management/reports', [
                'title' => 'Monthly Attendance Report',
                'type' => 'attendance',
                'format' => 'pdf',
            ])
            ->assertCreated()
            ->assertJsonStructure(['data' => [
                'id', 'title', 'type', 'status', 'institution_id', 'created_by'
            ]]);
    }

    public function test_admin_can_list_reports(): void
    {
        Report::factory()->count(3)->create(['institution_id' => $this->institution->id]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $this->admin->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $response = $this->withToken($token)
            ->getJson('/api/v1/management/reports');

        $response->assertOk();
        $data = $response->json('data.data');
        $this->assertIsArray($data);
        $this->assertCount(3, $data);
    }

    public function test_teacher_can_list_own_reports(): void
    {
        Report::factory()->create([
            'institution_id' => $this->institution->id,
            'created_by' => $this->admin->id,
        ]);
        Report::factory()->create([
            'institution_id' => $this->institution->id,
            'created_by' => $this->teacher->id,
        ]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $this->teacher->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $response = $this->withToken($token)
            ->getJson('/api/v1/management/reports');

        $response->assertOk();
        // Teacher should see their own report plus admin reports due to view permission
        $this->assertGreaterThanOrEqual(1, count($response->json('data.data')));
    }

    public function test_report_is_tenant_scoped(): void
    {
        $otherInstitution = Institution::create(['name' => 'Other School']);
        Report::factory()->create(['institution_id' => $otherInstitution->id]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $this->admin->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $response = $this->withToken($token)
            ->getJson('/api/v1/management/reports');

        $response->assertOk();
        $data = $response->json('data.data');
        $this->assertIsArray($data);
        $this->assertCount(0, $data);

        $this->withToken($token)
            ->getJson('/api/v1/management/reports/999')
            ->assertNotFound();
    }

    public function test_report_show_returns_report(): void
    {
        $report = Report::factory()->create([
            'institution_id' => $this->institution->id,
            'created_by' => $this->admin->id,
        ]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $this->admin->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $this->withToken($token)
            ->getJson('/api/v1/management/reports/' . $report->id)
            ->assertOk()
            ->assertJsonPath('data.title', $report->title);
    }

    public function test_report_can_be_generated(): void
    {
        $report = Report::factory()->create([
            'institution_id' => $this->institution->id,
            'created_by' => $this->admin->id,
            'status' => 'pending',
        ]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $this->admin->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $this->withToken($token)
            ->postJson('/api/v1/management/reports/' . $report->id . '/generate')
            ->assertOk()
            ->assertJsonPath('data.status', 'completed');
    }

    public function test_report_can_be_updated(): void
    {
        $report = Report::factory()->create([
            'institution_id' => $this->institution->id,
            'created_by' => $this->admin->id,
        ]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $this->admin->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $this->withToken($token)
            ->putJson('/api/v1/management/reports/' . $report->id, [
                'title' => 'Updated Report Title',
            ])
            ->assertOk()
            ->assertJsonPath('data.title', 'Updated Report Title');
    }

    public function test_report_can_be_deleted(): void
    {
        $report = Report::factory()->create([
            'institution_id' => $this->institution->id,
            'created_by' => $this->admin->id,
        ]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $this->admin->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $this->withToken($token)
            ->deleteJson('/api/v1/management/reports/' . $report->id)
            ->assertNoContent();

        $this->assertDatabaseMissing('reports', ['id' => $report->id]);
    }

    public function test_report_filters_by_type_and_status(): void
    {
        Report::factory()->create([
            'institution_id' => $this->institution->id,
            'type' => 'attendance',
            'status' => 'pending',
        ]);
        Report::factory()->create([
            'institution_id' => $this->institution->id,
            'type' => 'academic',
            'status' => 'completed',
        ]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $this->admin->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $response = $this->withToken($token)
            ->getJson('/api/v1/management/reports?type=attendance&status=pending');

        $response->assertOk();
        $data = $response->json('data.data');
        $this->assertCount(1, $data);
        $this->assertEquals('attendance', $data[0]['type']);
    }
}
