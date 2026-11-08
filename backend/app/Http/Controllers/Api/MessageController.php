<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Controller as ApiController;
use App\Models\Message;
use Illuminate\Http\Request;

class MessageController extends ApiController
{
    public function index(Request $request)
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $query = Message::query()
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

        if ($request->has('recipient_type')) {
            $query->where('recipient_type', $request->recipient_type);
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
            'subject' => 'required|string|max:255',
            'message' => 'required|string',
            'recipient_type' => 'required|in:parent,teacher,student',
            'recipient_id' => 'sometimes|exists:users,id',
            'data' => 'sometimes|array',
        ]);

        $message = Message::create([
            'institution_id' => $institution->id,
            'sender_id' => $user->id,
            'subject' => $validated['subject'],
            'message' => $validated['message'],
            'type' => $validated['recipient_type'],
            'recipient_id' => $validated['recipient_id'] ?? null,
            'data' => $validated['data'] ?? [],
            'is_read' => false,
        ]);

        return response()->json([
            'data' => $message
        ], 201);
    }

    public function show(Request $request, string $messageId)
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $message = Message::query()
            ->where('institution_id', $institution->id)
            ->where('id', $messageId)
            ->first();

        if ($message === null) {
            return response()->json(['message' => 'Message not found.'], 404);
        }

        return response()->json([
            'data' => $message
        ]);
    }

    public function update(Request $request, string $messageId)
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $message = Message::query()
            ->where('institution_id', $institution->id)
            ->where('id', $messageId)
            ->first();

        if ($message === null) {
            return response()->json(['message' => 'Message not found.'], 404);
        }

        $validated = $request->validate([
            'subject' => 'sometimes|string|max:255',
            'message' => 'sometimes|string',
            'data' => 'sometimes|array',
            'is_read' => 'sometimes|boolean',
        ]);

        $message->update($validated);

        return response()->json([
            'data' => $message
        ]);
    }

    public function destroy(Request $request, string $messageId)
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $message = Message::query()
            ->where('institution_id', $institution->id)
            ->where('id', $messageId)
            ->first();

        if ($message === null) {
            return response()->json(['message' => 'Message not found.'], 404);
        }

        $message->delete();

        return response()->json([
            'message' => 'Message deleted successfully'
        ]);
    }

    public function markAsRead(Request $request, string $messageId)
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $message = Message::query()
            ->where('institution_id', $institution->id)
            ->where('id', $messageId)
            ->first();

        if ($message === null) {
            return response()->json(['message' => 'Message not found.'], 404);
        }

        $message->update(['is_read' => true]);

        return response()->json([
            'data' => $message
        ]);
    }

    public function markAllAsRead(Request $request)
    {
        $institution = $request->attributes->get('institution');

        if ($institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        Message::where('institution_id', $institution->id)
            ->where('is_read', false)
            ->update(['is_read' => true]);

        return response()->json([
            'message' => 'All messages marked as read'
        ]);
    }
}
