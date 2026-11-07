<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Department;
use App\Models\Subject;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class SubjectController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $departmentId = $request->query('department_id');

        $query = Subject::query()
            ->where('institution_id', $institution->id)
            ->where('is_active', true);

        if ($departmentId) {
            $query->where('department_id', $departmentId);
        }

        $subjects = $query->get()
            ->map(fn (Subject $subject): array => [
                'id' => $subject->id,
                'department_id' => $subject->department_id,
                'name' => $subject->name,
                'code' => $subject->code,
                'description' => $subject->description,
            ]);

        return response()->json(['data' => $subjects]);
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
            'department_id' => ['nullable', 'string', 'exists:departments,id'],
            'name' => ['required', 'string', 'max:255'],
            'code' => ['nullable', 'string', 'max:32'],
            'description' => ['nullable', 'string'],
        ]);

        if ($attributes['department_id']) {
            $department = Department::query()
                ->where('id', $attributes['department_id'])
                ->where('institution_id', $institution->id)
                ->first();

            if ($department === null) {
                return response()->json(['message' => 'Department not found in this institution.'], 404);
            }
        }

        $subject = Subject::query()->create([
            'institution_id' => $institution->id,
            'department_id' => $attributes['department_id'] ?? null,
            'name' => $attributes['name'],
            'code' => $attributes['code'] ?? Str::upper(Str::slug($attributes['name'], '_')),
            'description' => $attributes['description'] ?? null,
        ]);

        return response()->json([
            'data' => [
                'id' => $subject->id,
                'department_id' => $subject->department_id,
                'name' => $subject->name,
                'code' => $subject->code,
            ],
        ], 201);
    }
}
