<?php

namespace App\Http\Controllers\Api;

use App\Enums\InstitutionRole;
use App\Http\Controllers\Controller;
use App\Models\AuditEvent;
use App\Models\Institution;
use App\Models\InstitutionMembership;
use App\Models\ParentChild;
use App\Models\ParentInvitation;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Str;
use Illuminate\Validation\Rules\Password;

class ParentInvitationController extends Controller
{
    /**
     * Issue a parent invitation to link a parent account with a student.
     */
    public function store(Request $request): JsonResponse
    {
        $attributes = $request->validate([
            'student_email' => ['required', 'email'],
        ]);

        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        abort_unless($user->can('institution-permission', 'parent.invite'), 403);

        $student = User::query()
            ->where('email', $attributes['student_email'])
            ->where('active_institution_id', $institution->id)
            ->where('is_active', true)
            ->where('user_type', 'student')
            ->first();

        if ($student === null) {
            return response()->json(['message' => 'Student not found in this institution.'], 404);
        }

        $result = DB::transaction(function () use ($institution, $user, $student, $request): array {
            $invitation = ParentInvitation::query()->where([
                'institution_id' => $institution->id,
                'student_id' => $student->id,
            ])->first();

            if ($invitation !== null && $invitation->isAvailable()) {
                // Return the existing invitation without a new code (code already delivered)
                return [
                    'invitation' => $invitation,
                    'code' => null,
                    'expires_at' => $invitation->expires_at->toIso8601String(),
                    'already_exists' => true,
                ];
            }

            $code = $this->generateCode();
            $codeHash = hash('sha256', $code);
            $expiresAt = now()->addHours((int) config('auth.parent_invitation_hours', 72));

            $invitation = ParentInvitation::query()->create([
                'institution_id' => $institution->id,
                'student_id' => $student->id,
                'issued_by' => $user->id,
                'code_hash' => $codeHash,
                'expires_at' => $expiresAt,
            ]);

            $this->audit($user, 'parent.invitation_issued', 'success', $request, [
                'student_id' => $student->id,
                'institution_id' => $institution->id,
            ]);

            return [
                'invitation' => $invitation,
                'code' => $code,
                'expires_at' => $expiresAt->toIso8601String(),
                'already_exists' => false,
            ];
        });

        // If invitation already existed, don't return the code again
        if ($result['already_exists']) {
            return response()->json([
                'data' => [
                    'invitation_id' => $result['invitation']->id,
                    'student' => [
                        'id' => $student->id,
                        'name' => $student->name,
                        'email' => $student->email,
                    ],
                    'expires_at' => $result['expires_at'],
                    'message' => 'An active invitation already exists for this student. The code was previously delivered.',
                ],
            ], 200);
        }

        return response()->json([
            'data' => [
                'invitation_id' => $result['invitation']->id,
                'student' => [
                    'id' => $student->id,
                    'name' => $student->name,
                    'email' => $student->email,
                ],
                'invitation_code' => $result['code'],
                'expires_at' => $result['expires_at'],
            ],
        ], 201);
    }

    /**
     * Accept a parent invitation and become linked to the student.
     */
    public function accept(Request $request): JsonResponse
    {
        $attributes = $request->validate([
            'invitation_code' => ['required', 'string'],
            'parent_name' => ['required', 'string', 'max:255'],
            'parent_email' => ['required', 'email'],
            'password' => ['required', 'confirmed', Password::min(12)->mixedCase()->numbers()->symbols()],
        ]);

        $key = 'auth.parent_accept:'.$attributes['invitation_code'].'|'.$request->ip();

        $result = DB::transaction(function () use ($attributes, $request, $key): ?ParentChild {
            $codeHash = hash('sha256', $attributes['invitation_code']);
            $invitation = ParentInvitation::query()
                ->where('code_hash', $codeHash)
                ->where('expires_at', '>', now())
                ->whereNull('accepted_at')
                ->whereNull('revoked_at')
                ->with(['student', 'institution'])
                ->lockForUpdate()
                ->first();

            if ($invitation === null || $invitation->isExpired() || $invitation->isConsumed() || $invitation->isRevoked()) {
                // Only increment rate limiter on actual invalid attempts (not on rate limit check)
                RateLimiter::hit($key, 60);

                return null;
            }

            $parent = User::query()->updateOrCreate(
                ['email' => $attributes['parent_email']],
                [
                    'name' => $attributes['parent_name'],
                    'username' => $this->generateUsername($attributes['parent_name']),
                    'password' => $attributes['password'],
                    'is_active' => true,
                    'user_type' => 'parent',
                    'active_institution_id' => $invitation->institution_id,
                ]
            );

            // Create institution membership for the parent
            InstitutionMembership::query()->firstOrCreate(
                [
                    'institution_id' => $invitation->institution_id,
                    'user_id' => $parent->id,
                ],
                [
                    'role' => InstitutionRole::Parent->value,
                    'is_active' => true,
                ]
            );

            $parentLink = ParentChild::query()->create([
                'institution_id' => $invitation->institution_id,
                'parent_user_id' => $parent->id,
                'child_user_id' => $invitation->student_id,
                'invitation_id' => $invitation->id,
                'is_active' => true,
            ]);

            $invitation->update(['accepted_at' => now()]);

            $this->audit($parent, 'parent.accepted', 'success', $request, [
                'invitation_id' => (string) $invitation->id,
                'student_id' => (string) $invitation->student_id,
            ]);

            return $parentLink;
        });

        if ($result === null) {
            // Check if rate limit was exceeded on this failed attempt
            if (RateLimiter::tooManyAttempts($key, 5)) {
                return response()->json(['message' => 'Too many acceptance attempts.'], 429);
            }

            return response()->json(['message' => 'Invalid or expired invitation code.'], 422);
        }

        RateLimiter::clear($key);

        return response()->json([
            'data' => [
                'parent' => [
                    'id' => $result->parent->id,
                    'name' => $result->parent->name,
                    'email' => $result->parent->email,
                ],
                'child' => [
                    'id' => $result->child->id,
                    'name' => $result->child->name,
                ],
            ],
        ], 201);
    }

    /**
     * List pending parent invitations for this institution.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        abort_unless($user !== null && $user->can('institution-permission', 'parent.invite'), 403);

        $institution = $request->attributes->get('institution');

        if ($institution === null) {
            return response()->json(['message' => 'Valid institution membership required.'], 403);
        }

        $invitations = ParentInvitation::query()
            ->where('institution_id', $institution->id)
            ->where('expires_at', '>', now())
            ->whereNull('accepted_at')
            ->whereNull('revoked_at')
            ->with(['student', 'issuer'])
            ->get()
            ->map(fn (ParentInvitation $invitation): array => [
                'id' => $invitation->id,
                'student' => [
                    'id' => $invitation->student->id,
                    'name' => $invitation->student->name,
                    'email' => $invitation->student->email,
                ],
                'issued_by' => $invitation->issuer->name ?? null,
                'expires_at' => $invitation->expires_at->toIso8601String(),
            ]);

        return response()->json(['data' => $invitations]);
    }

    /**
     * Revoke a pending parent invitation.
     */
    public function destroy(Request $request, string $invitationId): JsonResponse
    {
        $user = $request->user();
        abort_unless($user !== null && $user->can('institution-permission', 'parent.invite'), 403);

        $institution = $request->attributes->get('institution');

        if ($institution === null) {
            return response()->json(['message' => 'Valid institution membership required.'], 403);
        }

        $invitation = ParentInvitation::query()
            ->where('institution_id', $institution->id)
            ->where('id', $invitationId)
            ->first();

        if ($invitation === null) {
            return response()->json(['message' => 'Invitation not found.'], 404);
        }

        if ($invitation->accepted_at !== null) {
            return response()->json(['message' => 'Invitation already accepted.'], 422);
        }

        $invitation->update(['revoked_at' => now()]);

        $this->audit($user, 'parent.invitation_revoked', 'success', $request, [
            'invitation_id' => $invitationId,
        ]);

        return response()->json(status: 204);
    }

    /**
     * List parent-child links for the authenticated user.
     * If user is a parent, lists their children.
     * If user is a student, lists their parent(s).
     */
    public function links(Request $request): JsonResponse
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $userType = $user->user_type?->value ?? $user->user_type;

        if ($userType === 'parent') {
            $links = ParentChild::query()
                ->where('institution_id', $institution->id)
                ->where('parent_user_id', $user->id)
                ->where('is_active', true)
                ->with(['child'])
                ->get()
                ->map(fn (ParentChild $link): array => [
                    'id' => $link->id,
                    'child' => [
                        'id' => $link->child->id,
                        'name' => $link->child->name,
                        'email' => $link->child->email,
                        'username' => $link->child->username,
                    ],
                    'is_active' => $link->is_active,
                ]);
        } elseif ($userType === 'student') {
            $links = ParentChild::query()
                ->where('institution_id', $institution->id)
                ->where('child_user_id', $user->id)
                ->where('is_active', true)
                ->with(['parent'])
                ->get()
                ->map(fn (ParentChild $link): array => [
                    'id' => $link->id,
                    'parent' => [
                        'id' => $link->parent->id,
                        'name' => $link->parent->name,
                        'email' => $link->parent->email,
                        'username' => $link->parent->username,
                    ],
                    'is_active' => $link->is_active,
                ]);
        } else {
            return response()->json(['message' => 'This endpoint is for parents and students only.'], 403);
        }

        return response()->json(['data' => $links]);
    }

    private function generateCode(): string
    {
        return strtoupper(Str::random(8));
    }

    private function generateUsername(string $name): string
    {
        $base = Str::slug($name);
        $suffix = Str::lower(Str::random(6));

        return Str::limit($base.'_'.$suffix, 32, '');
    }

    private function audit(User $actor, string $eventType, string $outcome, Request $request, array $metadata = []): void
    {
        AuditEvent::query()->create([
            'institution_id' => $actor->active_institution_id,
            'actor_id' => $actor->id,
            'event_type' => $eventType,
            'outcome' => $outcome,
            'metadata' => $metadata,
            'request_id' => Str::limit((string) $request->header('X-Request-Id'), 100, ''),
            'ip_address' => $request->ip(),
            'user_agent' => Str::limit((string) $request->userAgent(), 1024, ''),
        ]);
    }
}
