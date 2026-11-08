<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Controller as ApiController;
use App\Models\Submission;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class SubmissionController extends ApiController
{
    public function index(Request $request)
    {
        $this->authorize('view', Submission::class);

        $institutionId = $request->attributes->get('institution')->id;
        $query = Submission::where('institution_id', $institutionId);

        // Filter by assignment if provided
        if ($request->has('assignment_id')) {
            $query->where('assignment_id', $request->assignment_id);
        }

        // Filter by student if provided
        if ($request->has('student_id')) {
            $query->where('student_id', $request->student_id);
        }

        // Filter by status if provided
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        return response()->json([
            'data' => $query->latest()->paginate(15)
        ]);
    }

    public function store(Request $request)
    {
        $this->authorize('create', Submission::class);

        $validated = Validator::make($request->all(), [
            'assignment_id' => 'required|exists:assignments,id',
            'content' => 'sometimes|string',
            'attachment_path' => 'sometimes|string',
            'status' => 'sometimes|in:pending,submitted,graded,late',
        ])->passed();

        if (! $validated) {
            return response()->json([
                'error' => 'Validation failed',
                'details' => validator()->errors()
            ], 422);
        }

        $submission = Submission::create([
            'institution_id' => $request->attributes->get('institution')->id,
            'assignment_id' => $request->assignment_id,
            'student_id' => $request->user()->id,
            'content' => $request->content,
            'attachment_path' => $request->attachment_path,
            'status' => $request->status ?? 'pending',
        ]);

        return response()->json([
            'data' => $submission
        ], 201);
    }

    public function show(Request $request, Submission $submission)
    {
        $this->authorize('view', $submission);

        return response()->json([
            'data' => $submission
        ]);
    }

    public function update(Request $request, Submission $submission)
    {
        $this->authorize('update', $submission);

        $validated = Validator::make($request->all(), [
            'content' => 'sometimes|string',
            'attachment_path' => 'sometimes|string',
            'status' => 'sometimes|in:pending,submitted,graded,late',
        ])->passed();

        if (! $validated) {
            return response()->json([
                'error' => 'Validation failed',
                'details' => validator()->errors()
            ], 422);
        }

        $submission->update([
            'content' => $request->content ?? $submission->content,
            'attachment_path' => $request->attachment_path ?? $submission->attachment_path,
            'status' => $request->status ?? $submission->status,
        ]);

        return response()->json([
            'data' => $submission
        ]);
    }

    public function destroy(Request $request, Submission $submission)
    {
        $this->authorize('delete', $submission);

        $submission->delete();

        return response()->json([
            'message' => 'Submission deleted successfully'
        ]);
    }
}
