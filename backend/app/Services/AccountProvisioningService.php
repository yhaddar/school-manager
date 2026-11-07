<?php

namespace App\Services;

use App\Enums\InstitutionPermission;
use App\Enums\UserAccountType;
use App\Models\AuditEvent;
use App\Models\Institution;
use App\Models\InstitutionMembership;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class AccountProvisioningService
{
    /**
     * Provision a staff or student account inside an institution.
     *
     * @param  array<string, mixed>  $attributes
     * @return array{user: User, temporary_password: string, username: string}
     */
    public function provision(Institution $institution, InstitutionMembership $membership, array $attributes, Request $request): array
    {
        $type = UserAccountType::tryFrom((string) ($attributes['user_type'] ?? 'staff'));

        abort_unless($type !== null && in_array($type->value, UserAccountType::provisionableTypes(), true), 422, 'Unsupported account type.');
        abort_unless($membership->allows(InstitutionPermission::ProvisionAccounts), 403, 'This role cannot provision accounts.');
        abort_unless($institution->status === 'active', 403, 'The institution is not active.');

        $username = $this->uniqueUsername($attributes['username'] ?? null, $type, $institution->id);
        $temporaryPassword = $this->generateTemporaryPassword();
        $expiresAt = now()->addHours((int) config('auth.account_activation_hours', 72));

        $user = DB::transaction(function () use ($institution, $membership, $type, $username, $temporaryPassword, $expiresAt, $attributes, $request): User {
            $user = User::query()->lockForUpdate()->where('username', $username)->first();

            if ($user !== null) {
                abort(422, 'The generated username is already taken. Retry provisioning.');
            }

            $user = User::query()->create([
                'name' => $attributes['name'],
                'email' => $attributes['email'],
                'username' => $username,
                'user_type' => $type->value,
                'password' => $temporaryPassword,
                'is_active' => false,
                'activation_expires_at' => $expiresAt,
                'active_institution_id' => $institution->id,
            ]);

            InstitutionMembership::query()->create([
                'institution_id' => $institution->id,
                'user_id' => $user->id,
                'role' => $attributes['role'] ?? $type->defaultRole()[0],
                'is_active' => true,
            ]);

            $this->audit($membership->user, $user, 'auth.account_provisioned', 'success', $request, [
                'institution_id' => $institution->id,
                'user_type' => $type->value,
                'role' => $attributes['role'] ?? $type->defaultRole()[0],
                'username' => $username,
                'activation_expires_at' => $expiresAt->toIso8601String(),
            ]);

            return $user;
        });

        return [
            'user' => $user,
            'temporary_password' => $temporaryPassword,
            'username' => $username,
        ];
    }

    /**
     * @param  array<string, mixed>|null  $preferred
     */
    public function uniqueUsername(?string $preferred, UserAccountType $type, string $institutionId): string
    {
        $base = $this->slugify($preferred ?? $this->defaultUsernameSeed($type, $institutionId));
        $maxAttempts = (int) config('auth.provisioning_username_max_attempts', 10);

        for ($i = 0; $i < $maxAttempts; $i++) {
            $candidate = $i === 0 ? $base : $base.'-'.($i + 1);

            if (! User::query()->where('username', $candidate)->exists()) {
                return $candidate;
            }
        }

        do {
            $candidate = $base.'-'.Str::lower(Str::random(6));
        } while (User::query()->where('username', $candidate)->exists());

        return $candidate;
    }

    public function isUsernameAvailable(string $username, UserAccountType $type, string $institutionId): bool
    {
        $candidate = $this->slugify($username);

        return $candidate !== ''
            && ! User::query()->where('username', $candidate)->exists();
    }

    public function generateTemporaryPassword(): string
    {
        $alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*';

        $password = '';
        $length = (int) config('auth.temporary_password_length', 16);

        for ($i = 0; $i < $length; $i++) {
            $password .= $alphabet[random_int(0, strlen($alphabet) - 1)];
        }

        return $password;
    }

    private function slugify(?string $value): string
    {
        if ($value === null || $value === '') {
            return '';
        }

        $value = Str::lower(trim($value));
        $value = preg_replace('/[^a-z0-9._-]+/', '-', $value) ?? '';
        $value = preg_replace('/[-]+/', '-', $value) ?? '';
        $value = trim($value, '-');

        return Str::limit($value, 32, '');
    }

    private function defaultUsernameSeed(UserAccountType $type, string $institutionId): string
    {
        return $type->value.'.'.Str::substr($institutionId, 0, 8);
    }

    private function audit(User $actor, User $target, string $eventType, string $outcome, Request $request, array $metadata = []): void
    {
        AuditEvent::query()->create([
            'institution_id' => $actor->active_institution_id,
            'actor_id' => $actor->id,
            'event_type' => $eventType,
            'outcome' => $outcome,
            'target_type' => User::class,
            'target_id' => (string) $target->id,
            'metadata' => $metadata,
            'request_id' => Str::limit((string) $request->header('X-Request-Id'), 100, ''),
            'ip_address' => $request->ip(),
            'user_agent' => Str::limit((string) $request->userAgent(), 1024, ''),
        ]);
    }
}
