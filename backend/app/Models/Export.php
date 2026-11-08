<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Export extends Model
{
    use HasFactory;

    protected $fillable = [
        'institution_id',
        'title',
        'entity_type',
        'filters',
        'columns',
        'format',
        'status',
        'file_path',
        'file_name',
        'file_size',
        'record_count',
        'started_at',
        'completed_at',
        'expires_at',
        'error_message',
        'requested_by',
    ];

    protected $casts = [
        'filters' => 'array',
        'columns' => 'array',
        'started_at' => 'datetime',
        'completed_at' => 'datetime',
        'expires_at' => 'datetime',
    ];

    public function institution(): BelongsTo
    {
        return $this->belongsTo(Institution::class);
    }

    public function requester(): BelongsTo
    {
        return $this->belongsTo(User::class, 'requested_by');
    }
}
