<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Event extends Model
{
    /** @use HasFactory<\Database\Factories\EventFactory> */
    use HasFactory;

    protected $fillable = [
        'institution_id',
        'title',
        'description',
        'type',
        'start_date',
        'end_date',
        'start_time',
        'end_time',
        'all_day',
        'data',
        'status',
    ];

    protected $casts = [
        'data' => 'array',
        'all_day' => 'boolean',
        'start_date' => 'date',
        'end_date' => 'date',
    ];
}
