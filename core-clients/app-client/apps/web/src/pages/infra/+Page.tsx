import React, { useEffect, useMemo, useState } from 'react';
import { connectReverb, connectSocketIo } from '@/lib/realtime';

type ConnectionState = 'idle' | 'connected' | 'error';

export function Page() {
  const [reverbState, setReverbState] = useState<ConnectionState>('idle');
  const [socketState, setSocketState] = useState<ConnectionState>('idle');

  useEffect(() => {
    const echo = connectReverb();
    const socket = connectSocketIo();

    if (echo) {
      setReverbState('connected');
    }

    if (socket) {
      socket.on('connect', () => setSocketState('connected'));
      socket.on('connect_error', () => setSocketState('error'));
    }

    return () => {
      echo?.disconnect();
      socket?.disconnect();
    };
  }, []);

  const queueUrl = useMemo(() => import.meta.env.VITE_QUEUE_DASHBOARD_URL || '/horizon', []);
  const schedulerUrl = useMemo(() => import.meta.env.VITE_SCHEDULER_DASHBOARD_URL || '/pulse', []);

  return (
    <div>
      <h1>Infrastructure Integrations</h1>
      <p>Connection bootstrap for realtime and quick links for queue/scheduler dashboards.</p>

      <h2>Realtime</h2>
      <ul>
        <li>Reverb/Echo: {reverbState}</li>
        <li>Socket.io: {socketState}</li>
      </ul>

      <h2>Dashboards</h2>
      <ul>
        <li>
          Queue Dashboard: <a href={queueUrl}>{queueUrl}</a>
        </li>
        <li>
          Scheduler Dashboard: <a href={schedulerUrl}>{schedulerUrl}</a>
        </li>
      </ul>
    </div>
  );
}
