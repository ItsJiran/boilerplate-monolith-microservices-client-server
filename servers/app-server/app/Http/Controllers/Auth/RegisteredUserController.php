<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Auth\Events\Registered;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Validation\Rules;
use Inertia\Inertia;
use Inertia\Response;

class RegisteredUserController extends Controller
{
    /**
     * Display the registration view.
     */
    public function create(): Response
    {
        return Inertia::render('Auth/Register');
    }

    /**
     * Handle an incoming registration request.
     *
     * @throws \Illuminate\Validation\ValidationException
     */
    public function store(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|lowercase|email|max:255|unique:'.User::class,
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
        ]);

        $data['username'] = $this->generateUniqueUsername($request->name);
        $data['password'] = Hash::make($data['password']);

        $user = User::create($data);

        event(new Registered($user));

        Auth::login($user);

        return redirect(route('dashboard', absolute: false));
    }

    private function generateUniqueUsername(string $name): string
    {
        $base = (string) Str::of($name)
            ->lower()
            ->replaceMatches('/[^a-z0-9\s]/', '')
            ->replaceMatches('/\s+/', '')
            ->trim();

        if ($base === '') {
            $base = 'user';
        }

        $candidate = $base;
        $counter = 1;

        while (User::where('username', $candidate)->exists()) {
            $candidate = $base.$counter;
            $counter++;
        }

        return $candidate;
    }
}
