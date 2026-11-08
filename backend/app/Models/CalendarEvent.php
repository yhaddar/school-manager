<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CalendarEvent extends Model
{
    /** @use HasFactory<\Database\Factories\CalendarEventFactory> */
    use HasFactory;

    protected $fillable = [
        'institution_id',
        'title',
        'description',
        'type',
        'starts_at',
        'ends_at',
        'all_day',
        'data',
    ];

    protected $casts = [
        'data' => 'array',
        'all_day' => 'boolean',
        'starts_at' => 'datetime',
        'ends_at' => 'datetime',
    ];
}
