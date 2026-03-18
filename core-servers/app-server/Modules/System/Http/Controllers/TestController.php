<?php

namespace Modules\System\Http\Controllers;

use Modules\System\Jobs\TestQueueJob;
use Modules\System\Models\SystemUser;
use Modules\System\Services\Shared\AppResponse;
use Illuminate\Foundation\Application;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;

class TestController extends Controller
{
    public function index()
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

        return Inertia::render('Test/Index', [
            'status' => $status,
            'version' => $version,
            'error' => $error,
            'laravelVersion' => Application::VERSION,
            'phpVersion' => PHP_VERSION,
        ]);
    }

    public function triggerSocket(Request $request)
    {
        // For testing we need a user id that actually exists to satisfy FK constraints.
        $userId = $this->resolveTestUserId($request);
        if (!$userId) {
            return AppResponse::error('No user found. Please register/login first before triggering socket test.', null, 422);
        }

        \App\Events\NotificationUpdated::dispatch($userId, 999);

        return AppResponse::success('Socket event dispatched');
    }

    public function migrate()
    {
        if (app()->isProduction()) {
            return AppResponse::error('Migration from Test Center is disabled in production.', null, 403);
        }

        try {
            Artisan::call('migrate', [
                '--force' => true,
            ]);

            return AppResponse::success('Migration completed successfully.');
        } catch (\Throwable $exception) {
            return AppResponse::error('Migration failed: ' . $exception->getMessage(), null, 500);
        }
    }

    public function triggerNotification(Request $request, \App\Services\Notification\NotificationService $service)
    {
        $request->validate([
            'title' => 'required|string',
            'body' => 'required|string',
            'type' => 'nullable|string',
        ]);

        $userId = $this->resolveTestUserId($request);
        if (!$userId) {
            return AppResponse::error('No user found. Please register/login first before triggering notification test.', null, 422);
        }

        $service->create($userId, [
            'type' => $request->input('type', 'info'),
            'title' => $request->input('title'),
            'body' => $request->input('body'),
        ]);

        return AppResponse::success([
            'message' => 'SystemNotification triggered!',
        ]);
    }

    public function triggerWorker()
    {
        if (app()->isProduction()) {
            return AppResponse::error('Queue worker test is disabled in production.', null, 403);
        }

        try {
            TestQueueJob::dispatch();

            return AppResponse::success('Test job dispatched to queue. If the worker is running, a socket broadcast on test-channel will be emitted shortly.');
        } catch (\Throwable $exception) {
            return AppResponse::error('Failed to dispatch test job: ' . $exception->getMessage(), null, 500);
        }
    }

    public function triggerCron()
    {
        if (app()->isProduction()) {
            return AppResponse::error('Cron test is disabled in production.', null, 403);
        }

        try {
            Artisan::call('schedule:run');
            $output = trim(Artisan::output()) ?: 'No scheduled tasks were due.';

            return AppResponse::success($output);
        } catch (\Throwable $exception) {
            return AppResponse::error('Failed to run schedule: ' . $exception->getMessage(), null, 500);
        }
    }

    private function resolveTestUserId(Request $request): ?int
    {
        if ($request->user()?->id) {
            return (int) $request->user()->id;
        }

        $firstUserId = SystemUser::query()->value('id');
        return $firstUserId ? (int) $firstUserId : null;
    }
}