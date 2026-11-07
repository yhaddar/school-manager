<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Department;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class DepartmentController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $parentId = $request->query('parent_id');

        $query = Department::query()
            ->where('institution_id', $institution->id)
            ->where('is_active', true)
            ->with('children');

        if ($parentId) {
            $query->where('parent_id', $parentId);
        } else {
            $query->whereNull('parent_id');
        }

        $departments = $query->get()
            ->map(fn (Department $dept): array => [
                'id' => $dept->id,
                'parent_id' => $dept->parent_id,
                'name' => $dept->name,
                'code' => $dept->code,
                'description' => $dept->description,
            ]);

        return response()->json(['data' => $departments]);
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
            'parent_id' => ['nullable', 'string', 'exists:departments,id'],
            'name' => ['required', 'string', 'max:255'],
            'code' => ['nullable', 'string', 'max:32'],
            'description' => ['nullable', 'string'],
        ]);

        if ($attributes['parent_id']) {
            $parent = Department::query()
                ->where('id', $attributes['parent_id'])
                ->where('institution_id', $institution->id)
                ->first();

            if ($parent === null) {
                return response()->json(['message' => 'Parent department not found in this institution.'], 404);
            }
        }

        $department = Department::query()->create([
            'institution_id' => $institution->id,
            'parent_id' => $attributes['parent_id'] ?? null,
            'name' => $attributes['name'],
            'code' => $attributes['code'] ?? Str::upper(Str::slug($attributes['name'], '_')),
            'description' => $attributes['description'] ?? null,
        ]);

        return response()->json([
            'data' => [
                'id' => $department->id,
                'parent_id' => $department->parent_id,
                'name' => $department->name,
                'code' => $department->code,
            ],
        ], 201);
    }
}
