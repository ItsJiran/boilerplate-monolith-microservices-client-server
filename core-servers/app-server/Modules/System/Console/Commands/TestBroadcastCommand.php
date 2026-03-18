<?php

namespace Modules\System\Console\Commands;

use Modules\System\Events\TestBroadcastEvent;
use Illuminate\Console\Command;

class TestBroadcastCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'broadcast:test {message=Hello} {--channel=test-channel}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Dispatch a test broadcast event to a specific channel';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $message = $this->argument('message');
        $channel = $this->option('channel');

        $this->info("Broadcasting message '{$message}' to channel '{$channel}'...");

        TestBroadcastEvent::dispatch($message, $channel);

        $this->info("Broadcast sent successfully!");
    }
}
