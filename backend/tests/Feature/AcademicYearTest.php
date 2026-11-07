<?php

namespace Tests\Feature;

use App\Enums\InstitutionRole;
use App\Models\AcademicYear;
use App\Models\Institution;
use App\Models\InstitutionMembership;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AcademicYearTest extends TestCase
{
    use RefreshDatabase;

    private function adminToken(): array
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

    private function teacherToken(): array
    {
        $institution = Institution::create(['name' => 'School']);
        $user = User::factory()->create([
            'active_institution_id' => $institution->id,
            'is_active' => true,
        ]);
        InstitutionMembership::create([
            'institution_id' => $institution->id,
            'user_id' => $user->id,
            'role' => InstitutionRole::Teacher->value,
            'is_active' => true,
        ]);
        $token = $this->postJson('/api/v1/auth/sessions', [
            'email' => $user->email,
            'password' => 'password',
        ])->assertCreated()->json('data.access_token');

        return [$user, $token, $institution];
    }

    public function test_administrator_can_list_academic_years(): void
    {
        [$user, $token, $institution] = $this->adminToken();

        AcademicYear::create([
            'institution_id' => $institution->id,
            'name' => '2024-2025',
            'starts_at' => '2024-09-01',
            'ends_at' => '2025-06-30',
            'is_current' => true,
        ]);

        $response = $this->withToken($token)->getJson('/api/v1/management/academic-years');

        $response->assertOk()
            ->assertJsonStructure([
                'data' => [
                    '*' => ['id', 'name', 'starts_at', 'ends_at', 'is_current', 'is_locked'],
                ],
            ]);
    }

    public function test_administrator_can_create_academic_year(): void
    {
        [$user, $token, $institution] = $this->adminToken();

        $response = $this->withToken($token)->postJson('/api/v1/management/academic-years', [
            'name' => '2025-2026',
            'starts_at' => '2025-09-01',
            'ends_at' => '2026-06-30',
            'is_current' => false,
        ]);

        $response->assertCreated()
            ->assertJsonStructure([
                'data' => ['id', 'name', 'starts_at', 'ends_at', 'is_current', 'is_locked'],
            ]);

        $this->assertDatabaseHas('academic_years', [
            'institution_id' => $institution->id,
            'name' => '2025-2026',
        ]);
    }

    public function test_administrator_can_show_academic_year(): void
    {
        [$user, $token, $institution] = $this->adminToken();

        $year = AcademicYear::create([
            'institution_id' => $institution->id,
            'name' => '2024-2025',
            'starts_at' => '2024-09-01',
            'ends_at' => '2025-06-30',
            'is_current' => true,
        ]);

        $response = $this->withToken($token)->getJson("/api/v1/management/academic-years/{$year->id}");

        $response->assertOk()
            ->assertJsonPath('data.id', $year->id)
            ->assertJsonPath('data.name', '2024-2025');
    }

    public function test_teacher_cannot_create_academic_year(): void
    {
        [$user, $token, $institution] = $this->teacherToken();

        $response = $this->withToken($token)->postJson('/api/v1/management/academic-years', [
            'name' => '2025-2026',
            'starts_at' => '2025-09-01',
            'ends_at' => '2026-06-30',
        ]);

        $response->assertForbidden();
    }
}
