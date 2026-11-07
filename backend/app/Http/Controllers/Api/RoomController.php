<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Room;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class RoomController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $type = $request->query('type');

        $query = Room::query()
            ->where('institution_id', $institution->id)
            ->where('is_active', true);

        if ($type) {
            $query->where('type', $type);
        }

        $rooms = $query->get()
            ->map(fn (Room $room): array => [
                'id' => $room->id,
                'name' => $room->name,
                'code' => $room->code,
                'type' => $room->type,
                'capacity' => $room->capacity,
                'equipment' => $room->equipment,
            ]);

        return response()->json(['data' => $rooms]);
    }

    public function store(Request $request): JsonResponse
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        abort_unless($user->can('institution-permission', 'institution.manage'), 403);

        $attributes = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'code' => ['nullable', 'string', 'max:32'],
            'type' => ['required', 'string', 'in:classroom,lab,gym,auditorium,office,other'],
            'capacity' => ['integer', 'min:1', 'max:200'],
            'equipment' => ['nullable', 'array'],
        ]);

        $room = Room::query()->create([
            'institution_id' => $institution->id,
            'name' => $attributes['name'],
            'code' => $attributes['code'] ?? Str::upper(Str::slug($attributes['name'], '_')),
            'type' => $attributes['type'],
            'capacity' => $attributes['capacity'] ?? 30,
            'equipment' => $attributes['equipment'] ?? [],
        ]);

        return response()->json([
            'data' => [
                'id' => $room->id,
                'name' => $room->name,
                'code' => $room->code,
                'type' => $room->type,
                'capacity' => $room->capacity,
            ],
        ], 201);
    }
}
