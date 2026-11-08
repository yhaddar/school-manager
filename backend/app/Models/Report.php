<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Report extends Model
{
    use HasFactory;

    protected $fillable = [
        'institution_id',
        'title',
        'slug',
        'description',
        'type',
        'parameters',
        'columns',
        'format',
        'status',
        'file_path',
        'file_name',
        'file_size',
        'generated_at',
        'expires_at',
        'created_by',
    ];

    protected $casts = [
        'parameters' => 'array',
        'columns' => 'array',
        'generated_at' => 'datetime',
        'expires_at' => 'datetime',
    ];

    public function institution(): BelongsTo
    {
        return $this->belongsTo(Institution::class);
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}
