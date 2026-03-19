import { createReverbEcho, createSocketClient } from '@repo/common/realtime';

function toNumber(input: string | undefined, fallback: number): number {
  const value = Number(input);
  return Number.isFinite(value) ? value : fallback;
}

export function connectReverb() {
  const key = import.meta.env.VITE_REVERB_APP_KEY;
  const host = import.meta.env.VITE_REVERB_HOST || window.location.hostname;
  const port = toNumber(import.meta.env.VITE_REVERB_PORT, 8080);

  if (!key) return null;

  return createReverbEcho({
    key,
    wsHost: host,
    wsPort: port,
    forceTLS: false,
  });
}

export function connectSocketIo() {
  const url = import.meta.env.VITE_SOCKET_IO_URL;
  if (!url) return null;

  return createSocketClient({
    url,
    transports: ['websocket'],
  });
}
