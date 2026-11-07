<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Track;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class TrackController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $levelId = $request->query('level_id');

        $query = Track::query()
            ->where('institution_id', $institution->id)
            ->where('is_active', true);

        if ($levelId) {
            $query->where('level_id', $levelId);
        }

        $tracks = $query->get()
            ->map(fn (Track $track): array => [
                'id' => $track->id,
                'level_id' => $track->level_id,
                'name' => $track->name,
                'code' => $track->code,
                'description' => $track->description,
            ]);

        return response()->json(['data' => $tracks]);
    }

    public function store(Request $request): JsonResponse
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        abort_unless($user->can('institution-permission', 'institution.manage'), 403);

        $attributes = $request->validate([
            'level_id' => ['nullable', 'string', 'exists:levels,id'],
            'name' => ['required', 'string', 'max:255'],
            'code' => ['nullable', 'string', 'max:32'],
            'description' => ['nullable', 'string'],
        ]);

        $track = Track::query()->create([
            'institution_id' => $institution->id,
            'level_id' => $attributes['level_id'] ?? null,
            'name' => $attributes['name'],
            'code' => $attributes['code'] ?? Str::upper(Str::slug($attributes['name'], '_')),
            'description' => $attributes['description'] ?? null,
        ]);

        return response()->json([
            'data' => [
                'id' => $track->id,
                'level_id' => $track->level_id,
                'name' => $track->name,
                'code' => $track->code,
            ],
        ], 201);
    }
}
