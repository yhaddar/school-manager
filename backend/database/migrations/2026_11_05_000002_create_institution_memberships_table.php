<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('institution_memberships', function (Blueprint $table): void {
            $table->id();
            $table->foreignUlid('institution_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('role');
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->unique(['institution_id', 'user_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('institution_memberships');
    }
};
