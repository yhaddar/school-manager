<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AcademicPeriod;
use App\Models\AcademicYear;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AcademicPeriodController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $institution = $request->attributes->get('institution');

        if ($user === null || $institution === null) {
            return response()->json(['message' => 'Valid request context required.'], 403);
        }

        $academicYearId = $request->query('academic_year_id');

        $query = AcademicPeriod::query()
            ->where('institution_id', $institution->id);

        if ($academicYearId) {
            $query->where('academic_year_id', $academicYearId);
        }

        $periods = $query->orderBy('sequence')
            ->get()
            ->map(fn (AcademicPeriod $period): array => [
                'id' => $period->id,
                'academic_year_id' => $period->academic_year_id,
                'name' => $period->name,
                'type' => $period->type,
                'sequence' => $period->sequence,
                'starts_at' => $period->starts_at->toDateString(),
                'ends_at' => $period->ends_at->toDateString(),
                'is_grading_period' => $period->is_grading_period,
            ]);

        return response()->json(['data' => $periods]);
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
            'academic_year_id' => ['required', 'string', 'exists:academic_years,id'],
            'name' => ['required', 'string', 'max:255'],
            'type' => ['required', 'string', 'in:semester,trimester,quarter,custom'],
            'sequence' => ['required', 'integer', 'min:1'],
            'starts_at' => ['required', 'date'],
            'ends_at' => ['required', 'date', 'after:starts_at'],
            'is_grading_period' => ['boolean'],
        ]);

        $academicYear = AcademicYear::query()
            ->where('id', $attributes['academic_year_id'])
            ->where('institution_id', $institution->id)
            ->first();

        if ($academicYear === null) {
            return response()->json(['message' => 'Academic year not found or not in this institution.'], 404);
        }

        // Update sequence to fill gaps
        $existingSequence = AcademicPeriod::query()
            ->where('academic_year_id', $attributes['academic_year_id'])
            ->max('sequence');

        if ($existingSequence && $existingSequence >= $attributes['sequence']) {
            AcademicPeriod::query()
                ->where('academic_year_id', $attributes['academic_year_id'])
                ->where('sequence', '>=', $attributes['sequence'])
                ->increment('sequence');
        }

        $period = AcademicPeriod::query()->create([
            'institution_id' => $institution->id,
            'academic_year_id' => $attributes['academic_year_id'],
            'name' => $attributes['name'],
            'type' => $attributes['type'],
            'sequence' => $attributes['sequence'],
            'starts_at' => $attributes['starts_at'],
            'ends_at' => $attributes['ends_at'],
            'is_grading_period' => $attributes['is_grading_period'] ?? true,
        ]);

        return response()->json([
            'data' => [
                'id' => $period->id,
                'academic_year_id' => $period->academic_year_id,
                'name' => $period->name,
                'type' => $period->type,
                'sequence' => $period->sequence,
                'starts_at' => $period->starts_at->toDateString(),
                'ends_at' => $period->ends_at->toDateString(),
                'is_grading_period' => $period->is_grading_period,
            ],
        ], 201);
    }
}
