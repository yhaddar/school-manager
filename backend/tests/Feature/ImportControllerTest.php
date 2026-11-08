<?php

namespace Tests\Feature;

use App\Models\Import;
use App\Models\Institution;
use App\Models\InstitutionMembership;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ImportControllerTest extends TestCase
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

    public function test_admin_can_create_import(): void
    {
        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $this->admin->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $this->withToken($token)
            ->postJson('/api/v1/management/imports', [
                'title' => 'Student List Import',
                'entity_type' => 'students',
                'format' => 'csv',
            ])
            ->assertCreated()
            ->assertJsonStructure(['data' => [
                'id', 'title', 'entity_type', 'status', 'institution_id', 'requested_by'
            ]]);
    }

    public function test_admin_can_list_imports(): void
    {
        Import::factory()->count(3)->create(['institution_id' => $this->institution->id]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $this->admin->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $response = $this->withToken($token)
            ->getJson('/api/v1/management/imports');

        $response->assertOk();
        $data = $response->json('data.data');
        $this->assertIsArray($data);
        $this->assertCount(3, $data);
    }

    public function test_import_filters_by_entity_type_and_status(): void
    {
        Import::factory()->create([
            'institution_id' => $this->institution->id,
            'entity_type' => 'students',
            'status' => 'pending',
        ]);
        Import::factory()->create([
            'institution_id' => $this->institution->id,
            'entity_type' => 'teachers',
            'status' => 'completed',
        ]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $this->admin->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $response = $this->withToken($token)
            ->getJson('/api/v1/management/imports?entity_type=students&status=pending');

        $response->assertOk();
        $data = $response->json('data.data');
        $this->assertCount(1, $data);
        $this->assertEquals('students', $data[0]['entity_type']);
    }

    public function test_import_can_be_validated(): void
    {
        $import = Import::factory()->create([
            'institution_id' => $this->institution->id,
            'requested_by' => $this->admin->id,
            'status' => 'pending',
        ]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $this->admin->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $this->withToken($token)
            ->postJson('/api/v1/management/imports/' . $import->id . '/validate')
            ->assertOk()
            ->assertJsonPath('data.status', 'validating');
    }

    public function test_import_can_be_processed(): void
    {
        $import = Import::factory()->create([
            'institution_id' => $this->institution->id,
            'requested_by' => $this->admin->id,
            'status' => 'validating',
        ]);

        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $this->admin->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        $this->withToken($token)
            ->postJson('/api/v1/management/imports/' . $import->id . '/process')
            ->assertOk()
            ->assertJsonPath('data.status', 'completed')
            ->assertJsonPath('data.total_rows', 100)
            ->assertJsonPath('data.successful_rows', 100);
    }
}
