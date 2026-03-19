import Echo from 'laravel-echo';
import Pusher from 'pusher-js';
import { io, Socket } from 'socket.io-client';

export type ReverbConfig = {
  key: string;
  wsHost: string;
  wsPort: number;
  wssPort?: number;
  forceTLS?: boolean;
  enabledTransports?: Array<'ws' | 'wss'>;
};

export function createReverbEcho(config: ReverbConfig): Echo<'reverb'> {
  (globalThis as typeof globalThis & { Pusher?: typeof Pusher }).Pusher = Pusher;

  return new Echo({
    broadcaster: 'reverb',
    key: config.key,
    wsHost: config.wsHost,
    wsPort: config.wsPort,
    wssPort: config.wssPort,
    forceTLS: config.forceTLS ?? false,
    enabledTransports: config.enabledTransports ?? ['ws', 'wss'],
  });
}

export type SocketIoConfig = {
  url: string;
  path?: string;
  transports?: Array<'websocket' | 'polling'>;
  withCredentials?: boolean;
};

export function createSocketClient(config: SocketIoConfig): Socket {
  return io(config.url, {
    path: config.path,
    transports: config.transports ?? ['websocket'],
    withCredentials: config.withCredentials ?? true,
  });
}
