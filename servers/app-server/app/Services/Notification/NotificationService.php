<?php

namespace App\Services\Notification;

use App\Models\Notification;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;

class NotificationService
{
    /**
     * Get paginated notifications for a user.
     */
    public function getUserNotifications(User $user, int $perPage = 10): LengthAwarePaginator
    {
        return Notification::query()
            ->select('notifications.*', 'notification_user.read_at')
            ->join(
                'notification_user',
                'notifications.id',
                '=',
                'notification_user.notification_id',
            )
            ->where('notification_user.user_id', $user->id)
            ->orderByDesc('notifications.created_at')
            ->paginate($perPage)
            ->withQueryString()
            ->through(fn (Notification $notification) => [
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
    public function getUnreadCount(User $user): int
    {
        return Notification::unreadCountForUser($user->id);
    }

    /**
     * Mark a notification as read for a user.
     */
    public function markAsRead(User $user, Notification $notification): bool
    {
        $updated = DB::table('notification_user')
            ->where('user_id', $user->id)
            ->where('notification_id', $notification->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        if ($updated > 0) {
            Notification::flushUserUnreadCount($user->id);
            
            // Broadcast the real-time update
            $unreadCount = Notification::unreadCountForUser($user->id);
            \App\Events\NotificationUpdated::dispatch($user->id, $unreadCount);
            
            return true;
        }

        return false;
    }

    /**
     * Mark all notifications as read for a user.
     */
    public function markAllAsRead(User $user): int
    {
        $updated = DB::table('notification_user')
            ->where('user_id', $user->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        if ($updated > 0) {
            Notification::flushUserUnreadCount($user->id);
            
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
     * @return Notification
     */
    public function create(int|array $userIds, array $data): Notification
    {
        $notification = Notification::create([
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
            Notification::flushUserUnreadCount($userId);

            // Dispatch Event
            $unreadCount = Notification::unreadCountForUser($userId);
            \App\Events\NotificationCreated::dispatch($userId, $notification, $unreadCount);
        }

        return $notification;
    }

}