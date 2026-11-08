<?php

namespace App\Http\Controllers\Api\SuperAdmin;

use App\Http\Controllers\Controller;
use App\Models\Institution;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class TenantController extends Controller
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
        
        $institutions = Institution::withCount('memberships')
            ->orderBy('created_at', 'desc')
            ->paginate(20);
            
        return response()->json(['data' => $institutions]);
    }

    public function activate(Request $request, string $id): JsonResponse
    {
        $this->authorizeSuperAdmin($request);
        
        $institution = Institution::findOrFail($id);
        $institution->update(['status' => 'active']);
        
        Log::info('Institution activated', [
            'institution_id' => $id,
            'activated_by' => $request->user()->id,
        ]);
        
        return response()->json(['data' => $institution]);
    }

    public function suspend(Request $request, string $id): JsonResponse
    {
        $this->authorizeSuperAdmin($request);
        
        $institution = Institution::findOrFail($id);
        $institution->update(['status' => 'suspended']);
        
        Log::info('Institution suspended', [
            'institution_id' => $id,
            'suspended_by' => $request->user()->id,
        ]);
        
        return response()->json(['data' => $institution]);
    }

    public function reactivate(Request $request, string $id): JsonResponse
    {
        $this->authorizeSuperAdmin($request);
        
        $institution = Institution::findOrFail($id);
        $institution->update(['status' => 'active']);
        
        Log::info('Institution reactivated', [
            'institution_id' => $id,
            'reactivated_by' => $request->user()->id,
        ]);
        
        return response()->json(['data' => $institution]);
    }

    public function archive(Request $request, string $id): JsonResponse
    {
        $this->authorizeSuperAdmin($request);
        
        $institution = Institution::findOrFail($id);
        $institution->update(['status' => 'archived', 'archived_at' => now()]);
        
        Log::info('Institution archived', [
            'institution_id' => $id,
            'archived_by' => $request->user()->id,
        ]);
        
        return response()->json(['data' => $institution]);
    }

    public function restore(Request $request, string $id): JsonResponse
    {
        $this->authorizeSuperAdmin($request);
        
        $institution = Institution::findOrFail($id);
        $institution->update(['status' => 'active', 'archived_at' => null]);
        
        Log::info('Institution restored', [
            'institution_id' => $id,
            'restored_by' => $request->user()->id,
        ]);
        
        return response()->json(['data' => $institution]);
    }
}
