<?php

namespace App\Http\Middleware;

use App\Models\InstitutionMembership;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class ResolveTenantContext
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (! $user?->active_institution_id) {
            abort(403, 'An active institution membership is required.');
        }

        $membership = InstitutionMembership::query()
            ->with('institution')
            ->where('institution_id', $user->active_institution_id)
            ->where('user_id', $user->id)
            ->where('is_active', true)
            ->first();

        if (! $membership || ! $user->can('view', $membership->institution)) {
            abort(403, 'The active institution membership is unavailable.');
        }

        $request->attributes->set('institution', $membership->institution);
        $request->attributes->set('institution_membership', $membership);

        return $next($request);
    }
}
