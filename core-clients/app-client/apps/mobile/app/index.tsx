import { View, Text, Button, StyleSheet } from 'react-native';
import { Link, useRouter } from 'expo-router';
import { useAuth } from '../src/hooks/useAuth';

export default function Home() {
  const { user, login, logout, isAuthenticated } = useAuth();
  const router = useRouter();

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Welcome Home</Text>
      
      {isAuthenticated ? (
        <View style={styles.card}>
          <Text style={styles.subtitle}>Hello, {user?.name}</Text>
          <Button title="Logout" onPress={logout} />
        </View>
      ) : (
        <View style={styles.card}>
          <Text style={styles.subtitle}>Not logged in</Text>
          <Button title="Go to Login" onPress={() => router.push('/auth/login')} />
        </View>
      )}

      <View style={styles.links}>
        <Link href="/protected" asChild>
          <Button title="Go to Protected Page" />
        </Link>
        <Link href="/guest" asChild>
          <Button title="Go to Guest Page" color="green" />
        </Link>
        <Link href="/ssr-test" asChild>
          <Button title="Test Data Fetching" color="purple" />
        </Link>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 20, alignItems: 'center', justifyContent: 'center' },
  title: { fontSize: 24, fontWeight: 'bold', marginBottom: 20 },
  card: { padding: 20, backgroundColor: '#eee', borderRadius: 10, marginBottom: 20, width: '100%' },
  subtitle: { fontSize: 18, marginBottom: 10 },
  links: { gap: 10, width: '100%' }
});
