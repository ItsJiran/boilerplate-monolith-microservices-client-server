<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureRole
{
    /**
     * Handle the incoming request by ensuring the current user has one of the specified role slugs.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @param  string  $slugs  Comma separated list of role slugs.
     * @param  string|null  $redirectRoute  Optional route name to redirect when validation fails.
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function handle(Request $request, Closure $next, string $slugs = '', ?string $redirectRoute = null): Response
    {
        if (!$user = $request->user()) {
            return $next($request);
        }

        $requiredSlugs = array_filter(array_map('trim', explode(',', $slugs)));
        if ($requiredSlugs === []) {
            return $next($request);
        }

        $hasAllowedRole = $user->hasRole($requiredSlugs);

        if ($hasAllowedRole) {
            return $next($request);
        }

        if ($redirectRoute !== null && route()->has($redirectRoute)) {
            return redirect()->route($redirectRoute);
        }

        abort(403, 'You do not have the required role to access this resource.');
    }
}