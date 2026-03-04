<?php

namespace App\Http\Controllers;

use App\Services\Shared\AppResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;

class TestController extends Controller
{
    public function database()
    {
        $status = 'Connected';
        $version = 'Unknown';
        $error = null;

        try {
            DB::connection()->getPdo();
            $version = DB::select("SELECT VERSION() AS v")[0]->v ?? 'Unknown';
        }
        catch (\Exception $e) {
            $status = 'Disconnected';
            $error = $e->getMessage();
        }

        return Inertia::render('Test/Database', [
            'status' => $status,
            'version' => $version,
            'error' => $error,
        ]);
    }

    public function socket()
    {
        return Inertia::render('Test/Socket');
    }

    public function triggerSocket(Request $request)
    {
        // For testing we will just broadcast a generic status
        $userId = $request->user() ? $request->user()->id : 1; // Fallback to ID 1 if public
        \App\Events\NotificationUpdated::dispatch($userId, 999);

        return AppResponse::success('Socket event dispatched');
    }

    public function notification()
    {
        return Inertia::render('Test/Notification');
    }

    public function triggerNotification(Request $request, \App\Services\Notification\NotificationService $service)
    {
        $request->validate([
            'title' => 'required|string',
            'body' => 'required|string',
            'type' => 'nullable|string',
        ]);

        $userId = $request->user() ? $request->user()->id : 1; // Fallback to ID 1 if public
        $service->create($userId, [
            'type' => $request->input('type', 'info'),
            'title' => $request->input('title'),
            'body' => $request->input('body'),
        ]);

        return AppResponse::success([
            'message' => 'Notification triggered!',
        ]);
    }
}