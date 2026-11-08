<?php

namespace Tests\Feature;

use App\Models\Export;
use App\Models\Institution;
use App\Models\InstitutionMembership;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ExportControllerTest extends TestCase
{
    use RefreshDatabase;

    protected Institution $institution;
    protected User $admin;
    protected User $teacher;

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
    }

    public function test_admin_can_create_export(): void
    {
        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $this->admin->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $this->withToken($token)
            ->postJson('/api/v1/management/exports', [
                'title' => 'Student List Export',
                'entity_type' => 'students',
                'format' => 'csv',
            ])
            ->assertCreated()
            ->assertJsonStructure(['data' => [
                'id', 'title', 'entity_type', 'status', 'institution_id', 'requested_by'
            ]]);
    }

    public function test_admin_can_list_exports(): void
    {
        Export::factory()->count(3)->create(['institution_id' => $this->institution->id]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $this->admin->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $response = $this->withToken($token)
            ->getJson('/api/v1/management/exports');

        $response->assertOk();
        $data = $response->json('data.data');
        $this->assertIsArray($data);
        $this->assertCount(3, $data);
    }

    public function test_export_filters_by_entity_type_and_status(): void
    {
        Export::factory()->create([
            'institution_id' => $this->institution->id,
            'entity_type' => 'students',
            'status' => 'pending',
        ]);
        Export::factory()->create([
            'institution_id' => $this->institution->id,
            'entity_type' => 'teachers',
            'status' => 'completed',
        ]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $this->admin->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $response = $this->withToken($token)
            ->getJson('/api/v1/management/exports?entity_type=students&status=pending');

        $response->assertOk();
        $data = $response->json('data.data');
        $this->assertCount(1, $data);
        $this->assertEquals('students', $data[0]['entity_type']);
    }

    public function test_export_download_rejects_not_completed(): void
    {
        $export = Export::factory()->create([
            'institution_id' => $this->institution->id,
            'requested_by' => $this->admin->id,
            'status' => 'pending',
        ]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $this->admin->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $this->withToken($token)
            ->getJson('/api/v1/management/exports/' . $export->id . '/download')
            ->assertStatus(400);
    }

    public function test_export_download_returns_url_when_completed(): void
    {
        $export = Export::factory()->create([
            'institution_id' => $this->institution->id,
            'requested_by' => $this->admin->id,
            'status' => 'completed',
            'file_name' => 'students.csv',
            'file_size' => 1024,
        ]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $this->admin->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $this->withToken($token)
            ->getJson('/api/v1/management/exports/' . $export->id . '/download')
            ->assertOk()
            ->assertJsonStructure(['data' => ['download_url', 'file_name', 'file_size']]);
    }
}
