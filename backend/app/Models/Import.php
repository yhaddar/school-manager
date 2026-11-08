<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Import extends Model
{
    use HasFactory;

    protected $fillable = [
        'institution_id',
        'title',
        'entity_type',
        'format',
        'status',
        'file_path',
        'original_file_name',
        'file_size',
        'total_rows',
        'processed_rows',
        'successful_rows',
        'failed_rows',
        'validation_errors',
        'import_errors',
        'started_at',
        'completed_at',
        'requested_by',
    ];

    protected $casts = [
        'validation_errors' => 'array',
        'import_errors' => 'array',
        'started_at' => 'datetime',
        'completed_at' => 'datetime',
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
