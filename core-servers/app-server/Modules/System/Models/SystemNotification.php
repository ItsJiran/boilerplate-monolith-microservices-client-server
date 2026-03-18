<?php

namespace Modules\System\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class SystemNotification extends Model
{
    use HasFactory;

    protected $fillable = [
        'type',
        'title',
        'body',
        'meta_json',
    ];

    protected $casts = [
        'meta_json' => 'array',
    ];

    public function users(): BelongsToMany
    {
        return $this->belongsToMany(SystemUser::class , 'system_notification_users')
            ->withPivot('read_at')
            ->withTimestamps();
    }

    public static function unreadCountForUser(int $userId): int
    {
        return DB::table('system_notification_users')
            ->where('user_id', $userId)
            ->whereNull('read_at')
            ->count();
    }

    public static function flushUserUnreadCount(int $userId): void
    {
        Cache::forget(self::cacheKeyForUser($userId));
    }

    public static function cacheKeyForUser(int $userId): string
    {
        return "notifications:user:{$userId}:unread";
    }
}