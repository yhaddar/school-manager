<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AcademicYear;
use App\Models\ClassModel;
use App\Models\Track;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class ClassController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $academicYearId = $request->query('academic_year_id');
        $levelId = $request->query('level_id');
        $trackId = $request->query('track_id');
        $teacherId = $request->query('teacher_id');

        $query = ClassModel::query()
            ->where('institution_id', $institution->id)
            ->where('is_active', true)
            ->with(['level', 'track', 'homeroomTeacher']);

        if ($academicYearId) {
            $query->where('academic_year_id', $academicYearId);
        }
        if ($levelId) {
            $query->where('level_id', $levelId);
        }
        if ($trackId) {
            $query->where('track_id', $trackId);
        }
        if ($teacherId) {
            $query->where('homeroom_teacher_id', $teacherId);
        }

        $classes = $query->get()
            ->map(fn (ClassModel $class): array => [
                'id' => $class->id,
                'academic_year_id' => $class->academic_year_id,
                'level' => $class->level ? ['id' => $class->level->id, 'name' => $class->level->name] : null,
                'track' => $class->track ? ['id' => $class->track->id, 'name' => $class->track->name] : null,
                'name' => $class->name,
                'code' => $class->code,
                'capacity' => $class->capacity,
                'homeroom_teacher' => $class->homeroomTeacher ? ['id' => $class->homeroomTeacher->id, 'name' => $class->homeroomTeacher->name] : null,
            ]);

        return response()->json(['data' => $classes]);
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
            'academic_year_id' => ['required', 'string', 'exists:academic_years,id'],
            'level_id' => ['nullable', 'string', 'exists:levels,id'],
            'track_id' => ['nullable', 'string', 'exists:tracks,id'],
            'name' => ['required', 'string', 'max:255'],
            'code' => ['nullable', 'string', 'max:32'],
            'capacity' => ['integer', 'min:1', 'max:100'],
            'homeroom_teacher_id' => ['nullable', 'integer', 'exists:users,id'],
            'room_id' => ['nullable', 'string', 'exists:rooms,id'],
        ]);

        // Verify academic year belongs to institution
        $academicYear = AcademicYear::query()
            ->where('id', $attributes['academic_year_id'])
            ->where('institution_id', $institution->id)
            ->first();

        if ($academicYear === null) {
            return response()->json(['message' => 'Academic year not found in this institution.'], 404);
        }

        // Verify track belongs to institution
        if ($attributes['track_id']) {
            $track = Track::query()
                ->where('id', $attributes['track_id'])
                ->where('institution_id', $institution->id)
                ->first();

            if ($track === null) {
                return response()->json(['message' => 'Track not found in this institution.'], 404);
            }
        }

        // Verify teacher is in same institution
        if ($attributes['homeroom_teacher_id']) {
            $teacher = User::query()
                ->where('id', $attributes['homeroom_teacher_id'])
                ->where('active_institution_id', $institution->id)
                ->first();

            if ($teacher === null) {
                return response()->json(['message' => 'Teacher not found in this institution.'], 404);
            }
        }

        $class = ClassModel::query()->create([
            'institution_id' => $institution->id,
            'academic_year_id' => $attributes['academic_year_id'],
            'level_id' => $attributes['level_id'] ?? null,
            'track_id' => $attributes['track_id'] ?? null,
            'name' => $attributes['name'],
            'code' => $attributes['code'] ?? Str::upper(Str::slug($attributes['name'], '_')),
            'capacity' => $attributes['capacity'] ?? 30,
            'homeroom_teacher_id' => $attributes['homeroom_teacher_id'] ?? null,
            'room_id' => $attributes['room_id'] ?? null,
        ]);

        return response()->json([
            'data' => [
                'id' => $class->id,
                'academic_year_id' => $class->academic_year_id,
                'name' => $class->name,
                'code' => $class->code,
                'capacity' => $class->capacity,
            ],
        ], 201);
    }
}
