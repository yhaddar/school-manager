<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class SupportSession extends Model
{
    use HasFactory;

    protected $fillable = [
        'support_request_id',
        'accessor_id',
        'session_token',
        'expires_at',
        'started_at',
        'ended_at',
        'status',
        'actions_logged',
    ];

    protected $casts = [
        'expires_at' => 'datetime',
        'started_at' => 'datetime',
        'ended_at' => 'datetime',
        'actions_logged' => 'array',
    ];

    public function supportRequest()
    {
        return $this->belongsTo(SupportRequest::class);
    }

    public function accessor()
    {
        return $this->belongsTo(User::class, 'accessor_id');
    }
}
