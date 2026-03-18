<?php

namespace Modules\System\Console\Commands;

use Modules\System\Models\SystemUser;
use Modules\System\Services\Notification\NotificationService;
use Illuminate\Console\Command;
use Modules\System\Models\SystemNotification;

class TestNotificationCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'broadcast:notification {userId} {--title=Test SystemNotification} {--body=This is a broadcast check.}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Generate a test SystemNotification row and dispatch the NotificationCreated Reverb broadcast event for a user';

    /**
     * Execute the console command.
     */
    public function handle(NotificationService $notificationService)
    {
        $userId = $this->argument('userId');
        
        $user = SystemUser::find($userId);
        if (!$user) {
            $this->error("SystemUser with ID {$userId} not found.");
            return;
        }

        $this->info("Creating notification for SystemUser {$user->name}...");

        $notification = $notificationService->create($user->id, [
            'type' => 'info',
            'title' => $this->option('title'),
            'body' => $this->option('body'),
            'meta_json' => ['source' => 'artisan-command'],
            'tenant_id' => null, 
        ]);

        $this->info("SystemNotification ID {$notification->id} created and broadcasted to user {$userId} successfully!");
    }
}
