<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('assignments', function (Blueprint $table) {
            $table->id();
            $table->foreignUlid('institution_id')->constrained()->cascadeOnDelete();
            $table->foreignId('course_id')->nullable()->constrained('courses')->nullOnDelete();
            $table->foreignId('class_id')->nullable()->constrained('classes')->nullOnDelete();
            $table->string('title');
            $table->text('description')->nullable();
            $table->string('type')->default('homework'); // homework, project, quiz
            $table->dateTime('published_at')->nullable();
            $table->dateTime('due_at')->nullable();
            $table->dateTime('submitted_at')->nullable();
            $table->integer('max_score')->default(100);
            $table->enum('status', ['draft', 'published', 'closed'])->default('draft');
            $table->string('attachment_path')->nullable();
            $table->timestamps();

            // Composite indexes for tenant-scoped queries
            $table->index(['institution_id', 'status']);
            $table->index(['institution_id', 'course_id']);
            $table->index(['institution_id', 'class_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('assignments');
    }
};
