<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Controller as ApiController;
use App\Models\Assignment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AssignmentController extends ApiController
{
    public function index(Request $request)
    {
        $this->authorize('view', Assignment::class);

        $institutionId = $request->attributes->get('institution')->id;
        $query = Assignment::where('institution_id', $institutionId);

        // Filter by status if provided
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Filter by course if provided
        if ($request->has('course_id')) {
            $query->where('course_id', $request->course_id);
        }

        // Filter by class if provided
        if ($request->has('class_id')) {
            $query->where('class_id', $request->class_id);
        }

        return response()->json([
            'data' => $query->latest()->paginate(15)
        ]);
    }

    public function store(Request $request)
    {
        $this->authorize('create', Assignment::class);

        $validated = Validator::make($request->all(), [
            'course_id' => 'sometimes|exists:courses,id',
            'class_id' => 'sometimes|exists:classes,id',
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'type' => 'required|in:homework,project,quiz',
            'due_at' => 'nullable|date_after:published_at',
            'max_score' => 'sometimes|integer|min:1',
            'status' => 'sometimes|in:draft,published,closed',
        ])->passed();

        if (! $validated) {
            return response()->json([
                'error' => 'Validation failed',
                'details' => validator()->errors()
            ], 422);
        }

        $assignment = Assignment::create([
            'institution_id' => $request->attributes->get('institution')->id,
            'course_id' => $request->course_id,
            'class_id' => $request->class_id,
            'title' => $request->title,
            'description' => $request->description,
            'type' => $request->type,
            'published_at' => $request->published_at ?? now(),
            'due_at' => $request->due_at,
            'max_score' => $request->max_score ?? 100,
            'status' => $request->status ?? 'draft',
        ]);

        return response()->json([
            'data' => $assignment
        ], 201);
    }

    public function show(Request $request, Assignment $assignment)
    {
        $this->authorize('view', $assignment);

        return response()->json([
            'data' => $assignment
        ]);
    }

    public function update(Request $request, Assignment $assignment)
    {
        $this->authorize('update', $assignment);

        $validated = Validator::make($request->all(), [
            'title' => 'sometimes|string|max:255',
            'description' => 'sometimes|string',
            'type' => 'sometimes|in:homework,project,quiz',
            'due_at' => 'nullable|date_after:published_at',
            'max_score' => 'sometimes|integer|min:1',
            'status' => 'sometimes|in:draft,published,closed',
        ])->passed();

        if (! $validated) {
            return response()->json([
                'error' => 'Validation failed',
                'details' => validator()->errors()
            ], 422);
        }

        $assignment->update([
            'title' => $request->title ?? $assignment->title,
            'description' => $request->description ?? $assignment->description,
            'type' => $request->type ?? $assignment->type,
            'due_at' => $request->due_at ?? $assignment->due_at,
            'max_score' => $request->max_score ?? $assignment->max_score,
            'status' => $request->status ?? $assignment->status,
        ]);

        return response()->json([
            'data' => $assignment
        ]);
    }

    public function destroy(Request $request, Assignment $assignment)
    {
        $this->authorize('delete', $assignment);

        $assignment->delete();

        return response()->json([
            'message' => 'Assignment deleted successfully'
        ]);
    }
}
