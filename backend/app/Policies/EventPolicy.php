<?php

namespace App\Policies;

use App\Models\Event;
use App\Models\User;
use Illuminate\Auth\Access\HandlesAuthorization;

class EventPolicy
{
    use HandlesAuthorization;

    public function viewAny(User $user): bool
    {
        return $user->active_institution_id !== null;
    }

    public function view(User $user, Event $event): bool
    {
        return $event->institution_id === $user->active_institution_id;
    }

    public function create(User $user): bool
    {
        return $user->active_institution_id !== null;
    }

    public function update(User $user, Event $event): bool
    {
        return $event->institution_id === $user->active_institution_id;
    }

    public function delete(User $user, Event $event): bool
    {
        return $event->institution_id === $user->active_institution_id;
    }
}
