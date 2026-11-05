<?php

namespace App\Policies;

use App\Models\Institution;
use App\Models\User;

class InstitutionPolicy
{
    public function view(User $user, Institution $institution): bool
    {
        return $institution->status === 'active'
            && $user->active_institution_id === $institution->id
            && $user->institutionMemberships()
                ->where('institution_id', $institution->id)
                ->where('is_active', true)
                ->exists();
    }
}
