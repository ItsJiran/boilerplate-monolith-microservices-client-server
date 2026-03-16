import React, { useState } from 'react';
import { Head, Link, usePage } from '@inertiajs/react';
import axios from 'axios';
import useAppBroadcast from '@/Hooks/useAppBroadcast';

export default function TestCenter({ status, version, error, laravelVersion, phpVersion }) {
    const { auth } = usePage().props;
    const { isConnected } = useAppBroadcast();

    const [notificationForm, setNotificationForm] = useState({
        title: 'Test Notification',
        body: 'This is a test notification generated from the boilerplate.',
        type: 'info',
    });
    const [resultMessage, setResultMessage] = useState(null);
    const [isMigrating, setIsMigrating] = useState(false);
    const [isDispatchingJob, setIsDispatchingJob] = useState(false);
    const [isRunningCron, setIsRunningCron] = useState(false);

    const triggerWorkerJob = async () => {
        setResultMessage(null);
        setIsDispatchingJob(true);
        try {
            const response = await axios.post(route('test.trigger_worker'));
            setResultMessage({ status: 'success', message: response?.data?.message ?? 'Job dispatched.' });
        } catch (requestError) {
            setResultMessage({ status: 'error', message: requestError?.response?.data?.message ?? 'Failed to dispatch job.' });
        } finally {
            setIsDispatchingJob(false);
        }
    };

    const triggerCronRun = async () => {
        setResultMessage(null);
        setIsRunningCron(true);
        try {
            const response = await axios.post(route('test.trigger_cron'));
            setResultMessage({ status: 'success', message: response?.data?.message ?? 'Schedule run completed.' });
        } catch (requestError) {
            setResultMessage({ status: 'error', message: requestError?.response?.data?.message ?? 'Failed to run schedule.' });
        } finally {
            setIsRunningCron(false);
        }
    };

    const runMigration = async () => {
        setResultMessage(null);
        setIsMigrating(true);

        try {
            const response = await axios.post(route('test.migrate'));
            setResultMessage({
                status: 'success',
                message: response?.data?.message ?? 'Migration completed successfully.',
            });
        } catch (requestError) {
            setResultMessage({
                status: 'error',
                message: requestError?.response?.data?.message ?? 'Migration failed.',
            });
        } finally {
            setIsMigrating(false);
        }
    };

    const triggerSocketEvent = async () => {
        setResultMessage(null);
        try {
            const response = await axios.get(route('test.trigger_socket'));
            setResultMessage({
                status: 'success',
                message: response?.data?.message ?? 'Socket event dispatched.',
            });
        } catch (requestError) {
            setResultMessage({
                status: 'error',
                message: requestError?.response?.data?.message ?? 'Failed to trigger socket event.',
            });
        }
    };

    const triggerNotificationEvent = async (event) => {
        event.preventDefault();
        setResultMessage(null);

        try {
            const response = await axios.post(route('test.trigger_notification'), notificationForm);
            setResultMessage({
                status: 'success',
                message: response?.data?.message ?? 'Notification triggered.',
            });
        } catch (requestError) {
            setResultMessage({
                status: 'error',
                message: requestError?.response?.data?.message ?? 'Failed to trigger notification event.',
            });
        }
    };

    return (
        <>
            <Head title="Test Center | AT-Monolith" />
            <div className="font-sans antialiased bg-white text-slate-800 selection:bg-indigo-100 selection:text-indigo-900 min-h-screen">
                <header className="fixed w-full z-50 bg-white/80 backdrop-blur-md border-b border-slate-100">
                    <div className="max-w-7xl mx-auto px-6 lg:px-8 py-4">
                        <div className="flex items-center justify-between">
                            <div className="flex items-center gap-3">
                                <div className="w-10 h-10 bg-indigo-600 rounded-lg flex items-center justify-center shadow-lg shadow-indigo-200">
                                    <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
                                    </svg>
                                </div>
                                <div>
                                    <h1 className="text-xl font-bold text-slate-900 tracking-tight">AT-Monolith</h1>
                                    <p className="text-xs text-indigo-600 font-medium tracking-wide">Integrated Test Center</p>
                                </div>
                            </div>

                            <nav className="flex items-center gap-3 text-sm font-medium">
                                <Link href={route('home')} className="text-slate-600 hover:text-indigo-600 transition-colors">
                                    Home
                                </Link>
                                {auth?.user ? (
                                    <Link
                                        href={route('dashboard')}
                                        className="inline-flex justify-center items-center rounded-md bg-indigo-600 px-4 py-2 text-white hover:bg-indigo-700 transition-all"
                                    >
                                        Dashboard
                                    </Link>
                                ) : (
                                    <Link
                                        href={route('login')}
                                        className="inline-flex justify-center items-center rounded-md bg-slate-900 px-4 py-2 text-white hover:bg-slate-800 transition-all"
                                    >
                                        Log in
                                    </Link>
                                )}
                            </nav>
                        </div>
                    </div>
                </header>

                <main className="relative isolate pt-28 pb-20">
                    <div className="absolute inset-x-0 -top-40 -z-10 transform-gpu overflow-hidden blur-3xl sm:-top-80" aria-hidden="true">
                        <div className="relative left-[calc(50%-11rem)] aspect-[1155/678] w-[36.125rem] -translate-x-1/2 rotate-[30deg] bg-gradient-to-tr from-indigo-200 to-sky-400 opacity-20 sm:left-[calc(50%-30rem)] sm:w-[72.1875rem]" style={{ clipPath: 'polygon(74.1% 44.1%, 100% 61.6%, 97.5% 26.9%, 85.5% 0.1%, 80.7% 2%, 72.5% 32.5%, 60.2% 62.4%, 52.4% 68.1%, 47.5% 58.3%, 45.2% 34.5%, 27.5% 76.7%, 0.1% 64.9%, 17.9% 100%, 27.6% 76.8%, 76.1% 97.7%, 74.1% 44.1%)' }}></div>
                    </div>

                    <div className="mx-auto max-w-7xl px-6 lg:px-8">
                        <div className="mx-auto max-w-2xl text-center">
                            <span className="inline-flex rounded-full px-4 py-1.5 text-xs font-semibold tracking-[0.12em] uppercase text-indigo-700 ring-1 ring-indigo-600/20 bg-indigo-50/70">
                                Unified Diagnostics
                            </span>
                            <h2 className="mt-6 text-4xl font-extrabold tracking-tight text-slate-900 sm:text-5xl">App Test Center</h2>
                            <p className="mt-4 text-lg text-slate-600">Database health, socket connectivity, and notification test are now available in one page.</p>
                        </div>

                        {resultMessage && (
                            <div className={`mt-8 mx-auto max-w-3xl rounded-xl border px-4 py-3 text-sm ${resultMessage.status === 'success' ? 'border-emerald-200 bg-emerald-50 text-emerald-700' : 'border-rose-200 bg-rose-50 text-rose-700'}`}>
                                {resultMessage.message}
                            </div>
                        )}

                        <div className="mt-10 grid grid-cols-1 gap-6 lg:grid-cols-3">
                            <section className="rounded-2xl border border-slate-100 bg-white p-6 shadow-sm">
                                <h3 className="text-lg font-semibold text-slate-900">Database Connection</h3>
                                <div className="mt-5 space-y-3 text-sm">
                                    <div className="flex items-center justify-between gap-3">
                                        <span className="text-slate-500">Status</span>
                                        <span className={status === 'Connected' ? 'text-emerald-600 font-semibold' : 'text-rose-600 font-semibold'}>{status}</span>
                                    </div>
                                    <div className="flex items-center justify-between gap-3">
                                        <span className="text-slate-500">MySQL Version</span>
                                        <span className="text-slate-800 font-medium">{version}</span>
                                    </div>
                                    {error && <p className="text-rose-600 text-xs whitespace-pre-wrap">{error}</p>}
                                </div>
                                <button
                                    type="button"
                                    onClick={runMigration}
                                    disabled={isMigrating}
                                    className="mt-5 w-full rounded-lg bg-emerald-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-emerald-500 disabled:opacity-60 disabled:cursor-not-allowed transition"
                                >
                                    {isMigrating ? 'Running Migration...' : 'Run Migration'}
                                </button>
                            </section>

                            <section className="rounded-2xl border border-slate-100 bg-white p-6 shadow-sm">
                                <h3 className="text-lg font-semibold text-slate-900">Socket Connection</h3>
                                <div className="mt-5 space-y-4">
                                    <div className="flex items-center gap-2 text-sm">
                                        <span className={`w-2.5 h-2.5 rounded-full ${isConnected ? 'bg-emerald-500' : 'bg-rose-500'}`}></span>
                                        <span className="font-medium text-slate-700">{isConnected ? 'Connected' : 'Disconnected'}</span>
                                    </div>
                                    <button
                                        type="button"
                                        onClick={triggerSocketEvent}
                                        disabled={!isConnected}
                                        className="w-full rounded-lg bg-indigo-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed transition"
                                    >
                                        Trigger Socket Event
                                    </button>
                                </div>
                            </section>

                            <section className="rounded-2xl border border-slate-100 bg-white p-6 shadow-sm">
                                <h3 className="text-lg font-semibold text-slate-900">Notification Trigger</h3>
                                <form onSubmit={triggerNotificationEvent} className="mt-4 space-y-3">
                                    <select
                                        value={notificationForm.type}
                                        onChange={(event) => setNotificationForm({ ...notificationForm, type: event.target.value })}
                                        className="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm text-slate-700 focus:border-indigo-500 focus:ring-indigo-500"
                                    >
                                        <option value="info">Info</option>
                                        <option value="success">Success</option>
                                        <option value="warning">Warning</option>
                                        <option value="error">Error</option>
                                    </select>
                                    <input
                                        type="text"
                                        value={notificationForm.title}
                                        onChange={(event) => setNotificationForm({ ...notificationForm, title: event.target.value })}
                                        className="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm text-slate-700 focus:border-indigo-500 focus:ring-indigo-500"
                                        placeholder="Notification title"
                                        required
                                    />
                                    <textarea
                                        rows="3"
                                        value={notificationForm.body}
                                        onChange={(event) => setNotificationForm({ ...notificationForm, body: event.target.value })}
                                        className="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm text-slate-700 focus:border-indigo-500 focus:ring-indigo-500"
                                        placeholder="Notification body"
                                        required
                                    ></textarea>
                                    <button
                                        type="submit"
                                        className="w-full rounded-lg bg-slate-900 px-4 py-2.5 text-sm font-semibold text-white hover:bg-slate-800 transition"
                                    >
                                        Send Notification
                                    </button>
                                </form>
                            </section>
                        </div>

                        <div className="mt-6 grid grid-cols-1 gap-6 sm:grid-cols-2">
                            <section className="rounded-2xl border border-slate-100 bg-white p-6 shadow-sm">
                                <h3 className="text-lg font-semibold text-slate-900">Queue Worker</h3>
                                <p className="mt-2 text-sm text-slate-500">Dispatch a test job to the queue. If the worker is running, it will pick it up and broadcast a socket event on <code className="text-xs bg-slate-100 px-1 py-0.5 rounded">test-channel</code>.</p>
                                <button
                                    type="button"
                                    onClick={triggerWorkerJob}
                                    disabled={isDispatchingJob}
                                    className="mt-5 w-full rounded-lg bg-violet-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-violet-500 disabled:opacity-60 disabled:cursor-not-allowed transition"
                                >
                                    {isDispatchingJob ? 'Dispatching...' : 'Dispatch Test Job'}
                                </button>
                            </section>

                            <section className="rounded-2xl border border-slate-100 bg-white p-6 shadow-sm">
                                <h3 className="text-lg font-semibold text-slate-900">Cron Scheduler</h3>
                                <p className="mt-2 text-sm text-slate-500">Manually trigger <code className="text-xs bg-slate-100 px-1 py-0.5 rounded">php artisan schedule:run</code>. Returns all due tasks output or "No scheduled tasks were due."</p>
                                <button
                                    type="button"
                                    onClick={triggerCronRun}
                                    disabled={isRunningCron}
                                    className="mt-5 w-full rounded-lg bg-amber-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-amber-500 disabled:opacity-60 disabled:cursor-not-allowed transition"
                                >
                                    {isRunningCron ? 'Running Schedule...' : 'Run schedule:run'}
                                </button>
                            </section>
                        </div>
                    </div>
                </main>

                <footer className="bg-white border-t border-slate-100 py-10 w-full">
                    <div className="mx-auto max-w-7xl px-6 lg:px-8 text-center">
                        <p className="text-xs font-medium text-slate-400">
                            Laravel v{laravelVersion} • PHP v{phpVersion} • AT-Monolith
                        </p>
                    </div>
                </footer>
            </div>
        </>
    );
}
