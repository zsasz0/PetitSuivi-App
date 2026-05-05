<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class RoleMiddleware
{
    /**
     * Handle an incoming request.
     *
     * Checks if the authenticated user has the required role.
     * Role mapping: 1 = teacher, 2 = admin, 3 = parent
     *
     * @param Request $request
     * @param Closure $next
     * @param string $role The required role name (admin, teacher, parent)
     * @return Response
     */
    public function handle(Request $request, Closure $next, string $role): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated.'
            ], 401);
        }

        $roleMap = [
            'admin' => 2,
            'teacher' => 1,
            'parent' => 3,
        ];

        $allowedRoles = $roleMap[$role] ?? null;

        if ($allowedRoles === null) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid role specified.'
            ], 403);
        }

        $userRoleId = (int) $user->RoleID;

        // Admin (RoleID 2) can access everything
        if ($userRoleId === 2) {
            return $next($request);
        }

        if (is_array($allowedRoles)) {
            if (!in_array($userRoleId, $allowedRoles)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Accès refusé. Rôle insuffisant.'
                ], 403);
            }
        } else {
            if ($userRoleId !== $allowedRoles) {
                return response()->json([
                    'success' => false,
                    'message' => 'Accès refusé. Rôle insuffisant.'
                ], 403);
            }
        }

        return $next($request);
    }
}
