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
        Schema::create('tracks', function (Blueprint $table): void {
            $table->ulid('id')->primary();
            $table->foreignUlid('institution_id')->constrained()->cascadeOnDelete();
            $table->foreignUlid('level_id')->nullable()->constrained()->nullOnDelete();
            $table->string('name'); // e.g., "Science", "Arts", "General", "Vocational - Nursing"
            $table->string('code')->nullable(); // e.g., "SCI", "ART", "GEN", "VOC-NUR"
            $table->text('description')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->softDeletes();

            $table->unique(['institution_id', 'level_id', 'name']);
            $table->unique(['institution_id', 'level_id', 'code']);
            $table->index(['institution_id', 'level_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('tracks');
    }
};
