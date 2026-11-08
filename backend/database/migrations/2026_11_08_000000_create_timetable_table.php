<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('timetables', function (Blueprint $table) {
            $table->id();
            $table->foreignUlid('institution_id')->constrained()->cascadeOnDelete();
            $table->foreignId('class_id')->constrained()->cascadeOnDelete();
            $table->foreignUlid('room_id')->nullable()->constrained('rooms')->nullOnDelete();
            $table->foreignId('course_id')->constrained()->cascadeOnDelete();
            $table->foreignId('teacher_id')->nullable()->constrained('users')->nullOnDelete();
            $table->time('start_time');
            $table->time('end_time');
            $table->integer('sequence');
            $table->string('day_of_week'); // monday, tuesday, etc.
            $table->timestamps();

            $table->unique([
                'institution_id',
                'class_id',
                'room_id',
                'start_time',
                'end_time',
                'day_of_week'
            ], 'timetable_unique_slot');

            $table->index(['institution_id', 'day_of_week', 'start_time']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('timetables');
    }
};
