<?php

namespace Modules\System\Jobs;

use Modules\System\Events\TestBroadcastEvent;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;

class TestQueueJob implements ShouldQueue
{
    use Queueable;

    public function __construct(public readonly string $message = 'Queue worker is operational!')
    {
    }

    public function handle(): void
    {
        TestBroadcastEvent::dispatch($this->message, 'test-channel');
    }
}
