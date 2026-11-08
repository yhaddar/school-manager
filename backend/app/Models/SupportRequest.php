<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class SupportRequest extends Model
{
    use HasFactory;

    protected $fillable = [
        'institution_id',
        'requester_id',
        'approver_id',
        'subject',
        'description',
        'priority',
        'status',
        'category',
        'requested_access',
        'notes',
        'approved_at',
        'denied_at',
        'resolved_by',
        'resolved_at',
    ];

    protected $casts = [
        'requested_access' => 'array',
        'approved_at' => 'datetime',
        'denied_at' => 'datetime',
        'resolved_at' => 'datetime',
    ];

    public function institution()
    {
        return $this->belongsTo(Institution::class);
    }

    public function requester()
    {
        return $this->belongsTo(User::class, 'requester_id');
    }

    public function approver()
    {
        return $this->belongsTo(User::class, 'approver_id');
    }

    public function resolvedBy()
    {
        return $this->belongsTo(User::class, 'resolved_by');
    }

    public function sessions()
    {
        return $this->hasMany(SupportSession::class);
    }
}
