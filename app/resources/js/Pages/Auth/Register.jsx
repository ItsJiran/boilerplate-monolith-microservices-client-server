import { Head, Link, useForm } from '@inertiajs/react';
import AuthLayout from '@/Layouts/AuthLayout';
import DashboardPreview from '@/Components/ui/molecules/DashboardPreview';
import InputGroup from '@/Components/ui/atoms/InputGroup';
import Button from '@/Components/ui/atoms/Button';

export default function Register() {
    const { data, setData, post, processing, errors } = useForm({
        name: '',
        email: '',
        password: '',
        password_confirmation: '',
    });

    const submit = (event) => {
        event.preventDefault();
        post(route('register'), {
            onFinish: () => { },
        });
    };

    return (
        <AuthLayout previewContent={<DashboardPreview />}>
            <Head title="Register" />

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
                    Buat Akun Baru
                </h1>
                <p className="text-sm text-gray-500">
                    Mulai sesi yang aman dan pantau insight secara real-time.
                </p>
            </div>

            <form onSubmit={submit}>
                <InputGroup
                    label="Full name"
                    value={data.name}
                    placeholder="Jane Doe"
                    onChange={(event) => setData('name', event.target.value)}
                />
                {errors.name && (
                    <p className="text-xs text-red-500 mb-2">{errors.name}</p>
                )}

                <InputGroup
                    label="Email"
                    type="email"
                    value={data.email}
                    placeholder="you@example.com"
                    onChange={(event) => setData('email', event.target.value)}
                />
                {errors.email && (
                    <p className="text-xs text-red-500 mb-2">{errors.email}</p>
                )}

                <InputGroup
                    label="Password"
                    type="password"
                    value={data.password}
                    placeholder="••••••••"
                    onChange={(event) =>
                        setData('password', event.target.value)
                    }
                />
                {errors.password && (
                    <p className="text-xs text-red-500 mb-2">
                        {errors.password}
                    </p>
                )}

                <InputGroup
                    label="Confirm Password"
                    type="password"
                    value={data.password_confirmation}
                    placeholder="••••••••"
                    onChange={(event) =>
                        setData('password_confirmation', event.target.value)
                    }
                />
                {errors.password_confirmation && (
                    <p className="text-xs text-red-500 mb-2">
                        {errors.password_confirmation}
                    </p>
                )}

                <Button className='w-full' type="submit" isLoading={processing}>
                    Daftar
                </Button>

                <div className="mt-4">
                    <Link href={route('login')}>
                        <Button
                            className='w-full'
                            type="button"
                            variant="white"
                        >
                            Sudah punya akun
                        </Button>
                    </Link>
                </div>
            </form>
        </AuthLayout>
    );
}
