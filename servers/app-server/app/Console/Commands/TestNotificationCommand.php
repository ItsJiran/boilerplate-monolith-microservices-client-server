<?php

namespace App\Console\Commands;

use App\Models\User;
use App\Services\Notification\NotificationService;
use Illuminate\Console\Command;
use App\Models\Notification;

class TestNotificationCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'broadcast:notification {userId} {--title=Test Notification} {--body=This is a broadcast check.}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Generate a test Notification row and dispatch the NotificationCreated Reverb broadcast event for a user';

    /**
     * Execute the console command.
     */
    public function handle(NotificationService $notificationService)
    {
        $userId = $this->argument('userId');
        
        $user = User::find($userId);
        if (!$user) {
            $this->error("User with ID {$userId} not found.");
            return;
        }

        $this->info("Creating notification for User {$user->name}...");

        $notification = $notificationService->create($user->id, [
            'type' => 'info',
            'title' => $this->option('title'),
            'body' => $this->option('body'),
            'meta_json' => ['source' => 'artisan-command'],
            'tenant_id' => null, 
        ]);

        $this->info("Notification ID {$notification->id} created and broadcasted to user {$userId} successfully!");
    }
}
