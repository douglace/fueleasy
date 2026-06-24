<?php

declare(strict_types=1);

namespace App\Http\Middleware;

use App\Models\DeviceSession;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Symfony\Component\HttpFoundation\Response;

/**
 * Authentifie une requête API mobile via un jeton de session d'appareil (Bearer).
 */
class AuthenticateMobile
{
    public function handle(Request $request, Closure $next): Response
    {
        $token = $request->bearerToken();

        if ($token === null) {
            return response()->json(['message' => 'Non authentifié.'], 401);
        }

        $session = DeviceSession::query()
            ->where('token_hash', hash('sha256', $token))
            ->whereNull('revoked_at')
            ->first();

        if ($session === null) {
            return response()->json(['message' => 'Session invalide ou révoquée.'], 401);
        }

        $user = $session->user;
        if (! $user->isActive()) {
            return response()->json(['message' => 'Compte indisponible.'], 401);
        }

        $session->forceFill(['last_used_at' => Carbon::now()])->save();

        $request->setUserResolver(fn () => $user);
        $request->attributes->set('device_session', $session);

        return $next($request);
    }
}
