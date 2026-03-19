import { View, Text, Button, StyleSheet, ActivityIndicator } from 'react-native';
import { useRouter } from 'expo-router';
import { useAuth } from '@/hooks/useAuth';
import { useEffect } from 'react';

export default function Guest() {
  const { user, isAuthenticated, loading } = useAuth();
  const router = useRouter();

  useEffect(() => {
    // If logged in, redirect to home
    if (!loading && isAuthenticated) {
      router.replace('/');
    }
  }, [loading, isAuthenticated]);

  if (loading || isAuthenticated) {
    return (
      <View style={styles.container}>
        <ActivityIndicator size="large" />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Guest Page</Text>
      <Text style={styles.subtitle}>Welcome Guest!</Text>
      <Text>You are not logged in. This page is public.</Text>
      
      <Button title="Login now" onPress={() => router.push('/auth/login')} />
      <Button title="Go Home" onPress={() => router.push('/')} color="gray" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 20, justifyContent: 'center', alignItems: 'center' },
  title: { fontSize: 24, fontWeight: 'bold', marginBottom: 20 },
  subtitle: { fontSize: 18, marginBottom: 10, color: 'gray' },
});
