<?php

namespace Tests\Integration\Services;


use Illuminate\Support\Facades\Broadcast;
use Illuminate\Support\Facades\Event;
use Tests\TestCase;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\PrivateChannel;

// A simple test event class to avoid dependency complexity
class TestIntegrationEvent implements ShouldBroadcast
{
    public $message;

    public function __construct($message)
    {
        $this->message = $message;
    }

    public function broadcastOn()
    {
        return new PrivateChannel('test-integration-channel');
    }
}

class ReverbIntegrationTest extends TestCase
{
    /** @test */
    public function it_can_broadcast_event_to_reverb_server()
    {
        // 1. Verify Config
        $this->assertEquals('reverb', config('broadcasting.default'));

        // 2. Dispatch Broadcast
        // We use a try-catch block to verify it implies a network call
        try {
            $event = new TestIntegrationEvent("Hello Reverb " . time());
            
            // This helper broadcasts the event using the default driver (reverb)
            // It triggers the HTTP call to the Reverb Server
            broadcast($event); 
            
            $this->assertTrue(true); // If no exception, it worked (backend side)
        } catch (\Exception $e) {
            $this->fail("Broadcasting to Reverb failed: " . $e->getMessage());
        }
    }
}
