<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use App\Enums\UserAccountType;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

#[Fillable(['name', 'email', 'username', 'password', 'user_type', 'is_active', 'activation_expires_at', 'activated_at', 'active_institution_id'])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasFactory, Notifiable;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'is_active' => 'boolean',
            'user_type' => UserAccountType::class,
            'activation_expires_at' => 'datetime',
            'activated_at' => 'datetime',
        ];
    }

    public function activeInstitution(): BelongsTo
    {
        return $this->belongsTo(Institution::class, 'active_institution_id');
    }

    public function institutionMemberships(): HasMany
    {
        return $this->hasMany(InstitutionMembership::class);
    }

    public function apiSessions(): HasMany
    {
        return $this->hasMany(ApiSession::class);
    }

    public function parentChildren(): HasMany
    {
        return $this->hasMany(ParentChild::class, 'parent_user_id');
    }

    public function childLinks(): HasMany
    {
        return $this->hasMany(ParentChild::class, 'child_user_id');
    }

    public function issuedParentInvitations(): HasMany
    {
        return $this->hasMany(ParentInvitation::class, 'issued_by');
    }
}
