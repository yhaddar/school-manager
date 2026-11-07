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
        Schema::create('classes', function (Blueprint $table): void {
            $table->id();
            $table->foreignUlid('institution_id')->constrained()->cascadeOnDelete();
            $table->foreignUlid('academic_year_id')->constrained()->cascadeOnDelete();
            $table->foreignUlid('level_id')->constrained()->cascadeOnDelete();
            $table->foreignUlid('track_id')->nullable()->constrained()->nullOnDelete();
            $table->string('name'); // e.g., "1A", "2B", "Grade 10 - Science"
            $table->string('code')->nullable(); // short code
            $table->integer('capacity')->default(30);
            $table->foreignId('homeroom_teacher_id')->nullable()->constrained('users')->nullOnDelete();
            $table->ulid('room_id')->nullable(); // References rooms.id (ULID) - FK added after rooms migration
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->softDeletes();

            $table->unique(['institution_id', 'academic_year_id', 'name']);
            $table->unique(['institution_id', 'academic_year_id', 'code']);
            $table->index(['institution_id', 'academic_year_id', 'level_id']);
            $table->index(['institution_id', 'academic_year_id', 'homeroom_teacher_id']);
            $table->index('room_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('classes');
    }
};
