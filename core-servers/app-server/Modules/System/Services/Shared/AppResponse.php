<?php

namespace Modules\System\Services\Shared;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Inertia\Inertia;
use Inertia\Response as InertiaResponse;

class AppResponse
{
    /**
     * Handle sukses respon.
     * - API: Return JSON data.
     * - Web: Return Inertia Render ATAU Redirect dengan Flash Message.
     */
    public static function success(
        mixed $data = null, 
        string $message = 'Success', 
        ?string $view = null,      // Jika ingin render halaman (Inertia)
        ?string $route = null      // Jika ingin redirect (Inertia)
    ): JsonResponse|InertiaResponse|RedirectResponse
    {
        // 1. Jika Request adalah API (Mobile/Postman)
        if (request()->wantsJson()) {
            return response()->json([
                'success' => true,
                'message' => $message,
                'data'    => $data,
            ], 200);
        }

        // 2. Jika Request adalah Web (Inertia)
        
        // Kasus A: Redirect (Biasanya setelah Create/Update/Delete)
        if ($route) {
            return to_route($route, $data)->with('success', $message);
        }

        // Kasus B: Render Halaman (Biasanya Get/Index/Show)
        if ($view) {
            // Kita bisa attach extra data (flash message) jika perlu
            return Inertia::render($view, $data ?? []);
        }

        // Default fallback (jarang terjadi)
        return back()->with('success', $message);
    }

    /**
     * Handle error respon.
     */
    public static function error(
        string $message = 'Error', 
        mixed $details = null, 
        int $status = 500
    ): JsonResponse|RedirectResponse
    {
        // 1. API: Return JSON Error
        if (request()->wantsJson()) {
            return response()->json([
                'success' => false,
                'message' => $message,
                'error_code' => $details,
            ], $status);
        }

        // 2. Web: Redirect Back dengan Flash Error
        // Simpan di dua tempat:
        // - flash session 'error'  → terbaca di props.flash.error (untuk toast notifier)
        // - error bag 'message'    → terbaca di props.errors.message (untuk inline error di form)
        return back()
            ->with('error', $message)
            ->withErrors(['message' => $message]);
    }
}
