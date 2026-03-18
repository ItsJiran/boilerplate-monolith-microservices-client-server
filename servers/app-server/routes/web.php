<?php

use App\Http\Controllers\Admin\TenantController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\SettingsController;
use App\Http\Controllers\UploadController;
use App\Http\Controllers\TestController;
use Illuminate\Foundation\Application;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
})->name('home');

// Example API Routes Here if needed

Route::middleware([
    'auth',
])->group(function () {

        Route::get('/dashboard', [DashboardController::class , 'index'])->name('dashboard');

        // TODO: Add generic feature routes here

        // Notifications
        Route::get('/notifications', [NotificationController::class , 'index'])->name('notifications.index');
        Route::patch('/notifications/{notification}/read', [NotificationController::class , 'markRead'])->name('notifications.read');
        Route::patch('/notifications/read-all', [NotificationController::class , 'markAllRead'])->name('notifications.read_all');

        // User Profile & Settings
        Route::get('/profile', [ProfileController::class , 'edit'])->name('profile.edit');
        Route::patch('/profile', [ProfileController::class , 'update'])->name('profile.update');
        Route::delete('/profile', [ProfileController::class , 'destroy'])->name('profile.destroy');
        Route::get('/settings', [SettingsController::class , 'index'])->name('settings');

    });

// Test Routes (made public)
Route::get('/test', [TestController::class , 'index'])->name('test.index');
Route::get('/test/db', fn (): RedirectResponse => redirect()->route('test.index'))->name('test.db');
Route::get('/test/socket', fn (): RedirectResponse => redirect()->route('test.index'))->name('test.socket');
Route::get('/test/trigger-socket', [TestController::class , 'triggerSocket'])->name('test.trigger_socket');
Route::get('/test/notification', fn (): RedirectResponse => redirect()->route('test.index'))->name('test.notification');
Route::post('/test/migrate', [TestController::class , 'migrate'])->name('test.migrate');
Route::post('/test/trigger-notification', [TestController::class , 'triggerNotification'])->name('test.trigger_notification');
Route::post('/test/trigger-worker', [TestController::class , 'triggerWorker'])->name('test.trigger_worker');
Route::post('/test/trigger-cron', [TestController::class , 'triggerCron'])->name('test.trigger_cron');


require __DIR__ . '/auth.php';