<?php

namespace App\Policies;

use App\Models\Message;
use App\Models\User;
use Illuminate\Auth\Access\HandlesAuthorization;

class MessagePolicy
{
    use HandlesAuthorization;

    public function viewAny(User $user): bool
    {
        return $user->active_institution_id !== null;
    }

    public function view(User $user, Message $message): bool
    {
        return $message->institution_id === $user->active_institution_id;
    }

    public function create(User $user): bool
    {
        return $user->active_institution_id !== null;
    }

    public function update(User $user, Message $message): bool
    {
        return $message->institution_id === $user->active_institution_id;
    }

    public function delete(User $user, Message $message): bool
    {
        return $message->institution_id === $user->active_institution_id;
    }
}
