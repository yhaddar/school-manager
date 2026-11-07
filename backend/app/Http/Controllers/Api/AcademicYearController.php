<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AcademicYear;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AcademicYearController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $years = AcademicYear::query()
            ->where('institution_id', $institution->id)
            ->orderBy('starts_at', 'desc')
            ->get()
            ->map(fn (AcademicYear $year): array => [
                'id' => $year->id,
                'name' => $year->name,
                'starts_at' => $year->starts_at->toDateString(),
                'ends_at' => $year->ends_at->toDateString(),
                'is_current' => $year->is_current,
                'is_locked' => $year->is_locked,
            ]);

        return response()->json(['data' => $years]);
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
            'starts_at' => ['required', 'date'],
            'ends_at' => ['required', 'date', 'after:starts_at'],
            'is_current' => ['boolean'],
        ]);

        if (! empty($attributes['is_current']) && $attributes['is_current']) {
            AcademicYear::query()
                ->where('institution_id', $institution->id)
                ->update(['is_current' => false]);
        }

        $academicYear = AcademicYear::query()->create([
            'institution_id' => $institution->id,
            'name' => $attributes['name'],
            'starts_at' => $attributes['starts_at'],
            'ends_at' => $attributes['ends_at'],
            'is_current' => $attributes['is_current'] ?? false,
            'is_locked' => false,
        ]);

        return response()->json([
            'data' => [
                'id' => $academicYear->id,
                'name' => $academicYear->name,
                'starts_at' => $academicYear->starts_at->toDateString(),
                'ends_at' => $academicYear->ends_at->toDateString(),
                'is_current' => $academicYear->is_current,
                'is_locked' => $academicYear->is_locked,
            ],
        ], 201);
    }

    public function show(Request $request, string $academicYearId): JsonResponse
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $academicYear = AcademicYear::query()
            ->where('institution_id', $institution->id)
            ->where('id', $academicYearId)
            ->with(['periods', 'classes'])
            ->first();

        if ($academicYear === null) {
            return response()->json(['message' => 'Academic year not found.'], 404);
        }

        return response()->json(['data' => $academicYear]);
    }
}
