<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AssessmentSubmission extends Model
{
    use HasFactory;

    protected $fillable = [
        'institution_id',
        'assessment_id',
        'student_id',
        'score',
        'max_score',
        'answers_json',
        'attempted_at',
        'submitted_at',
        'status',
    ];

    protected $casts = [
        'attempted_at' => 'datetime',
        'submitted_at' => 'datetime',
        'answers_json' => 'array',
    ];

    public function institution(): BelongsTo
    {
        return $this->belongsTo(Institution::class);
    }

    public function assessment(): BelongsTo
    {
        return $this->belongsTo(Assessment::class);
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(User::class, 'student_id');
    }
}
