<?php

namespace App\Http\Controllers\Api;

use App\Enums\UserAccountType;
use App\Http\Controllers\Controller;
use App\Models\Institution;
use App\Models\InstitutionMembership;
use App\Services\AccountProvisioningService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rules\Password;

class AccountProvisioningController extends Controller
{
    public function __construct(
        private AccountProvisioningService $provisioning = new AccountProvisioningService
    ) {}

    /**
     * Provision a new staff or student account.
     *
     * Returns the temporary password to the authorized administrator.
     */
    public function store(Request $request, ?AccountProvisioningService $provisioning = null): JsonResponse
    {
        $attributes = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255'],
            'username' => ['nullable', 'string', 'max:255'],
            'user_type' => ['required', 'in:staff,student'],
            'role' => ['required', 'string', 'max:64'],
        ]);

        $user = $request->user();
        $institution = $request->attributes->get('institution');
        /** @var InstitutionMembership $membership */
        $membership = $request->attributes->get('institution_membership');

        if ($user === null || $institution === null || $membership === null) {
            return response()->json(['message' => 'Valid institution membership required.'], 403);
        }

        abort_unless($user->can('institution-permission', 'accounts.provision'), 403);

        $service = $provisioning ?? app(AccountProvisioningService::class);
        $result = $service->provision($institution, $membership, $attributes, $request);

        return response()->json([
            'data' => [
                'user' => [
                    'id' => $result['user']->id,
                    'name' => $result['user']->name,
                    'email' => $result['user']->email,
                    'username' => $result['user']->username,
                    'user_type' => $result['user']->user_type->value,
                ],
                'temporary_password' => $result['temporary_password'],
                'activation_expires_at' => $result['user']->activation_expires_at->toIso8601String(),
            ],
        ], 201);
    }

    /**
     * Check if a username is available for the specified user type in this institution.
     */
    public function availability(Request $request, AccountProvisioningService $provisioning): JsonResponse
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid institution membership required.'], 403);
        }

        abort_unless($user->can('institution-permission', 'accounts.provision'), 403);

        $attributes = $request->validate([
            'username' => ['required', 'string', 'max:255'],
            'user_type' => ['required', 'in:staff,student'],
        ]);

        $type = UserAccountType::tryFrom($attributes['user_type']);
        if ($type === null) {
            return response()->json(['message' => 'Invalid user type.'], 422);
        }

        $available = $provisioning->isUsernameAvailable($attributes['username'], $type, $institution->id);

        return response()->json([
            'data' => [
                'username' => $attributes['username'],
                'available' => $available,
            ],
        ]);
    }
}
