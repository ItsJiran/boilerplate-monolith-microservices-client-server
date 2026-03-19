import { Stack } from 'expo-router';
import { AuthProvider } from '@/hooks/useAuth';

export default function Layout() {
  return (
    <AuthProvider>
      <Stack
        screenOptions={{
          headerStyle: { backgroundColor: '#f4511e' },
          headerTintColor: '#fff',
          headerTitleStyle: { fontWeight: 'bold' },
        }}
      >
        <Stack.Screen name="index" options={{ title: 'Home' }} />
        <Stack.Screen name="auth/login" options={{ title: 'Sign In' }} />
        <Stack.Screen name="ssr-test" options={{ title: 'Data Fetching' }} />
        <Stack.Screen name="protected" options={{ title: 'Protected Route' }} />
        <Stack.Screen name="guest" options={{ title: 'Guest Page' }} />
      </Stack>
    </AuthProvider>
  );
}
