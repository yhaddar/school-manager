<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Report;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class ReportController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $institutionId = $request->attributes->get('institution')->id;

        $query = Report::where('institution_id', $institutionId)
            ->when($user->can('institution-permission', 'reports.view'), function ($q) {
                // Admin/Director can see all reports
            })
            ->when($user->can('institution-permission', 'reports.view.own'), function ($q) use ($user) {
                // Teachers can see only their own reports
                $q->where('created_by', $user->id);
            })
            ->orderBy('created_at', 'desc');

        if ($request->filled('type')) {
            $query->where('type', $request->input('type'));
        }

        if ($request->filled('status')) {
            $query->where('status', $request->input('status'));
        }

        return response()->json(['data' => $query->paginate($request->get('per_page', 15))]);
    }

    public function store(Request $request)
    {
        $institutionId = $request->attributes->get('institution')->id;
        $user = $request->user();

        if (!$user->can('institution-permission', 'reports.create')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'type' => 'required|in:academic,attendance,financial,enrollment,custom',
            'parameters' => 'nullable|array',
            'columns' => 'nullable|array',
            'format' => 'in:pdf,excel,csv',
        ]);

        $validated['institution_id'] = $institutionId;
        $validated['slug'] = Str::slug($request->title) . '-' . Str::lower(Str::random(8));
        $validated['created_by'] = $user->id;
        $validated['status'] = 'pending';

        $report = Report::create($validated);

        return response()->json(['data' => $report], 201);
    }

    public function show(Request $request, Report $report)
    {
        $user = $request->user();
        $institutionId = $request->attributes->get('institution')->id;

        if ($report->institution_id !== $institutionId) {
            return response()->json(['message' => 'Not found'], 404);
        }

        if (!$user->can('institution-permission', 'reports.view') && 
            !$user->can('institution-permission', 'reports.view.own') &&
            $report->created_by !== $user->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return response()->json(['data' => $report]);
    }

    public function update(Request $request, Report $report)
    {
        $user = $request->user();
        $institutionId = $request->attributes->get('institution')->id;

        if ($report->institution_id !== $institutionId) {
            return response()->json(['message' => 'Not found'], 404);
        }

        if ($report->created_by !== $user->id && !$user->can('institution-permission', 'reports.manage')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'title' => 'sometimes|string|max:255',
            'type' => 'sometimes|in:academic,attendance,financial,enrollment,custom',
            'parameters' => 'sometimes|nullable|array',
            'columns' => 'sometimes|nullable|array',
            'format' => 'sometimes|in:pdf,excel,csv',
        ]);

        $report->update($validated);

        return response()->json(['data' => $report]);
    }

    public function destroy(Request $request, Report $report)
    {
        $user = $request->user();
        $institutionId = $request->attributes->get('institution')->id;

        if ($report->institution_id !== $institutionId) {
            return response()->json(['message' => 'Not found'], 404);
        }

        if (!$user->can('institution-permission', 'reports.manage')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $report->delete();

        return response()->json(status: 204);
    }

    public function generate(Request $request, Report $report)
    {
        $user = $request->user();
        $institutionId = $request->attributes->get('institution')->id;

        if ($report->institution_id !== $institutionId) {
            return response()->json(['message' => 'Not found'], 404);
        }

        if ($report->created_by !== $user->id && !$user->can('institution-permission', 'reports.manage')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // For now, simulate report generation
        // In a real implementation, this would generate the actual report file
        $report->update([
            'status' => 'completed',
            'generated_at' => now(),
            'file_path' => '/storage/reports/' . $report->id . '.pdf',
            'file_name' => $report->title . '.pdf',
            'file_size' => 1024,
        ]);

        return response()->json(['data' => $report]);
    }
}
