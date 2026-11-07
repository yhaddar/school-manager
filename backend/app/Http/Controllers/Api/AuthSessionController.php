<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\InstitutionMembership;
use App\Services\SessionService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\RateLimiter;

class AuthSessionController extends Controller
{
    public function store(Request $request, SessionService $sessions): JsonResponse
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);
        $email = strtolower($credentials['email']);
        $key = 'auth.login:'.$email.'|'.$request->ip();

        if (RateLimiter::tooManyAttempts($key, 5)) {
            return response()->json(['message' => 'Too many login attempts.'], 429);
        }

        $user = User::query()->where('email', $email)->first();

        if (! $user || ! $user->is_active || ! Hash::check($credentials['password'], $user->password)) {
            RateLimiter::hit($key, 60);

            return response()->json(['message' => 'Invalid credentials.'], 422);
        }

        RateLimiter::clear($key);

        return response()->json(['data' => $sessions->create($user, $request)], 201);
    }

    public function refresh(Request $request, SessionService $sessions): JsonResponse
    {
        $attributes = $request->validate(['refresh_token' => ['required', 'string']]);
        $tokens = $sessions->refresh($attributes['refresh_token'], $request);

        if (! $tokens) {
            return response()->json(['message' => 'Invalid refresh token.'], 401);
        }

        return response()->json(['data' => $tokens]);
    }

    public function destroy(Request $request, SessionService $sessions): JsonResponse
    {
        $sessions->revoke($request->attributes->get('api_session'), $request);

        return response()->json(status: 204);
    }

    public function show(Request $request): JsonResponse
    {
        $user = $request->user();
        $membership = InstitutionMembership::where('user_id', $user->id)
            ->where('is_active', true)
            ->where('institution_id', $user->active_institution_id)
            ->first();

        $userData = [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'username' => $user->username,
            'user_type' => $user->user_type->value,
            'is_active' => $user->is_active,
            'active_institution_id' => $user->active_institution_id,
            'membership_role' => $membership?->role->value,
        ];

        return response()->json(['data' => $userData]);
    }
}
