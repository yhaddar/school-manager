<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Controller as ApiController;
use App\Models\Assessment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AssessmentController extends ApiController
{
    public function index(Request $request)
    {
        $this->authorize('view', Assessment::class);

        $institutionId = $request->attributes->get('institution')->id;
        $query = Assessment::where('institution_id', $institutionId);

        // Filter by status if provided
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Filter by course if provided
        if ($request->has('course_id')) {
            $query->where('course_id', $request->course_id);
        }

        return response()->json([
            'data' => $query->latest()->paginate(15)
        ]);
    }

    public function store(Request $request)
    {
        $this->authorize('create', Assessment::class);

        $validated = Validator::make($request->all(), [
            'course_id' => 'sometimes|exists:courses,id',
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'type' => 'required|in:quiz,exam,assignment',
            'published_at' => 'nullable|date',
            'starts_at' => 'nullable|date|after_or_equal:published_at',
            'ends_at' => 'nullable|date|after_or_equal:starts_at',
            'duration_minutes' => 'sometimes|integer|min:1',
            'allow_multiple_attempts' => 'sometimes|boolean',
            'show_results_immediately' => 'sometimes|boolean',
            'status' => 'sometimes|in:draft,published,closed',
        ]);

        if ($validated->fails()) {
            return response()->json([
                'error' => 'Validation failed',
                'details' => $validated->errors()
            ], 422);
        }

        $assessment = Assessment::create([
            'institution_id' => $request->attributes->get('institution')->id,
            'course_id' => $request->course_id,
            'title' => $request->title,
            'description' => $request->description,
            'type' => $request->type,
            'published_at' => $request->published_at ?? now(),
            'starts_at' => $request->starts_at,
            'ends_at' => $request->ends_at,
            'duration_minutes' => $request->duration_minutes,
            'allow_multiple_attempts' => $request->allow_multiple_attempts ?? false,
            'show_results_immediately' => $request->show_results_immediately ?? false,
            'status' => $request->status ?? 'draft',
        ]);

        return response()->json([
            'data' => $assessment
        ], 201);
    }

    public function show(Request $request, Assessment $assessment)
    {
        $this->authorize('view', $assessment);

        return response()->json([
            'data' => $assessment
        ]);
    }

    public function update(Request $request, Assessment $assessment)
    {
        $this->authorize('update', $assessment);

        $validated = Validator::make($request->all(), [
            'title' => 'sometimes|string|max:255',
            'description' => 'sometimes|string',
            'type' => 'sometimes|in:quiz,exam,assignment',
            'published_at' => 'sometimes|date',
            'starts_at' => 'sometimes|date|after_or_equal:published_at',
            'ends_at' => 'sometimes|date|after_or_equal:starts_at',
            'duration_minutes' => 'sometimes|integer|min:1',
            'allow_multiple_attempts' => 'sometimes|boolean',
            'show_results_immediately' => 'sometimes|boolean',
            'status' => 'sometimes|in:draft,published,closed',
        ]);

        if ($validated->fails()) {
            return response()->json([
                'error' => 'Validation failed',
                'details' => $validated->errors()
            ], 422);
        }

        $assessment->update([
            'title' => $request->title ?? $assessment->title,
            'description' => $request->description ?? $assessment->description,
            'type' => $request->type ?? $assessment->type,
            'published_at' => $request->published_at ?? $assessment->published_at,
            'starts_at' => $request->starts_at ?? $assessment->starts_at,
            'ends_at' => $request->ends_at ?? $assessment->ends_at,
            'duration_minutes' => $request->duration_minutes ?? $assessment->duration_minutes,
            'allow_multiple_attempts' => $request->allow_multiple_attempts ?? $assessment->allow_multiple_attempts,
            'show_results_immediately' => $request->show_results_immediately ?? $assessment->show_results_immediately,
            'status' => $request->status ?? $assessment->status,
        ]);

        return response()->json([
            'data' => $assessment
        ]);
    }

    public function destroy(Request $request, Assessment $assessment)
    {
        $this->authorize('delete', $assessment);

        $assessment->delete();

        return response()->json([
            'message' => 'Assessment deleted successfully'
        ]);
    }
}
