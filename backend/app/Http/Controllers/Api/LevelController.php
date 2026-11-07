<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Level;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LevelController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $levels = Level::query()
            ->where('institution_id', $institution->id)
            ->where('is_active', true)
            ->orderBy('sequence')
            ->get()
            ->map(fn (Level $level): array => [
                'id' => $level->id,
                'name' => $level->name,
                'code' => $level->code,
                'sequence' => $level->sequence,
                'education_type' => $level->education_type,
            ]);

        return response()->json(['data' => $levels]);
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
            'name' => ['required', 'string', 'max:255'],
            'code' => ['nullable', 'string', 'max:32'],
            'sequence' => ['required', 'integer', 'min:1'],
            'education_type' => ['nullable', 'string', 'in:preschool,primary,secondary,higher,vocational'],
            'description' => ['nullable', 'string'],
        ]);

        $existingSequence = Level::query()
            ->where('institution_id', $institution->id)
            ->max('sequence');

        if ($existingSequence && $existingSequence >= $attributes['sequence']) {
            Level::query()
                ->where('institution_id', $institution->id)
                ->where('sequence', '>=', $attributes['sequence'])
                ->increment('sequence');
        }

        $level = Level::query()->create([
            'institution_id' => $institution->id,
            'name' => $attributes['name'],
            'code' => $attributes['code'] ?? Str::upper(Str::slug($attributes['name'], '_')),
            'sequence' => $attributes['sequence'],
            'education_type' => $attributes['education_type'] ?? null,
            'description' => $attributes['description'] ?? null,
        ]);

        return response()->json([
            'data' => [
                'id' => $level->id,
                'name' => $level->name,
                'code' => $level->code,
                'sequence' => $level->sequence,
                'education_type' => $level->education_type,
            ],
        ], 201);
    }
}
