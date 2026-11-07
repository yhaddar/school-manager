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
        Schema::create('academic_periods', function (Blueprint $table): void {
            $table->ulid('id')->primary();
            $table->foreignUlid('academic_year_id')->constrained()->cascadeOnDelete();
            $table->foreignUlid('institution_id')->constrained()->cascadeOnDelete();
            $table->string('name'); // e.g., "Semester 1", "Q1", "Trimester 1"
            $table->string('type'); // semester, trimester, quarter, custom
            $table->integer('sequence'); // 1, 2, 3...
            $table->date('starts_at');
            $table->date('ends_at');
            $table->boolean('is_grading_period')->default(true);
            $table->boolean('is_locked')->default(false);
            $table->timestamps();
            $table->softDeletes();

            $table->unique(['academic_year_id', 'name']);
            $table->unique(['academic_year_id', 'sequence']);
            $table->index(['institution_id', 'starts_at', 'ends_at']);
            $table->index(['academic_year_id', 'sequence']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('academic_periods');
    }
};
