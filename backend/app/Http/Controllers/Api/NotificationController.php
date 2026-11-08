<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Controller as ApiController;
use App\Models\Notification;
use Illuminate\Http\Request;

class NotificationController extends ApiController
{
    public function index(Request $request)
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $query = Notification::query()
            ->where('institution_id', $institution->id);

        if ($request->has('type')) {
            $query->where('type', $request->type);
        }

        // Handle is_read filter - convert string "true"/"false" to boolean
        if ($request->has('is_read')) {
            $isReadValue = $request->input('is_read');
            if (is_string($isReadValue)) {
                $isReadValue = filter_var($isReadValue, FILTER_VALIDATE_BOOLEAN);
            }
            $query->where('is_read', $isReadValue);
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
            'message' => 'required|string',
            'type' => 'required|string',
            'data' => 'sometimes|array',
            'priority' => 'sometimes|in:low,medium,high,urgent',
        ]);

        $notification = Notification::create([
            'institution_id' => $institution->id,
            'title' => $validated['title'],
            'message' => $validated['message'],
            'type' => $validated['type'],
            'data' => $validated['data'] ?? [],
            'priority' => $validated['priority'] ?? 'medium',
            'is_read' => false,
        ]);

        return response()->json([
            'data' => $notification
        ], 201);
    }

    public function show(Request $request, string $notificationId)
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $notification = Notification::query()
            ->where('institution_id', $institution->id)
            ->where('id', $notificationId)
            ->first();

        if ($notification === null) {
            return response()->json(['message' => 'Notification not found.'], 404);
        }

        return response()->json([
            'data' => $notification
        ]);
    }

    public function update(Request $request, string $notificationId)
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $notification = Notification::query()
            ->where('institution_id', $institution->id)
            ->where('id', $notificationId)
            ->first();

        if ($notification === null) {
            return response()->json(['message' => 'Notification not found.'], 404);
        }

        $validated = $request->validate([
            'title' => 'sometimes|string|max:255',
            'message' => 'sometimes|string',
            'type' => 'sometimes|string',
            'data' => 'sometimes|array',
            'priority' => 'sometimes|in:low,medium,high,urgent',
            'is_read' => 'sometimes|boolean',
        ]);

        $notification->update($validated);

        return response()->json([
            'data' => $notification
        ]);
    }

    public function destroy(Request $request, string $notificationId)
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $notification = Notification::query()
            ->where('institution_id', $institution->id)
            ->where('id', $notificationId)
            ->first();

        if ($notification === null) {
            return response()->json(['message' => 'Notification not found.'], 404);
        }

        $notification->delete();

        return response()->json([
            'message' => 'Notification deleted successfully'
        ]);
    }

    public function markAsRead(Request $request, string $notificationId)
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $notification = Notification::query()
            ->where('institution_id', $institution->id)
            ->where('id', $notificationId)
            ->first();

        if ($notification === null) {
            return response()->json(['message' => 'Notification not found.'], 404);
        }

        $notification->update(['is_read' => true]);

        return response()->json([
            'data' => $notification
        ]);
    }

    public function markAllAsRead(Request $request)
    {
        $institution = $request->attributes->get('institution');

        if ($institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        Notification::where('institution_id', $institution->id)
            ->where('is_read', false)
            ->update(['is_read' => true]);

        return response()->json([
            'message' => 'All notifications marked as read'
        ]);
    }
}
