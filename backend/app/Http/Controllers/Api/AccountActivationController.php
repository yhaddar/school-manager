<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AuditEvent;
use App\Models\User;
use App\Services\SessionService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Str;
use Illuminate\Validation\Rules\Password;

class AccountActivationController extends Controller
{
    public function store(Request $request, SessionService $sessions): JsonResponse
    {
        $attributes = $request->validate([
            'username' => ['required', 'string', 'max:255'],
            'temporary_password' => ['required', 'string'],
            'password' => ['required', 'confirmed', Password::min(12)->mixedCase()->numbers()->symbols()],
        ]);
        $username = strtolower($attributes['username']);
        $key = 'auth.activation:'.$username.'|'.$request->ip();

        if (RateLimiter::tooManyAttempts($key, 5)) {
            return response()->json(['message' => 'Too many activation attempts.'], 429);
        }

        $result = DB::transaction(function () use ($attributes, $username, $request, $sessions): ?array {
            $user = User::query()->whereRaw('lower(username) = ?', [$username])->lockForUpdate()->first();

            if (! $user || $user->is_active || ! $user->activation_expires_at || $user->activation_expires_at->isPast() || ! Hash::check($attributes['temporary_password'], $user->password)) {
                if ($user) {
                    $this->audit($user, 'auth.account_activation_denied', 'denied', $request);
                }

                return null;
            }

            if (Hash::check($attributes['password'], $user->password)) {
                return [];
            }

            $user->forceFill([
                'password' => $attributes['password'],
                'is_active' => true,
                'activated_at' => now(),
                'activation_expires_at' => null,
            ])->save();
            $this->audit($user, 'auth.account_activated', 'success', $request);

            return $sessions->create($user, $request);
        });

        if ($result === []) {
            return response()->json(['message' => 'New password must differ from the temporary password.'], 422);
        }

        if (! $result) {
            RateLimiter::hit($key, 60);

            return response()->json(['message' => 'Invalid activation credentials.'], 422);
        }

        RateLimiter::clear($key);

        return response()->json(['data' => $result], 201);
    }

    private function audit(User $user, string $eventType, string $outcome, Request $request): void
    {
        AuditEvent::query()->create([
            'institution_id' => $user->active_institution_id,
            'actor_id' => $user->id,
            'event_type' => $eventType,
            'outcome' => $outcome,
            'target_type' => User::class,
            'target_id' => (string) $user->id,
            'request_id' => Str::limit((string) $request->header('X-Request-Id'), 100, ''),
            'ip_address' => $request->ip(),
            'user_agent' => Str::limit((string) $request->userAgent(), 1024, ''),
        ]);
    }
}
