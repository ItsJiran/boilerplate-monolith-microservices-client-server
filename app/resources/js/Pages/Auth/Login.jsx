import { Head, Link, useForm } from '@inertiajs/react';
import AuthLayout from '@/Layouts/AuthLayout';
import DashboardPreview from '@/Components/ui/molecules/DashboardPreview';
import InputGroup from '@/Components/ui/atoms/InputGroup';
import Button from '@/Components/ui/atoms/Button';

export default function Login() {
    const { data, setData, post, processing, errors } = useForm({
        email: '',
        password: '',
    });

    const submit = (event) => {
        event.preventDefault();
        post(route('login'), {
            onFinish: () => { },
        });
    };

    return (
        <AuthLayout previewContent={<DashboardPreview />}>
            <Head title="Login" />

            {/* Logo Section */}
            <div className="flex items-center gap-2 mb-6">
                <div className="w-8 h-8 bg-purple-600 rounded-lg flex items-center justify-center">
                    <svg
                        className="w-5 h-5 text-white"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                    >
                        <path
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            strokeWidth={2}
                            d="M13 10V3L4 14h7v7l9-11h-7z"
                        />
                    </svg>
                </div>
                <div>
                    <p className="text-xl font-bold text-gray-900">APP</p>
                    <p className="text-xs text-gray-400">admin</p>
                </div>
            </div>

            <div className="mb-8">
                <h1 className="text-3xl font-bold text-gray-900 mb-2">
                    Masuk ke Dashboard
                </h1>
                <p className="text-sm text-gray-500">
                    Masukkan email dan kata sandi Anda untuk melanjutkan.
                </p>
            </div>

            <form onSubmit={submit}>
                <InputGroup
                    label="Email"
                    type="email"
                    placeholder="m@example.com"
                    value={data.email}
                    onChange={(e) => setData('email', e.target.value)}
                />
                {errors.email && (
                    <p className="text-xs text-red-500 mb-2">{errors.email}</p>
                )}

                <InputGroup
                    label="Password"
                    type="password"
                    placeholder="Enter your password"
                    value={data.password}
                    onChange={(e) => setData('password', e.target.value)}
                    className="mb-2"
                />
                {errors.password && (
                    <p className="text-xs text-red-500 mb-2">
                        {errors.password}
                    </p>
                )}

                <div className="mb-6 text-right">
                    <Link className="text-sm text-purple-600 hover:text-purple-700 font-medium" href={route('password.request')}>
                        Lupa kata sandi?
                    </Link>
                </div>

                <Button className='w-full' type="submit" isLoading={processing}>
                    Login
                </Button>

                <div className="mt-4">
                    <Link href={route('register')}>
                        <Button
                            className='w-full'
                            type="button"
                            variant="white"
                        >
                            Buat Akun
                        </Button>
                    </Link>
                </div>
            </form>
        </AuthLayout>
    );
}
