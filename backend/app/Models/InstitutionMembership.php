<?php

namespace App\Models;

use App\Enums\InstitutionPermission;
use App\Enums\InstitutionRole;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable(['institution_id', 'user_id', 'role', 'is_active'])]
class InstitutionMembership extends Model
{
    public function allows(InstitutionPermission $permission): bool
    {
        return $this->is_active && in_array($this->role, $permission->roles(), true);
    }

    public function hasRole(InstitutionRole $role): bool
    {
        return $this->is_active && $this->role === $role->value;
    }

    public function hasAnyRole(array $roles): bool
    {
        if (! $this->is_active) {
            return false;
        }

        foreach ($roles as $role) {
            $roleEnum = $role instanceof InstitutionRole ? $role : InstitutionRole::tryFrom($role);

            if ($roleEnum !== null && $this->role === $roleEnum->value) {
                return true;
            }
        }

        return false;
    }

    protected function casts(): array
    {
        return ['is_active' => 'boolean'];
    }

    public function institution(): BelongsTo
    {
        return $this->belongsTo(Institution::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
