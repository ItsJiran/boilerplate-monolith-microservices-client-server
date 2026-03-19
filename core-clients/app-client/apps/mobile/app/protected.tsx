import { View, Text, Button, StyleSheet, ActivityIndicator } from 'react-native';
import { useRouter } from 'expo-router';
import { useAuth } from '@/hooks/useAuth';
import { useEffect } from 'react';

export default function Protected() {
  const { user, isAuthenticated, loading } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!loading && !isAuthenticated) {
      router.replace('/auth/login');
    }
  }, [loading, isAuthenticated]);

  if (loading || !isAuthenticated) {
    return (
      <View style={styles.container}>
        <ActivityIndicator size="large" />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Protected Page</Text>
      <Text style={styles.subtitle}>Welcome back, {user?.name}</Text>
      <Text>This page is only visible to logged-in users.</Text>
      <Button title="Go Home" onPress={() => router.push('/')} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 20, justifyContent: 'center', alignItems: 'center' },
  title: { fontSize: 24, fontWeight: 'bold', marginBottom: 20 },
  subtitle: { fontSize: 18, marginBottom: 10, color: 'blue' },
});
