<?php

namespace App\Services;

use App\Models\ApiSession;
use App\Models\AuditEvent;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class SessionService
{
    /** @return array{access_token: string, refresh_token: string, access_expires_at: string, refresh_expires_at: string} */
    public function create(User $user, Request $request): array
    {
        return DB::transaction(function () use ($user, $request): array {
            $session = new ApiSession(['user_id' => $user->id]);
            $session->id = (string) Str::ulid();
            $tokens = $this->replaceTokens($session, $request);
            $session->save();
            $this->audit($user, 'auth.session_created', 'success', $request, $session);

            return $tokens;
        });
    }

    /** @return array{access_token: string, refresh_token: string, access_expires_at: string, refresh_expires_at: string}|null */
    public function refresh(?string $refreshToken, Request $request): ?array
    {
        [$sessionId, $secret] = $this->tokenParts($refreshToken);

        if (! $sessionId || ! $secret) {
            return null;
        }

        return DB::transaction(function () use ($sessionId, $secret, $request): ?array {
            $session = ApiSession::query()->with('user')->lockForUpdate()->find($sessionId);

            if (! $session || $session->revoked_at || $session->refresh_expires_at->isPast()) {
                return null;
            }

            if (! hash_equals($session->refresh_token_hash, hash('sha256', $secret))) {
                $session->forceFill(['revoked_at' => now()])->save();
                $this->audit($session->user, 'auth.refresh_reused', 'denied', $request, $session);

                return null;
            }

            $tokens = $this->replaceTokens($session, $request);
            $session->save();
            $this->audit($session->user, 'auth.session_refreshed', 'success', $request, $session);

            return $tokens;
        });
    }

    public function authenticateAccessToken(?string $accessToken): ?ApiSession
    {
        [$sessionId, $secret] = $this->tokenParts($accessToken);

        if (! $sessionId || ! $secret) {
            return null;
        }

        $session = ApiSession::query()->with('user')->find($sessionId);

        if (! $session || $session->revoked_at || $session->access_expires_at->isPast()) {
            return null;
        }

        return hash_equals($session->access_token_hash, hash('sha256', $secret)) ? $session : null;
    }

    public function revoke(ApiSession $session, Request $request): void
    {
        if ($session->revoked_at) {
            return;
        }

        $session->forceFill(['revoked_at' => now()])->save();
        $this->audit($session->user, 'auth.session_revoked', 'success', $request, $session);
    }

    /** @return array{access_token: string, refresh_token: string, access_expires_at: string, refresh_expires_at: string} */
    private function replaceTokens(ApiSession $session, Request $request): array
    {
        $accessSecret = bin2hex(random_bytes(32));
        $refreshSecret = bin2hex(random_bytes(32));
        $accessExpiresAt = now()->addMinutes(config('auth.api_session_access_minutes'));
        $refreshExpiresAt = now()->addDays(config('auth.api_session_refresh_days'));

        $session->forceFill([
            'access_token_hash' => hash('sha256', $accessSecret),
            'refresh_token_hash' => hash('sha256', $refreshSecret),
            'access_expires_at' => $accessExpiresAt,
            'refresh_expires_at' => $refreshExpiresAt,
            'ip_address' => $request->ip(),
            'user_agent' => Str::limit((string) $request->userAgent(), 1024, ''),
        ]);

        return [
            'access_token' => $session->id.'.'.$accessSecret,
            'refresh_token' => $session->id.'.'.$refreshSecret,
            'access_expires_at' => $accessExpiresAt->toIso8601String(),
            'refresh_expires_at' => $refreshExpiresAt->toIso8601String(),
        ];
    }

    /** @return array{0: ?string, 1: ?string} */
    private function tokenParts(?string $token): array
    {
        if (! $token || ! str_contains($token, '.')) {
            return [null, null];
        }

        [$sessionId, $secret] = explode('.', $token, 2);

        return [$sessionId ?: null, $secret ?: null];
    }

    private function audit(User $user, string $eventType, string $outcome, Request $request, ApiSession $session): void
    {
        AuditEvent::query()->create([
            'institution_id' => $user->active_institution_id,
            'actor_id' => $user->id,
            'event_type' => $eventType,
            'outcome' => $outcome,
            'target_type' => ApiSession::class,
            'target_id' => $session->id,
            'request_id' => Str::limit((string) $request->header('X-Request-Id'), 100, ''),
            'ip_address' => $request->ip(),
            'user_agent' => Str::limit((string) $request->userAgent(), 1024, ''),
        ]);
    }
}
