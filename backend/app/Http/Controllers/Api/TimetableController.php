<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Controller as ApiController;
use App\Models\Timetable;
use App\Models\ClassModel;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TimetableController extends ApiController
{
    public function index(Request $request): \Illuminate\Http\JsonResponse
    {
        $request->validate([
            'class_id' => 'sometimes|exists:classes,id',
            'teacher_id' => 'sometimes|exists:users,id',
            'day_of_week' => 'sometimes|string',
        ]);

        $query = Timetable::query()
            ->where('institution_id', $request->user()->active_institution_id)
            ->with(['room', 'course.subject', 'teacher']);

        if ($request->has('class_id')) {
            $query->where('class_id', $request->class_id);
        }

        if ($request->has('teacher_id')) {
            $query->where('teacher_id', $request->teacher_id);
        }

        if ($request->has('day_of_week')) {
            $query->where('day_of_week', $request->day_of_week);
        }

        return response()->json(['data' => $query->orderBy('day_of_week')
            ->orderBy('start_time')->get()]);
    }

    public function store(Request $request): \Illuminate\Http\JsonResponse
    {
        $validated = $request->validate([
            'class_id' => 'required|exists:classes,id',
            'room_id' => 'nullable|exists:rooms,id',
            'course_id' => 'required|exists:courses,id',
            'teacher_id' => 'nullable|exists:users,id',
            'start_time' => 'required|date_format:H:i',
            'end_time' => 'required|date_format:H:i',
            'sequence' => 'required|integer',
            'day_of_week' => 'required|string|in:monday,tuesday,wednesday,thursday,friday, saturday,sunday',
        ]);

        $validated['institution_id'] = $request->user()->active_institution_id;

        // Check for conflicts
        $conflict = Timetable::where('institution_id', $validated['institution_id'])
            ->where(function ($q) use ($validated) {
                // Room conflict
                if ($validated['room_id']) {
                    $q->where('room_id', $validated['room_id'])
                        ->where(function ($q2) use ($validated) {
                            $q2->where(function ($q3) use ($validated) {
                                $q3->where('start_time', '<', $validated['end_time'])
                                    ->where('end_time', '>', $validated['start_time']);
                            })
                            ->orWhere(function ($q3) use ($validated) {
                                $q3->where('start_time', '=', $validated['start_time'])
                                    ->where('end_time', '=', $validated['end_time']);
                            });
                        });
                }

                // Class conflict
                $q->orWhere(function ($q2) use ($validated) {
                    $q2->where('class_id', $validated['class_id'])
                        ->where(function ($q3) use ($validated) {
                            $q3->where(function ($q4) use ($validated) {
                                $q4->where('start_time', '<', $validated['end_time'])
                                    ->where('end_time', '>', $validated['start_time']);
                            })
                            ->orWhere(function ($q4) use ($validated) {
                                $q4->where('start_time', '=', $validated['start_time'])
                                    ->where('end_time', '=', $validated['end_time']);
                            });
                        });
                });

                // Teacher conflict (only if teacher_id is provided)
                if (isset($validated['teacher_id']) && $validated['teacher_id']) {
                    $q->orWhere(function ($q2) use ($validated) {
                        $q2->where('teacher_id', $validated['teacher_id'])
                            ->where(function ($q3) use ($validated) {
                                $q3->where(function ($q4) use ($validated) {
                                    $q4->where('start_time', '<', $validated['end_time'])
                                        ->where('end_time', '>', $validated['start_time']);
                                })
                                ->orWhere(function ($q4) use ($validated) {
                                    $q4->where('start_time', '=', $validated['start_time'])
                                        ->where('end_time', '=', $validated['end_time']);
                                });
                            });
                    });
                }
            })
            ->where('day_of_week', $validated['day_of_week'])
            ->exists();

        if ($conflict) {
            return response()->json(['message' => 'Scheduling conflict detected'], 409);
        }

        $timetable = DB::transaction(function () use ($validated) {
            return Timetable::create($validated);
        });

        return response()->json(['data' => $timetable->load(['room', 'course.subject', 'teacher'])], 201);
    }

    public function show(Request $request, Timetable $timetable): \Illuminate\Http\JsonResponse
    {
        if ($timetable->institution_id !== $request->user()->active_institution_id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        return response()->json(['data' => $timetable->load(['room', 'course.subject', 'teacher'])]);
    }

    public function destroy(Request $request, Timetable $timetable): \Illuminate\Http\JsonResponse
    {
        if ($timetable->institution_id !== $request->user()->active_institution_id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $timetable->delete();

        return response()->json(status: 204);
    }
}
