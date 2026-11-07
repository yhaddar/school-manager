<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ClassModel;
use App\Models\Group;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class GroupController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $classId = $request->query('class_id');

        $query = Group::query()
            ->where('institution_id', $institution->id)
            ->where('is_active', true);

        if ($classId) {
            $query->where('class_id', $classId);
        }

        $groups = $query->get()
            ->map(fn (Group $group): array => [
                'id' => $group->id,
                'class_id' => $group->class_id,
                'name' => $group->name,
                'code' => $group->code,
                'capacity' => $group->capacity,
            ]);

        return response()->json(['data' => $groups]);
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
            'class_id' => ['required', 'integer', 'exists:classes,id'],
            'name' => ['required', 'string', 'max:255'],
            'code' => ['nullable', 'string', 'max:32'],
            'capacity' => ['integer', 'min:1', 'max:100'],
        ]);

        // Verify class belongs to institution
        $class = ClassModel::query()
            ->where('id', $attributes['class_id'])
            ->where('institution_id', $institution->id)
            ->first();

        if ($class === null) {
            return response()->json(['message' => 'Class not found in this institution.'], 404);
        }

        $group = Group::query()->create([
            'institution_id' => $institution->id,
            'class_id' => $attributes['class_id'],
            'name' => $attributes['name'],
            'code' => $attributes['code'] ?? Str::upper(Str::slug($attributes['name'], '_')),
            'capacity' => $attributes['capacity'] ?? 15,
        ]);

        return response()->json([
            'data' => [
                'id' => $group->id,
                'class_id' => $group->class_id,
                'name' => $group->name,
                'code' => $group->code,
            ],
        ], 201);
    }
}
