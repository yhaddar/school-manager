<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Import;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class ImportController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $institutionId = $request->attributes->get('institution')->id;

        $query = Import::where('institution_id', $institutionId)
            ->when(!$user->can('institution-permission', 'imports.view.own'), function ($q) use ($user) {
                $q->where('requested_by', $user->id);
            })
            ->orderBy('created_at', 'desc');

        if ($request->filled('entity_type')) {
            $query->where('entity_type', $request->input('entity_type'));
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

        if (!$user->can('institution-permission', 'imports.create')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'entity_type' => 'required|in:students,teachers,courses,enrollments,grades,attendance',
            'format' => 'in:excel,csv',
        ]);

        $validated['institution_id'] = $institutionId;
        $validated['requested_by'] = $user->id;
        $validated['status'] = 'pending';

        $import = Import::create($validated);

        return response()->json(['data' => $import], 201);
    }

    public function validateImport(Request $request, Import $import)
    {
        $user = $request->user();
        $institutionId = $request->attributes->get('institution')->id;

        if ($import->institution_id !== $institutionId) {
            return response()->json(['message' => 'Not found'], 404);
        }

        if ($import->requested_by !== $user->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Simulate validation
        $import->update([
            'status' => 'validating',
        ]);

        return response()->json(['data' => $import]);
    }

    public function process(Request $request, Import $import)
    {
        $user = $request->user();
        $institutionId = $request->attributes->get('institution')->id;

        if ($import->institution_id !== $institutionId) {
            return response()->json(['message' => 'Not found'], 404);
        }

        if ($import->requested_by !== $user->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Simulate processing
        $import->update([
            'status' => 'processing',
            'started_at' => now(),
        ]);

        // In real implementation, process the import file

        $import->update([
            'status' => 'completed',
            'completed_at' => now(),
            'total_rows' => 100,
            'successful_rows' => 100,
            'failed_rows' => 0,
        ]);

        return response()->json(['data' => $import]);
    }
}
