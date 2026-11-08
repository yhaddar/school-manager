<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Controller as ApiController;
use App\Models\Grade;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class GradeController extends ApiController
{
    public function index(Request $request)
    {
        $this->authorize('view', Grade::class);

        $institutionId = $request->attributes->get('institution')->id;
        $query = Grade::where('institution_id', $institutionId);

        // Filter by student if provided
        if ($request->has('student_id')) {
            $query->where('student_id', $request->student_id);
        }

        // Filter by course if provided
        if ($request->has('course_id')) {
            $query->where('course_id', $request->course_id);
        }

        // Filter by assignment if provided
        if ($request->has('assignment_id')) {
            $query->where('assignment_id', $request->assignment_id);
        }

        // Filter by assessment if provided
        if ($request->has('assessment_id')) {
            $query->where('assessment_id', $request->assessment_id);
        }

        return response()->json([
            'data' => $query->latest()->paginate(15)
        ]);
    }

    public function store(Request $request)
    {
        $this->authorize('create', Grade::class);

        $validated = Validator::make($request->all(), [
            'student_id' => 'required|exists:users,id',
            'course_id' => 'sometimes|exists:courses,id',
            'assignment_id' => 'sometimes|exists:assignments,id',
            'assessment_id' => 'sometimes|exists:assessments,id',
            'score' => 'required|integer|min:0',
            'max_score' => 'sometimes|integer|min:1',
            'comments' => 'sometimes|string|max:500',
            'type' => 'required|in:assignment,assessment,exam',
            'status' => 'sometimes|in:draft,published,finalized',
        ]);

        if ($validated->fails()) {
            return response()->json([
                'error' => 'Validation failed',
                'details' => $validated->errors()
            ], 422);
        }

        $grade = Grade::create([
            'institution_id' => $request->attributes->get('institution')->id,
            'student_id' => $request->student_id,
            'course_id' => $request->course_id,
            'assignment_id' => $request->assignment_id,
            'assessment_id' => $request->assessment_id,
            'score' => $request->score,
            'max_score' => $request->max_score ?? 100,
            'comments' => $request->comments,
            'type' => $request->type,
            'status' => $request->status ?? 'draft',
        ]);

        return response()->json([
            'data' => $grade
        ], 201);
    }

    public function show(Request $request, Grade $grade)
    {
        $this->authorize('view', $grade);

        return response()->json([
            'data' => $grade
        ]);
    }

    public function update(Request $request, Grade $grade)
    {
        $this->authorize('update', $grade);

        $validated = Validator::make($request->all(), [
            'score' => 'sometimes|integer|min:0',
            'max_score' => 'sometimes|integer|min:1',
            'comments' => 'sometimes|string|max:500',
            'type' => 'sometimes|in:assignment,assessment,exam',
            'status' => 'sometimes|in:draft,published,finalized',
        ]);

        if ($validated->fails()) {
            return response()->json([
                'error' => 'Validation failed',
                'details' => $validated->errors()
            ], 422);
        }

        $grade->update([
            'score' => $request->score ?? $grade->score,
            'max_score' => $request->max_score ?? $grade->max_score,
            'comments' => $request->comments ?? $grade->comments,
            'type' => $request->type ?? $grade->type,
            'status' => $request->status ?? $grade->status,
        ]);

        return response()->json([
            'data' => $grade
        ]);
    }

    public function destroy(Request $request, Grade $grade)
    {
        $this->authorize('delete', $grade);

        $grade->delete();

        return response()->json([
            'message' => 'Grade deleted successfully'
        ]);
    }
}
