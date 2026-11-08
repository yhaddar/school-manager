<?php

namespace Database\Seeders;

use App\Models\Export;
use App\Models\Import;
use App\Models\Institution;
use App\Models\Report;
use App\Models\User;
use Illuminate\Database\Seeder;

class ReportsExportsImportsSeeder extends Seeder
{
    public function run(): void
    {
        $institution = Institution::first();
        $admin = User::where('email', 'admin@testschool.com')->first() ?? User::first();

        if (!$institution || !$admin) {
            return;
        }

        // Create Reports
        $reportTypes = ['academic', 'attendance', 'financial', 'enrollment', 'custom'];
        $reportFormats = ['pdf', 'excel', 'csv'];
        $reportStatuses = ['pending', 'generating', 'completed', 'failed'];

        for ($i = 0; $i < 10; $i++) {
            Report::create([
                'institution_id' => $institution->id,
                'title' => 'Report ' . ($i + 1),
                'slug' => 'report-' . ($i + 1) . '-' . now()->timestamp,
                'description' => 'Sample report description ' . ($i + 1),
                'type' => $reportTypes[array_rand($reportTypes)],
                'parameters' => ['param1' => 'value1', 'param2' => 'value2'],
                'columns' => ['col1', 'col2', 'col3'],
                'format' => $reportFormats[array_rand($reportFormats)],
                'status' => $reportStatuses[array_rand($reportStatuses)],
                'file_path' => $i % 2 === 0 ? 'reports/' . ($i + 1) . '.pdf' : null,
                'file_name' => $i % 2 === 0 ? 'report_' . ($i + 1) . '.pdf' : null,
                'file_size' => $i % 2 === 0 ? rand(1000, 5000000) : 0,
                'generated_at' => $i % 2 === 0 ? now()->subDays(rand(1, 30)) : null,
                'expires_at' => $i % 2 === 0 ? now()->addDays(365) : null,
                'created_by' => $admin->id,
            ]);
        }

        // Create Exports
        $exportEntityTypes = ['students', 'teachers', 'grades', 'attendance', 'enrollments', 'courses', 'messages', 'notifications', 'events', 'calendar_events'];
        $exportFormats = ['excel', 'csv'];
        $exportStatuses = ['pending', 'processing', 'completed', 'failed'];

        for ($i = 0; $i < 10; $i++) {
            Export::create([
                'institution_id' => $institution->id,
                'title' => 'Export ' . ($i + 1),
                'entity_type' => $exportEntityTypes[array_rand($exportEntityTypes)],
                'filters' => ['status' => 'active'],
                'columns' => ['col1', 'col2', 'col3'],
                'format' => $exportFormats[array_rand($exportFormats)],
                'status' => $exportStatuses[array_rand($exportStatuses)],
                'file_path' => $i % 2 === 0 ? 'exports/' . ($i + 1) . '.' . ($exportFormats[array_rand($exportFormats)]) : null,
                'file_name' => $i % 2 === 0 ? 'export_' . ($i + 1) . '.' . ($exportFormats[array_rand($exportFormats)]) : null,
                'file_size' => $i % 2 === 0 ? rand(1000, 5000000) : 0,
                'record_count' => $i % 2 === 0 ? rand(1, 1000) : 0,
                'started_at' => $i % 2 === 0 ? now()->subHours(rand(1, 24)) : null,
                'completed_at' => $i % 2 === 0 ? now()->subHours(rand(1, 24)) : null,
                'expires_at' => $i % 2 === 0 ? now()->addDays(365) : null,
                'error_message' => $i % 3 === 0 ? 'Sample error message' : null,
                'requested_by' => $admin->id,
            ]);
        }

        // Create Imports
        $importEntityTypes = ['students', 'teachers', 'courses', 'enrollments', 'grades', 'attendance'];
        $importFormats = ['excel', 'csv'];
        $importStatuses = ['pending', 'validating', 'processing', 'completed', 'failed', 'partial'];

        for ($i = 0; $i < 10; $i++) {
            Import::create([
                'institution_id' => $institution->id,
                'title' => 'Import ' . ($i + 1),
                'entity_type' => $importEntityTypes[array_rand($importEntityTypes)],
                'format' => $importFormats[array_rand($importFormats)],
                'status' => $importStatuses[array_rand($importStatuses)],
                'file_path' => 'imports/' . ($i + 1) . '.' . ($importFormats[array_rand($importFormats)]),
                'original_file_name' => 'import_' . ($i + 1) . '.' . ($importFormats[array_rand($importFormats)]),
                'file_size' => rand(1000, 5000000),
                'total_rows' => rand(100, 10000),
                'processed_rows' => rand(0, 10000),
                'successful_rows' => rand(0, 9900),
                'failed_rows' => rand(0, 100),
                'validation_errors' => $i % 3 === 0 ? ['error1', 'error2'] : null,
                'import_errors' => $i % 3 === 0 ? ['import_error1', 'import_error2'] : null,
                'started_at' => now()->subHours(rand(1, 48)),
                'completed_at' => now()->subHours(rand(1, 48)),
                'requested_by' => $admin->id,
            ]);
        }
    }
}
