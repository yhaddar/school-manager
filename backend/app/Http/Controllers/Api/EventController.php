<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Controller as ApiController;
use App\Models\Event;
use Illuminate\Http\Request;

class EventController extends ApiController
{
    public function index(Request $request)
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $query = Event::query()
            ->where('institution_id', $institution->id);

        if ($request->has('type')) {
            $query->where('type', $request->type);
        }

        if ($request->has('status')) {
            $query->where('status', $request->status);
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
            'start_date' => 'required|date',
            'end_date' => 'nullable|date',
            'start_time' => 'sometimes|date',
            'end_time' => 'sometimes|date',
            'all_day' => 'sometimes|boolean',
            'data' => 'sometimes|array',
            'status' => 'sometimes|string',
        ]);

        $event = Event::create([
            'institution_id' => $institution->id,
            'title' => $validated['title'],
            'description' => $validated['description'] ?? null,
            'type' => $validated['type'],
            'start_date' => $validated['start_date'],
            'end_date' => $validated['end_date'] ?? null,
            'start_time' => $validated['start_time'] ?? null,
            'end_time' => $validated['end_time'] ?? null,
            'all_day' => $validated['all_day'] ?? false,
            'data' => $validated['data'] ?? [],
            'status' => $validated['status'] ?? 'upcoming',
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

        $event = Event::query()
            ->where('institution_id', $institution->id)
            ->where('id', $eventId)
            ->first();

        if ($event === null) {
            return response()->json(['message' => 'Event not found.'], 404);
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

        $event = Event::query()
            ->where('institution_id', $institution->id)
            ->where('id', $eventId)
            ->first();

        if ($event === null) {
            return response()->json(['message' => 'Event not found.'], 404);
        }

        $validated = $request->validate([
            'title' => 'sometimes|string|max:255',
            'description' => 'sometimes|string',
            'type' => 'sometimes|string',
            'start_date' => 'sometimes|date',
            'end_date' => 'sometimes|date',
            'start_time' => 'sometimes|date',
            'end_time' => 'sometimes|date',
            'all_day' => 'sometimes|boolean',
            'data' => 'sometimes|array',
            'status' => 'sometimes|string',
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

        $event = Event::query()
            ->where('institution_id', $institution->id)
            ->where('id', $eventId)
            ->first();

        if ($event === null) {
            return response()->json(['message' => 'Event not found.'], 404);
        }

        $event->delete();

        return response()->json([
            'message' => 'Event deleted successfully'
        ]);
    }
}
