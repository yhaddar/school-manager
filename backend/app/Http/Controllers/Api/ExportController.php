<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Export;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class ExportController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $institutionId = $request->attributes->get('institution')->id;

        $query = Export::where('institution_id', $institutionId)
            ->when(!$user->can('institution-permission', 'exports.view.own'), function ($q) use ($user) {
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

        if (!$user->can('institution-permission', 'exports.create')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'entity_type' => 'required|in:students,teachers,grades,attendance,enrollments,courses,messages,notifications,events,calendar_events',
            'filters' => 'nullable|array',
            'columns' => 'nullable|array',
            'format' => 'in:excel,csv',
        ]);

        $validated['institution_id'] = $institutionId;
        $validated['requested_by'] = $user->id;
        $validated['status'] = 'pending';

        $export = Export::create($validated);

        // Dispatch job to process export (in real implementation)
        // ExportJob::dispatch($export);

        return response()->json(['data' => $export], 201);
    }

    public function show(Request $request, Export $export)
    {
        $user = $request->user();
        $institutionId = $request->attributes->get('institution')->id;

        if ($export->institution_id !== $institutionId) {
            return response()->json(['message' => 'Not found'], 404);
        }

        if (!$user->can('institution-permission', 'exports.view') && 
            $export->requested_by !== $user->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return response()->json(['data' => $export]);
    }

    public function download(Request $request, Export $export)
    {
        $user = $request->user();
        $institutionId = $request->attributes->get('institution')->id;

        if ($export->institution_id !== $institutionId) {
            return response()->json(['message' => 'Not found'], 404);
        }

        if ($export->requested_by !== $user->id && !$user->can('institution-permission', 'exports.manage')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if ($export->status !== 'completed') {
            return response()->json(['message' => 'Export not ready'], 400);
        }

        // In real implementation, return file download
        // return response()->download(storage_path('app/public/' . $export->file_path));
        
        return response()->json([
            'data' => [
                'download_url' => url('/api/v1/exports/' . $export->id . '/download'),
                'file_name' => $export->file_name,
                'file_size' => $export->file_size,
            ]
        ]);
    }
}
