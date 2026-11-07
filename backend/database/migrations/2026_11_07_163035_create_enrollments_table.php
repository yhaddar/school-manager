<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('enrollments', function (Blueprint $table): void {
            $table->id();
            $table->foreignUlid('institution_id')->constrained()->cascadeOnDelete();
            $table->foreignUlid('academic_year_id')->constrained()->cascadeOnDelete();
            $table->foreignId('student_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('class_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignUlid('track_id')->nullable()->constrained()->nullOnDelete();
            $table->string('status')->default('active'); // active, completed, withdrawn, transferred, graduated
            $table->date('enrolled_at');
            $table->date('completed_at')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();
            $table->softDeletes();

            // A student can only be enrolled in one class per academic year
            $table->unique(['academic_year_id', 'student_id']);
            $table->index(['institution_id', 'academic_year_id', 'class_id']);
            $table->index(['institution_id', 'academic_year_id', 'student_id']);
            $table->index(['institution_id', 'academic_year_id', 'status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('enrollments');
    }
};
