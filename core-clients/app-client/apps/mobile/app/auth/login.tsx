import { View, Text, TextInput, Button, StyleSheet } from 'react-native';
import { useRouter } from 'expo-router';
import { useAuth } from '@/hooks/useAuth';
import { useState } from 'react';

export default function Login() {
  const [email, setEmail] = useState('user@example.com');
  const [password, setPassword] = useState('secret');
  const { login, isAuthenticated, loading } = useAuth();
  const router = useRouter();

  const handleLogin = async () => {
    if (isAuthenticated) {
      router.replace('/');
      return;
    }

    try {
      await login(email, password);
      router.replace('/protected');
    } catch {
      alert('Invalid credentials');
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Login</Text>
      
      <TextInput
        style={styles.input}
        placeholder="Email"
        value={email}
        onChangeText={setEmail}
        autoCapitalize="none"
      />
      <TextInput
        style={styles.input}
        placeholder="Password"
        value={password}
        onChangeText={setPassword}
        secureTextEntry
      />
      
      <Button title={loading ? 'Signing in...' : 'Login'} onPress={handleLogin} disabled={loading} />
      
      <Button title="Go Back" onPress={() => router.back()} color="gray" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 20, justifyContent: 'center' },
  title: { fontSize: 24, fontWeight: 'bold', marginBottom: 20, textAlign: 'center' },
  input: { borderWidth: 1, borderColor: '#ccc', borderRadius: 5, padding: 10, marginBottom: 15 },
});
