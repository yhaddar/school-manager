<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('imports', function (Blueprint $table) {
            $table->id();
            $table->foreignUlid('institution_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->enum('entity_type', ['students', 'teachers', 'courses', 'enrollments', 'grades', 'attendance']);
            $table->enum('format', ['excel', 'csv'])->default('excel');
            $table->enum('status', ['pending', 'validating', 'processing', 'completed', 'failed', 'partial'])->default('pending');
            $table->string('file_path')->nullable();
            $table->string('original_file_name')->nullable();
            $table->bigInteger('file_size')->nullable();
            $table->integer('total_rows')->default(0);
            $table->integer('processed_rows')->default(0);
            $table->integer('successful_rows')->default(0);
            $table->integer('failed_rows')->default(0);
            $table->json('validation_errors')->nullable();
            $table->json('import_errors')->nullable();
            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->foreignId('requested_by')->constrained('users')->cascadeOnDelete();
            $table->timestamps();
            
            $table->index(['institution_id', 'entity_type']);
            $table->index(['institution_id', 'status']);
            $table->index(['requested_by', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('imports');
    }
};
