<?php

namespace App\Policies;

use App\Models\Notification;
use App\Models\User;
use Illuminate\Auth\Access\HandlesAuthorization;

class NotificationPolicy
{
    use HandlesAuthorization;

    public function viewAny(User $user): bool
    {
        return $user->active_institution_id !== null;
    }

    public function view(User $user, Notification $notification): bool
    {
        return $notification->institution_id === $user->active_institution_id;
    }

    public function create(User $user): bool
    {
        return $user->active_institution_id !== null;
    }

    public function update(User $user, Notification $notification): bool
    {
        return $notification->institution_id === $user->active_institution_id;
    }

    public function delete(User $user, Notification $notification): bool
    {
        return $notification->institution_id === $user->active_institution_id;
    }

    public function updateAny(User $user): bool
    {
        return $user->active_institution_id !== null;
    }
}
