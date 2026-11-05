<?php

namespace App\Http\Middleware;

use App\Services\SessionService;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;

class AuthenticateApiSession
{
    public function __construct(private SessionService $sessions) {}

    /**
     * Handle an incoming request.
     *
     * @param  Closure(Request): (Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $session = $this->sessions->authenticateAccessToken($request->bearerToken());

        if (! $session) {
            return new JsonResponse(['message' => 'Unauthenticated.'], Response::HTTP_UNAUTHORIZED);
        }

        $request->attributes->set('api_session', $session);
        $request->setUserResolver(fn () => $session->user);

        return $next($request);
    }
}
