<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AcademicYear;
use App\Models\ClassModel;
use App\Models\Course;
use App\Models\Subject;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CourseController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $academicYearId = $request->query('academic_year_id');
        $subjectId = $request->query('subject_id');
        $teacherId = $request->query('teacher_id');

        $query = Course::query()
            ->where('institution_id', $institution->id)
            ->where('is_active', true)
            ->with(['academicYear', 'subject', 'class', 'group', 'teacher']);

        if ($academicYearId) {
            $query->where('academic_year_id', $academicYearId);
        }
        if ($subjectId) {
            $query->where('subject_id', $subjectId);
        }
        if ($teacherId) {
            $query->where('teacher_id', $teacherId);
        }

        $courses = $query->get()
            ->map(fn (Course $course): array => [
                'id' => $course->id,
                'academic_year_id' => $course->academic_year_id,
                'subject' => $course->subject ? ['id' => $course->subject->id, 'name' => $course->subject->name] : null,
                'class' => $course->class ? ['id' => $course->class->id, 'name' => $course->class->name] : null,
                'group' => $course->group ? ['id' => $course->group->id, 'name' => $course->group->name] : null,
                'teacher' => $course->teacher ? ['id' => $course->teacher->id, 'name' => $course->teacher->name] : null,
                'name' => $course->name,
                'code' => $course->code,
                'weekly_hours' => $course->weekly_hours,
            ]);

        return response()->json(['data' => $courses]);
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
            'subject_id' => ['required', 'string', 'exists:subjects,id'],
            'class_id' => ['nullable', 'integer', 'exists:classes,id'],
            'group_id' => ['nullable', 'integer', 'exists:groups,id'],
            'teacher_id' => ['nullable', 'integer', 'exists:users,id'],
            'name' => ['nullable', 'string', 'max:255'],
            'code' => ['nullable', 'string', 'max:32'],
            'weekly_hours' => ['integer', 'min:1', 'max:10'],
        ]);

        // Verify academic year belongs to institution
        $academicYear = AcademicYear::query()
            ->where('id', $attributes['academic_year_id'])
            ->where('institution_id', $institution->id)
            ->first();

        if ($academicYear === null) {
            return response()->json(['message' => 'Academic year not found in this institution.'], 404);
        }

        // Verify subject belongs to institution
        $subject = Subject::query()
            ->where('id', $attributes['subject_id'])
            ->where('institution_id', $institution->id)
            ->first();

        if ($subject === null) {
            return response()->json(['message' => 'Subject not found in this institution.'], 404);
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
        }

        // Verify teacher is in same institution
        if ($attributes['teacher_id']) {
            $teacher = User::query()
                ->where('id', $attributes['teacher_id'])
                ->where('active_institution_id', $institution->id)
                ->first();

            if ($teacher === null) {
                return response()->json(['message' => 'Teacher not found in this institution.'], 404);
            }
        }

        $course = Course::query()->create([
            'institution_id' => $institution->id,
            'academic_year_id' => $attributes['academic_year_id'],
            'subject_id' => $attributes['subject_id'],
            'class_id' => $attributes['class_id'] ?? null,
            'group_id' => $attributes['group_id'] ?? null,
            'teacher_id' => $attributes['teacher_id'] ?? null,
            'name' => $attributes['name'] ?? null,
            'code' => $attributes['code'] ?? null,
            'weekly_hours' => $attributes['weekly_hours'] ?? 1,
        ]);

        return response()->json([
            'data' => [
                'id' => $course->id,
                'academic_year_id' => $course->academic_year_id,
                'subject_id' => $course->subject_id,
                'name' => $course->name,
                'code' => $course->code,
                'weekly_hours' => $course->weekly_hours,
            ],
        ], 201);
    }

    /**
     * Assign a teacher to a course.
     *
     * Only institution administrators can assign teachers.
     */
    public function assignTeacher(Request $request, string $courseId): JsonResponse
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        abort_unless($user->can('institution-permission', 'institution.manage'), 403);

        $attributes = $request->validate([
            'teacher_id' => ['required', 'integer', 'exists:users,id'],
        ]);

        // Verify teacher is in same institution
        $teacher = User::query()
            ->where('id', $attributes['teacher_id'])
            ->where('active_institution_id', $institution->id)
            ->first();

        if ($teacher === null) {
            return response()->json(['message' => 'Teacher not found in this institution.'], 404);
        }

        // Verify course belongs to institution
        $course = Course::query()
            ->where('institution_id', $institution->id)
            ->where('id', $courseId)
            ->first();

        if ($course === null) {
            return response()->json(['message' => 'Course not found in this institution.'], 404);
        }

        $course->update(['teacher_id' => $attributes['teacher_id']]);

        return response()->json([
            'data' => [
                'id' => $course->id,
                'teacher_id' => $course->teacher_id,
                'teacher_name' => $teacher->name,
            ],
        ]);
    }
}
