<?php

namespace App\Policies;

use App\Models\CalendarEvent;
use App\Models\User;
use Illuminate\Auth\Access\HandlesAuthorization;

class CalendarEventPolicy
{
    use HandlesAuthorization;

    public function viewAny(User $user): bool
    {
        return $user->active_institution_id !== null;
    }

    public function view(User $user, CalendarEvent $event): bool
    {
        return $event->institution_id === $user->active_institution_id;
    }

    public function create(User $user): bool
    {
        return $user->active_institution_id !== null;
    }

    public function update(User $user, CalendarEvent $event): bool
    {
        return $event->institution_id === $user->active_institution_id;
    }

    public function delete(User $user, CalendarEvent $event): bool
    {
        return $event->institution_id === $user->active_institution_id;
    }
}
