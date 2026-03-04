import ApplicationLogo from '@/Components/ApplicationLogo';
import { Link } from '@inertiajs/react';

export default function GuestLayout({ children }) {
    return (
        <div className="min-h-screen bg-slate-950">
            <div className="flex min-h-screen flex-col items-center justify-center px-4 py-12 sm:px-6 lg:px-8">
                <div className="flex flex-col items-center gap-4 text-center text-white/80">
                    <Link href="/">
                        <ApplicationLogo className="h-20 w-20 fill-current text-white" />
                    </Link>
                    <p className="max-w-sm text-sm font-light leading-relaxed text-white/70">
                        Securely access the application control surface with your
                        credentials. Tremor UI keeps the experience consistent
                        across every auth flow.
                    </p>
                </div>

                <div className="mt-10 w-full max-w-md">{children}</div>
            </div>
        </div>
    );
}
