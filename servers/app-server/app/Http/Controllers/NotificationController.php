<?php

namespace App\Http\Controllers;

use App\Models\Notification;
use App\Services\Notification\NotificationService;
use App\Services\Shared\AppResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function __construct(
        protected NotificationService $notificationService
    ) {}

    public function index(Request $request)
    {
        $user = $request->user();
        $notifications = $this->notificationService->getUserNotifications($user);
        $unreadCount = $this->notificationService->getUnreadCount($user);

        return AppResponse::success(
            data: [
                'notifications' => $notifications,
                'unreadCount' => $unreadCount,
            ],
            view: 'Notifications/Index'
        );
    }

    public function markRead(Request $request, Notification $notification)
    {
        $user = $request->user();
        $this->notificationService->markAsRead($user, $notification);

        return AppResponse::success(
            message: 'Notifikasi diperbarui.'
        );
    }

    public function markAllRead(Request $request)
    {
        $user = $request->user();
        $this->notificationService->markAllAsRead($user);

        return AppResponse::success(
            message: 'Semua notifikasi sudah dibaca.'
        );
    }
}
