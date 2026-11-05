<?php

use App\Http\Controllers\Api\AuthSessionController;
use App\Http\Middleware\AuthenticateApiSession;
use App\Http\Middleware\ResolveTenantContext;
use App\Models\Institution;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function (): void {
    Route::get('health', fn () => response()->json(['data' => ['status' => 'ok']]));

    Route::post('auth/sessions', [AuthSessionController::class, 'store']);
    Route::post('auth/sessions/refresh', [AuthSessionController::class, 'refresh']);

    Route::middleware(AuthenticateApiSession::class)->group(function (): void {
        Route::delete('auth/sessions/current', [AuthSessionController::class, 'destroy']);

        Route::middleware(ResolveTenantContext::class)->get('tenant-context', function () {
            /** @var Institution $institution */
            $institution = request()->attributes->get('institution');

            return response()->json(['data' => ['institution_id' => $institution->id]]);
        });
    });
});
