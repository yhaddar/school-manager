<?php

namespace App\Http\Controllers\Api\SuperAdmin;

use App\Http\Controllers\Controller;
use App\Models\Institution;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class InstitutionController extends Controller
{
    /**
     * List all institutions (Super Admin only).
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        
        if (!$user || !$user->can('platform-permission', 'super-admin')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $query = Institution::query();

        if ($request->input('status')) {
            $query->where('status', $request->input('status'));
        }

        if ($request->input('search')) {
            $query->where('name', 'like', "%{$request->input('search')}%");
        }

        $institutions = $query->orderBy('created_at', 'desc')->get();

        return response()->json(['data' => $institutions]);
    }

    /**
     * Create a new institution.
     */
    public function store(Request $request): JsonResponse
    {
        $user = $request->user();
        
        if (!$user || !$user->can('platform-permission', 'super-admin')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $attributes = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'status' => ['sometimes', 'string', 'in:active,inactive,suspended'],
        ]);

        $institution = Institution::create($attributes);

        return response()->json(['data' => $institution], 201);
    }

    /**
     * Get institution details.
     */
    public function show(Institution $institution): JsonResponse
    {
        $user = request()->user();
        
        if (!$user || !$user->can('platform-permission', 'super-admin')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $memberCount = $institution->memberships()->count();

        return response()->json([
            'data' => [
                'id' => $institution->id,
                'name' => $institution->name,
                'status' => $institution->status,
                'created_at' => $institution->created_at?->toIso8601String(),
                'updated_at' => $institution->updated_at?->toIso8601String(),
                'member_count' => $memberCount,
            ]
        ]);
    }

    /**
     * Update institution.
     */
    public function update(Request $request, Institution $institution): JsonResponse
    {
        $user = $request->user();
        
        if (!$user || !$user->can('platform-permission', 'super-admin')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $attributes = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'status' => ['sometimes', 'string', 'in:active,inactive,suspended'],
        ]);

        $institution->update($attributes);

        return response()->json(['data' => $institution]);
    }

    /**
     * Archive/deactivate institution.
     */
    public function destroy(Request $request, Institution $institution): JsonResponse
    {
        $user = $request->user();
        
        if (!$user || !$user->can('platform-permission', 'super-admin')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Prevent deleting institutions with active memberships
        if ($institution->memberships()->where('is_active', true)->exists()) {
            return response()->json([
                'message' => 'Cannot archive institution with active memberships. Deactivate members first.'
            ], 422);
        }

        $institution->update(['status' => 'inactive']);

        return response()->json(['data' => $institution]);
    }
}
