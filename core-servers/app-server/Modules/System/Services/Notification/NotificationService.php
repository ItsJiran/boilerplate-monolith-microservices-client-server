<?php

namespace Modules\System\Services\Notification;

use Modules\System\Models\SystemNotification;
use Modules\System\Models\SystemUser;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;

class NotificationService
{
    /**
     * Get paginated notifications for a user.
     */
    public function getUserNotifications(SystemUser $user, int $perPage = 10): LengthAwarePaginator
    {
        return SystemNotification::query()
            ->select('notifications.*', 'notification_user.read_at')
            ->join(
                'system_notification_users',
                'notifications.id',
                '=',
                'notification_user.notification_id',
            )
            ->where('notification_user.user_id', $user->id)
            ->orderByDesc('notifications.created_at')
            ->paginate($perPage)
            ->withQueryString()
            ->through(fn (SystemNotification $notification) => [
                'id' => $notification->id,
                'type' => $notification->type,
                'title' => $notification->title,
                'body' => $notification->body,
                'meta_json' => $notification->meta_json,
                'read_at' => $notification->read_at,
                'created_at' => $notification->created_at?->toDateTimeString(),
            ]);
    }

    /**
     * Get unread notification count for a user.
     */
    public function getUnreadCount(SystemUser $user): int
    {
        return SystemNotification::unreadCountForUser($user->id);
    }

    /**
     * Mark a notification as read for a user.
     */
    public function markAsRead(SystemUser $user, SystemNotification $notification): bool
    {
        $updated = DB::table('system_notification_users')
            ->where('user_id', $user->id)
            ->where('notification_id', $notification->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        if ($updated > 0) {
            SystemNotification::flushUserUnreadCount($user->id);
            
            // Broadcast the real-time update
            $unreadCount = SystemNotification::unreadCountForUser($user->id);
            \App\Events\NotificationUpdated::dispatch($user->id, $unreadCount);
            
            return true;
        }

        return false;
    }

    /**
     * Mark all notifications as read for a user.
     */
    public function markAllAsRead(SystemUser $user): int
    {
        $updated = DB::table('system_notification_users')
            ->where('user_id', $user->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        if ($updated > 0) {
            SystemNotification::flushUserUnreadCount($user->id);
            
            // Broadcast the real-time update (count is necessarily 0)
            \App\Events\NotificationUpdated::dispatch($user->id, 0);
        }


        return $updated;
    }

    /**
     * Create a notification, attach it to users, update cache, and dispatch event.
     *
     * @param int|array $userIds
     * @param array $data
     * @return SystemNotification
     */
    public function create(int|array $userIds, array $data): SystemNotification
    {
        $notification = SystemNotification::create([
            'type' => $data['type'] ?? 'info',
            'title' => $data['title'],
            'body' => $data['body'],
            'meta_json' => $data['meta_json'] ?? null,
            'tenant_id' => $data['tenant_id'] ?? null,
        ]);

        // Attach to user(s)
        $userIdsArray = (array) $userIds;
        $notification->users()->attach($userIdsArray);

        foreach ($userIdsArray as $userId) {
            // Update cache bootstrap
            SystemNotification::flushUserUnreadCount($userId);

            // Dispatch Event
            $unreadCount = SystemNotification::unreadCountForUser($userId);
            \App\Events\NotificationCreated::dispatch($userId, $notification, $unreadCount);
        }

        return $notification;
    }

}