<?php

namespace App\Http\Controllers\Api\SuperAdmin;

use App\Http\Controllers\Controller;
use App\Models\SupportRequest;
use App\Models\SupportSession;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class SupportController extends Controller
{
    private function authorizeSuperAdmin(Request $request): void
    {
        $user = $request->user();
        if (!$user || !$user->can('platform-permission', 'super-admin')) {
            abort(403, 'Unauthorized');
        }
    }

    public function index(Request $request): JsonResponse
    {
        $this->authorizeSuperAdmin($request);
        
        $query = SupportRequest::with('institution', 'requester', 'approver');
        
        if ($request->input('status')) {
            $query->where('status', $request->input('status'));
        }
        
        if ($request->input('priority')) {
            $query->where('priority', $request->input('priority'));
        }
        
        if ($request->input('institution_id')) {
            $query->where('institution_id', $request->input('institution_id'));
        }

        $requests = $query->orderBy('created_at', 'desc')->paginate(20);
        
        return response()->json(['data' => $requests]);
    }

    public function store(Request $request): JsonResponse
    {
        $this->authorizeSuperAdmin($request);
        
        $attributes = $request->validate([
            'institution_id' => ['required', 'exists:institutions,id'],
            'subject' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'priority' => ['sometimes', 'in:low,medium,high,urgent'],
            'category' => ['nullable', 'string', 'max:100'],
            'requested_access' => ['sometimes', 'array'],
            'notes' => ['nullable', 'string'],
        ]);
        
        $attributes['requester_id'] = $request->user()->id;
        
        $supportRequest = SupportRequest::create($attributes);
        
        return response()->json(['data' => $supportRequest->load('institution', 'requester')], 201);
    }

    public function show(SupportRequest $supportRequest): JsonResponse
    {
        $this->authorizeSuperAdmin(request());
        
        return response()->json(['data' => $supportRequest->load('institution', 'requester', 'approver', 'sessions')]);
    }

    public function approve(Request $request, SupportRequest $supportRequest): JsonResponse
    {
        $this->authorizeSuperAdmin($request);
        
        $supportRequest->update([
            'status' => 'approved',
            'approver_id' => $request->user()->id,
            'approved_at' => now(),
        ]);
        
        return response()->json(['data' => $supportRequest->load('institution', 'requester', 'approver')]);
    }

    public function deny(Request $request, SupportRequest $supportRequest): JsonResponse
    {
        $this->authorizeSuperAdmin($request);
        
        $supportRequest->update([
            'status' => 'denied',
            'approver_id' => $request->user()->id,
            'denied_at' => now(),
        ]);
        
        return response()->json(['data' => $supportRequest->load('institution', 'requester', 'approver')]);
    }

    public function grantAccess(Request $request, SupportRequest $supportRequest): JsonResponse
    {
        $this->authorizeSuperAdmin($request);
        
        if ($supportRequest->status !== 'approved') {
            return response()->json(['message' => 'Support request must be approved first'], 422);
        }
        
        if ($supportRequest->resolved_at) {
            return response()->json(['message' => 'Support request has been resolved'], 422);
        }
        
        $session = SupportSession::create([
            'support_request_id' => $supportRequest->id,
            'accessor_id' => $request->user()->id,
            'session_token' => Str::random(64),
            'expires_at' => now()->addHours(2),
            'started_at' => now(),
            'status' => 'active',
        ]);
        
        return response()->json(['data' => $session], 201);
    }

    public function audit(SupportRequest $supportRequest): JsonResponse
    {
        $this->authorizeSuperAdmin(request());
        
        $auditLog = [];
        
        if ($supportRequest->created_at) {
            $auditLog[] = [
                'action' => 'created',
                'user_id' => $supportRequest->requester_id,
                'timestamp' => $supportRequest->created_at,
            ];
        }
        
        if ($supportRequest->approved_at) {
            $auditLog[] = [
                'action' => 'approved',
                'user_id' => $supportRequest->approver_id,
                'timestamp' => $supportRequest->approved_at,
            ];
        }
        
        $supportRequest->sessions()->each(function ($session) use (&$auditLog) {
            $auditLog[] = [
                'action' => 'access_granted',
                'user_id' => $session->accessor_id,
                'timestamp' => $session->started_at,
                'session_token' => $session->session_token,
            ];
            
            if ($session->ended_at) {
                $auditLog[] = [
                    'action' => 'access_ended',
                    'user_id' => $session->accessor_id,
                    'timestamp' => $session->ended_at,
                ];
            }
        });
        
        return response()->json(['data' => $auditLog]);
    }

    public function terminate(Request $request, SupportSession $session): JsonResponse
    {
        $this->authorizeSuperAdmin($request);
        
        $session->update([
            'ended_at' => now(),
            'status' => 'terminated',
        ]);
        
        return response()->json(['data' => $session]);
    }
}
