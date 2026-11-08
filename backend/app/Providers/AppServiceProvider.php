<?php

namespace App\Providers;

use App\Enums\InstitutionPermission;
use App\Enums\InstitutionRole;
use App\Enums\UserAccountType;
use App\Models\CalendarEvent;
use App\Models\Event;
use App\Models\Institution;
use App\Models\Message;
use App\Models\Notification;
use App\Policies\CalendarEventPolicy;
use App\Policies\EventPolicy;
use App\Policies\InstitutionPolicy;
use App\Policies\MessagePolicy;
use App\Policies\NotificationPolicy;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Gate::policy(Institution::class, InstitutionPolicy::class);
        Gate::policy(Notification::class, NotificationPolicy::class);
        Gate::policy(Message::class, MessagePolicy::class);
        Gate::policy(CalendarEvent::class, CalendarEventPolicy::class);
        Gate::policy(Event::class, EventPolicy::class);

        Gate::define('institution-permission', function ($user, string $permission): bool {
            $permissionEnum = InstitutionPermission::tryFrom($permission);

            if ($permissionEnum === null) {
                return false;
            }

            $membership = $user->institutionMemberships()
                ->where('institution_id', $user->active_institution_id)
                ->where('is_active', true)
                ->first();

            return $membership !== null
                && $membership->institution?->status === 'active'
                && $membership->allows($permissionEnum);
        });

        Gate::define('account-type', function ($user, string $type): bool {
            $typeEnum = UserAccountType::tryFrom($type);

            if ($typeEnum === null) {
                return false;
            }

            return $user->user_type === $typeEnum->value;
        });

        Gate::define('account-type-in', function ($user, array $types): bool {
            foreach ($types as $type) {
                $typeEnum = UserAccountType::tryFrom($type);

                if ($typeEnum !== null && $user->user_type === $typeEnum->value) {
                    return true;
                }
            }

            return false;
        });

        Gate::define('membership-role', function ($user, string $role): bool {
            $roleEnum = InstitutionRole::tryFrom($role);

            if ($roleEnum === null) {
                return false;
            }

            $membership = $user->institutionMemberships()
                ->where('institution_id', $user->active_institution_id)
                ->where('is_active', true)
                ->first();

            return $membership !== null && $membership->role === $roleEnum->value;
        });

        Gate::define('membership-role-in', function ($user, array $roles): bool {
            $membership = $user->institutionMemberships()
                ->where('institution_id', $user->active_institution_id)
                ->where('is_active', true)
                ->first();

            if ($membership === null) {
                return false;
            }

            foreach ($roles as $role) {
                $roleEnum = InstitutionRole::tryFrom($role);

                if ($roleEnum !== null && $membership->role === $roleEnum->value) {
                    return true;
                }
            }

            return false;
        });
    }
}
