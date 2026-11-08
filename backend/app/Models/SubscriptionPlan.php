<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class SubscriptionPlan extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'tier',
        'features',
        'storage_limit_gb',
        'user_limit',
        'api_rate_limit',
        'price_monthly',
        'price_yearly',
        'is_active',
        'created_by',
    ];

    protected $casts = [
        'features' => 'array',
        'is_active' => 'boolean',
        'storage_limit_gb' => 'integer',
        'user_limit' => 'integer',
        'api_rate_limit' => 'integer',
        'price_monthly' => 'decimal:2',
        'price_yearly' => 'decimal:2',
    ];

    public function institutionSubscriptions()
    {
        return $this->hasMany(InstitutionSubscription::class, "plan_id");
    }

    public function createdBy()
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}
