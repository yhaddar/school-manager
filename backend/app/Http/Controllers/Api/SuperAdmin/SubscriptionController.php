<?php

namespace App\Http\Controllers\Api\SuperAdmin;

use App\Http\Controllers\Controller;
use App\Models\SubscriptionPlan;
use App\Models\InstitutionSubscription;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SubscriptionController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $this->authorizeSuperAdmin($request);
        $plans = SubscriptionPlan::where('is_active', true)->orderBy('created_at', 'desc')->get();
        return response()->json(['data' => $plans]);
    }

    public function store(Request $request): JsonResponse
    {
        $this->authorizeSuperAdmin($request);
        $attributes = $request->validate([
            'name' => ['required', 'string', 'max:255', 'unique:subscription_plans'],
            'tier' => ['required', 'in:basic,professional,enterprise'],
            'features' => ['sometimes', 'array'],
            'storage_limit_gb' => ['sometimes', 'integer', 'min:0'],
            'user_limit' => ['nullable', 'integer', 'min:1'],
            'api_rate_limit' => ['nullable', 'integer', 'min:1'],
            'price_monthly' => ['sometimes', 'numeric', 'min:0'],
            'price_yearly' => ['sometimes', 'numeric', 'min:0'],
        ]);
        $attributes['created_by'] = $request->user()->id;
        $plan = SubscriptionPlan::create($attributes);
        return response()->json(['data' => $plan], 201);
    }

    public function show(SubscriptionPlan $plan): JsonResponse
    {
        $this->authorizeSuperAdmin(request());
        return response()->json(['data' => $plan]);
    }

    public function update(Request $request, SubscriptionPlan $plan): JsonResponse
    {
        $this->authorizeSuperAdmin($request);
        $attributes = $request->validate([
            'name' => ['sometimes', 'string', 'max:255', 'unique:subscription_plans,name,' . $plan->id],
            'tier' => ['sometimes', 'in:basic,professional,enterprise'],
            'features' => ['sometimes', 'array'],
            'storage_limit_gb' => ['sometimes', 'integer', 'min:0'],
            'user_limit' => ['nullable', 'integer', 'min:1'],
            'api_rate_limit' => ['nullable', 'integer', 'min:1'],
            'price_monthly' => ['sometimes', 'numeric', 'min:0'],
            'price_yearly' => ['sometimes', 'numeric', 'min:0'],
            'is_active' => ['sometimes', 'boolean'],
        ]);
        $plan->update($attributes);
        return response()->json(['data' => $plan]);
    }

    public function destroy(SubscriptionPlan $plan): JsonResponse
    {
        $this->authorizeSuperAdmin(request());
        if ($plan->institutionSubscriptions()->exists()) {
            return response()->json(['message' => 'Cannot delete plan assigned to institutions'], 422);
        }
        $plan->delete();
        return response()->json(null, 204);
    }

    public function assignToInstitution(Request $request, string $institutionId): JsonResponse
    {
        $this->authorizeSuperAdmin($request);
        $attributes = $request->validate([
            'plan_id' => ['required', 'exists:subscription_plans,id'],
            'start_date' => ['required', 'date'],
            'end_date' => ['required', 'date', 'after:start_date'],
            'billing_cycle' => ['sometimes', 'in:monthly,yearly'],
        ]);
        $subscription = InstitutionSubscription::updateOrCreate(
            ['institution_id' => $institutionId],
            array_merge($attributes, [
                'status' => 'active',
                'billing_cycle' => $attributes['billing_cycle'] ?? 'yearly'
            ])
        );
        return response()->json(['data' => $subscription->load('plan')], 201);
    }

    public function renew(Request $request, string $institutionId): JsonResponse
    {
        $this->authorizeSuperAdmin($request);
        $attributes = $request->validate([
            'new_end_date' => ['required', 'date', 'after:today'],
            'notes' => ['sometimes', 'string'],
        ]);
        $subscription = InstitutionSubscription::where('institution_id', $institutionId)->firstOrFail();
        $subscription->update([
            'end_date' => $attributes['new_end_date'],
            'status' => 'active',
        ]);
        return response()->json(['data' => $subscription->load('plan')]);
    }

    public function history(string $institutionId): JsonResponse
    {
        $this->authorizeSuperAdmin(request());
        $subscription = InstitutionSubscription::where('institution_id', $institutionId)->firstOrFail();
        return response()->json(['data' => [
            'subscription' => $subscription,
            'plan' => $subscription->plan,
        ]]);
    }

    public function listSubscriptions(Request $request): JsonResponse
    {
        $this->authorizeSuperAdmin($request);
        $query = InstitutionSubscription::with('institution', 'plan');
        if ($request->input('status')) {
            $query->where('status', $request->input('status'));
        }
        $subscriptions = $query->orderBy('created_at', 'desc')->paginate(20);
        return response()->json(['data' => $subscriptions]);
    }

    private function authorizeSuperAdmin(Request $request): void
    {
        $user = $request->user();
        if (!$user || !$user->can('platform-permission', 'super-admin')) {
            abort(403, 'Unauthorized');
        }
    }
}
