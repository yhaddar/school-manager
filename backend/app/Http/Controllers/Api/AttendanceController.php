<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AttendanceController extends Controller
{
    public function index(Request $request): \Illuminate\Http\JsonResponse
    {
        $request->validate([
            'date' => 'sometimes|date',
            'status' => 'sometimes|in:present,absent,late,excused',
            'student_id' => 'sometimes|exists:users,id',
        ]);

        $query = Attendance::query()
            ->where('institution_id', $request->user()->active_institution_id)
            ->with(['enrollment.student', 'timetable.course.subject']);

        if ($request->has('date')) {
            $dateValue = $request->input('date');
            if ($dateValue instanceof \DateTimeInterface) {
                $dateValue = $dateValue->format('Y-m-d');
            }
            $query->whereDate('date', $dateValue);
        }

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        if ($request->has('student_id')) {
            $query->whereHas('enrollment', function ($q) use ($request) {
                $q->where('student_id', $request->student_id);
            });
        }

        return response()->json(['data' => $query->orderBy('date', 'desc')->get()]);
    }

    public function store(Request $request): \Illuminate\Http\JsonResponse
    {
        $validated = $request->validate([
            'enrollment_id' => 'required|exists:enrollments,id',
            'date' => 'required|date',
            'status' => 'required|in:present,absent,late,excused',
            'check_in_time' => 'nullable|date_format:H:i',
            'check_out_time' => 'nullable|date_format:H:i',
            'is_justified' => 'boolean',
            'justification' => 'nullable|string',
        ]);

        $validated['institution_id'] = $request->user()->active_institution_id;

        $attendance = DB::transaction(function () use ($validated) {
            return Attendance::create($validated);
        });

        return response()->json(['data' => $attendance], 201);
    }

    public function update(Request $request, Attendance $attendance): \Illuminate\Http\JsonResponse
    {
        if ($attendance->institution_id !== $request->user()->active_institution_id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $validated = $request->validate([
            'status' => 'sometimes|in:present,absent,late,excused',
            'check_in_time' => 'nullable|date_format:H:i',
            'check_out_time' => 'nullable|date_format:H:i',
            'justification' => 'nullable|string',
        ]);

        $attendance->update($validated);

        return response()->json(['data' => $attendance]);
    }

    public function destroy(Request $request, Attendance $attendance): \Illuminate\Http\JsonResponse
    {
        if ($attendance->institution_id !== $request->user()->active_institution_id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $attendance->delete();

        return response()->json(status: 204);
    }
}
