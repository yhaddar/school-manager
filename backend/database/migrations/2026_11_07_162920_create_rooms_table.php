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
        Schema::create('rooms', function (Blueprint $table): void {
            $table->ulid('id')->primary();
            $table->foreignUlid('institution_id')->constrained()->cascadeOnDelete();
            $table->string('name'); // e.g., "Room 101", "Lab A", "Gym"
            $table->string('code')->nullable(); // short code
            $table->string('type')->default('classroom'); // classroom, lab, gym, auditorium, office, other
            $table->integer('capacity')->default(30);
            $table->json('equipment')->nullable(); // list of equipment
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->softDeletes();

            $table->unique(['institution_id', 'name']);
            $table->unique(['institution_id', 'code']);
            $table->index(['institution_id', 'type']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('rooms');
    }
};
