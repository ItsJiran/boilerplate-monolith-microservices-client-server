<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Pusher\Pusher;

class ListActiveChannelsCommand extends Command
{
    /**
     * The name and signature of the console command.
     */
    protected $signature = 'broadcast:channels {--prefix= : Filter channels by prefix (e.g., presence-)}';

    /**
     * The console command description.
     */
    protected $description = 'List all currently active broadcast channels and their connected users';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        try {
            $key = config('broadcasting.connections.reverb.key') ?? env('REVERB_APP_KEY');
            $secret = config('broadcasting.connections.reverb.secret') ?? env('REVERB_APP_SECRET');
            $appId = config('broadcasting.connections.reverb.app_id') ?? env('REVERB_APP_ID');
            
            // FIX: Force the connection to use the internal Docker network.
            // We bypass Nginx entirely and talk container-to-container on HTTP.
            $host = env('REVERB_SERVER_HOST', 'reverb'); 
            $port = env('REVERB_SERVER_PORT', env('REVERB_PORT', 8080)); 
            $scheme = env('REVERB_SERVER_SCHEME', 'http'); 

            if (!$key || !$secret || !$appId) {
                $this->error('Reverb credentials missing. Please check your .env file.');
                return;
            }

            // Initialize Pusher with the internal Docker variables
            $pusher = new \Pusher\Pusher($key, $secret, $appId, [
                'host' => $host,
                'port' => $port,
                'scheme' => $scheme,
                'useTLS' => $scheme === 'https',
                'curl_options' => [
                    CURLOPT_SSL_VERIFYHOST => 0, 
                    CURLOPT_SSL_VERIFYPEER => 0,
                ]
            ]);



            $params = [];
            if ($prefix = $this->option('prefix')) {
                $params['filter_by_prefix'] = $prefix;
            }

            $this->info("Fetching active channels from internal Docker host: {$scheme}://{$host}:{$port}...");
            
            // Safe array casting (fixes the Reverb [] vs {} bug permanently)
            $response = $pusher->get('/channels', $params);
            $responseData = json_decode(json_encode($response), true);
            
            if (!is_array($responseData) || !isset($responseData['channels'])) {
                $this->error('Invalid response from websocket server.');
                return;
            }

            $channels = $responseData['channels'];

            if (empty($channels)) {
                $this->warn('No active channels currently opened.');
                return;
            }

            $this->info('Active Channels:');
            $this->newLine();
            
            foreach ($channels as $channelName => $channelInfo) {
                $this->line("<fg=green>- {$channelName}</>");
                
                // Fetch connected users for presence channels
                if (str_starts_with($channelName, 'presence-')) {
                    $usersResponse = $pusher->get('/channels/' . $channelName . '/users');
                    $usersData = json_decode(json_encode($usersResponse), true);
                    
                    if (isset($usersData['users']) && is_array($usersData['users']) && count($usersData['users']) > 0) {
                        $users = $usersData['users'];
                        $this->line("  <fg=gray>Users connected (" . count($users) . "):</>");
                        
                        foreach ($users as $user) {
                            $this->line("    <fg=cyan>- ID: {$user['id']}</>");
                        }
                    } else {
                        $this->line("  <fg=gray>Users connected (0)</>");
                    }
                }
            }

            $this->newLine();
            $this->info('Total active channels: ' . count($channels));

        } catch (\Exception $e) {
            $this->error('Failed to retrieve channels. Is your Reverb/Websocket server running?');
            $this->error('Error: ' . $e->getMessage());
        }
    }
}