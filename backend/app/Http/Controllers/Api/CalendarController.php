<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Controller as ApiController;
use App\Models\CalendarEvent;
use Illuminate\Http\Request;

class CalendarController extends ApiController
{
    public function index(Request $request)
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $query = CalendarEvent::query()
            ->where('institution_id', $institution->id);

        if ($request->has('type')) {
            $query->where('type', $request->type);
        }

        if ($request->has('start_date')) {
            $query->where('starts_at', '>=', $request->start_date);
        }

        if ($request->has('end_date')) {
            $query->where('ends_at', '<=', $request->end_date);
        }

        return response()->json([
            'data' => $query->latest()->paginate(20)
        ]);
    }

    public function store(Request $request)
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'type' => 'required|string',
            'starts_at' => 'required|date',
            'ends_at' => 'required|date|after_or_equal:starts_at',
            'all_day' => 'sometimes|boolean',
            'data' => 'sometimes|array',
        ]);

        $event = CalendarEvent::create([
            'institution_id' => $institution->id,
            'title' => $validated['title'],
            'description' => $validated['description'] ?? null,
            'type' => $validated['type'],
            'starts_at' => $validated['starts_at'],
            'ends_at' => $validated['ends_at'],
            'all_day' => $validated['all_day'] ?? false,
            'data' => $validated['data'] ?? [],
        ]);

        return response()->json([
            'data' => $event
        ], 201);
    }

    public function show(Request $request, string $eventId)
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $event = CalendarEvent::query()
            ->where('institution_id', $institution->id)
            ->where('id', $eventId)
            ->first();

        if ($event === null) {
            return response()->json(['message' => 'Calendar event not found.'], 404);
        }

        return response()->json([
            'data' => $event
        ]);
    }

    public function update(Request $request, string $eventId)
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $event = CalendarEvent::query()
            ->where('institution_id', $institution->id)
            ->where('id', $eventId)
            ->first();

        if ($event === null) {
            return response()->json(['message' => 'Calendar event not found.'], 404);
        }

        $validated = $request->validate([
            'title' => 'sometimes|string|max:255',
            'description' => 'sometimes|string',
            'type' => 'sometimes|string',
            'starts_at' => 'sometimes|date',
            'ends_at' => 'sometimes|date|after_or_equal:starts_at',
            'all_day' => 'sometimes|boolean',
            'data' => 'sometimes|array',
        ]);

        $event->update($validated);

        return response()->json([
            'data' => $event
        ]);
    }

    public function destroy(Request $request, string $eventId)
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $event = CalendarEvent::query()
            ->where('institution_id', $institution->id)
            ->where('id', $eventId)
            ->first();

        if ($event === null) {
            return response()->json(['message' => 'Calendar event not found.'], 404);
        }

        $event->delete();

        return response()->json([
            'message' => 'Calendar event deleted successfully'
        ]);
    }
}
