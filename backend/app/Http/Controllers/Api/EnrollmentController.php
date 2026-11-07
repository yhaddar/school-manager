<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AcademicYear;
use App\Models\ClassModel;
use App\Models\Enrollment;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class EnrollmentController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $academicYearId = $request->query('academic_year_id');
        $classId = $request->query('class_id');
        $studentId = $request->query('student_id');
        $status = $request->query('status');

        $query = Enrollment::query()
            ->where('institution_id', $institution->id)
            ->with(['academicYear', 'student', 'class', 'track']);

        if ($academicYearId) {
            $query->where('academic_year_id', $academicYearId);
        }
        if ($classId) {
            $query->where('class_id', $classId);
        }
        if ($studentId) {
            $query->where('student_id', $studentId);
        }
        if ($status) {
            $query->where('status', $status);
        }

        $enrollments = $query->get()
            ->map(fn (Enrollment $enrollment): array => [
                'id' => $enrollment->id,
                'academic_year_id' => $enrollment->academic_year_id,
                'student' => $enrollment->student ? ['id' => $enrollment->student->id, 'name' => $enrollment->student->name, 'email' => $enrollment->student->email] : null,
                'class' => $enrollment->class ? ['id' => $enrollment->class->id, 'name' => $enrollment->class->name] : null,
                'track' => $enrollment->track ? ['id' => $enrollment->track->id, 'name' => $enrollment->track->name] : null,
                'status' => $enrollment->status,
                'enrolled_at' => $enrollment->enrolled_at->toDateString(),
            ]);

        return response()->json(['data' => $enrollments]);
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
            'student_id' => ['required', 'integer', 'exists:users,id'],
            'class_id' => ['nullable', 'integer', 'exists:classes,id'],
            'track_id' => ['nullable', 'string', 'exists:tracks,id'],
            'enrolled_at' => ['required', 'date'],
        ]);

        // Verify academic year belongs to institution
        $academicYear = AcademicYear::query()
            ->where('id', $attributes['academic_year_id'])
            ->where('institution_id', $institution->id)
            ->first();

        if ($academicYear === null) {
            return response()->json(['message' => 'Academic year not found in this institution.'], 404);
        }

        // Verify student is in same institution and is a student
        $student = User::query()
            ->where('id', $attributes['student_id'])
            ->where('active_institution_id', $institution->id)
            ->where('user_type', 'student')
            ->first();

        if ($student === null) {
            return response()->json(['message' => 'Student not found in this institution.'], 404);
        }

        // Check if student is already enrolled in this academic year
        $existing = Enrollment::query()
            ->where('academic_year_id', $attributes['academic_year_id'])
            ->where('student_id', $attributes['student_id'])
            ->first();

        if ($existing !== null) {
            return response()->json(['message' => 'Student is already enrolled in this academic year.'], 422);
        }

        // Verify class belongs to institution
        if ($attributes['class_id']) {
            $class = ClassModel::query()
                ->where('id', $attributes['class_id'])
                ->where('institution_id', $institution->id)
                ->first();

            if ($class === null) {
                return response()->json(['message' => 'Class not found in this institution.'], 404);
            }

            // Check class capacity
            $enrolledCount = Enrollment::query()
                ->where('class_id', $attributes['class_id'])
                ->where('status', 'active')
                ->count();

            if ($enrolledCount >= $class->capacity) {
                return response()->json(['message' => 'Class has reached maximum capacity.'], 422);
            }
        }

        $enrollment = Enrollment::query()->create([
            'institution_id' => $institution->id,
            'academic_year_id' => $attributes['academic_year_id'],
            'student_id' => $attributes['student_id'],
            'class_id' => $attributes['class_id'] ?? null,
            'track_id' => $attributes['track_id'] ?? null,
            'status' => 'active',
            'enrolled_at' => $attributes['enrolled_at'],
        ]);

        return response()->json([
            'data' => [
                'id' => $enrollment->id,
                'academic_year_id' => $enrollment->academic_year_id,
                'student_id' => $enrollment->student_id,
                'class_id' => $enrollment->class_id,
                'status' => $enrollment->status,
                'enrolled_at' => $enrollment->enrolled_at->toDateString(),
            ],
        ], 201);
    }
}
