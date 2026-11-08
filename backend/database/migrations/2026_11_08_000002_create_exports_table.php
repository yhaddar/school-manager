<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('exports', function (Blueprint $table) {
            $table->id();
            $table->foreignUlid('institution_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->enum('entity_type', ['students', 'teachers', 'grades', 'attendance', 'enrollments', 'courses', 'messages', 'notifications', 'events', 'calendar_events']);
            $table->json('filters')->nullable();
            $table->json('columns')->nullable();
            $table->enum('format', ['excel', 'csv'])->default('excel');
            $table->enum('status', ['pending', 'processing', 'completed', 'failed'])->default('pending');
            $table->string('file_path')->nullable();
            $table->string('file_name')->nullable();
            $table->bigInteger('file_size')->nullable();
            $table->integer('record_count')->default(0);
            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamp('expires_at')->nullable();
            $table->text('error_message')->nullable();
            $table->foreignId('requested_by')->constrained('users')->cascadeOnDelete();
            $table->timestamps();
            
            $table->index(['institution_id', 'entity_type']);
            $table->index(['institution_id', 'status']);
            $table->index(['requested_by', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('exports');
    }
};
