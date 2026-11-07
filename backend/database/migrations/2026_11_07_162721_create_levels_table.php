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
        Schema::create('levels', function (Blueprint $table): void {
            $table->ulid('id')->primary();
            $table->foreignUlid('institution_id')->constrained()->cascadeOnDelete();
            $table->string('name'); // e.g., "Grade 1", "Year 1", "Kindergarten"
            $table->string('code')->nullable(); // e.g., "G1", "Y1", "KG"
            $table->integer('sequence'); // ordering within institution
            $table->string('education_type')->nullable(); // preschool, primary, secondary, higher, vocational
            $table->text('description')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->softDeletes();

            $table->unique(['institution_id', 'name']);
            $table->unique(['institution_id', 'code']);
            $table->index(['institution_id', 'sequence']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('levels');
    }
};
