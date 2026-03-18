import { View, Text, TextInput, Button, StyleSheet } from 'react-native';
import { useRouter } from 'expo-router';
import { useAuth } from '../../src/hooks/useAuth';
import { useState } from 'react';

export default function Login() {
  const [username, setUsername] = useState('user@example.com');
  const [password, setPassword] = useState('secret');
  const { login, isAuthenticated } = useAuth();
  const router = useRouter();

  const handleLogin = () => {
    // In a real app, validate credentials
    if (isAuthenticated) {
      router.replace('/');
      return;
    }
    
    // Simulate login
    if (username === 'user@example.com' && password === 'secret') {
      login(username);
      // Wait for state update (or mock it)
      setTimeout(() => {
        router.replace('/protected');
      }, 500);
    } else {
      alert('Invalid credentials');
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Login</Text>
      
      <TextInput
        style={styles.input}
        placeholder="Username"
        value={username}
        onChangeText={setUsername}
      />
      <TextInput
        style={styles.input}
        placeholder="Password"
        value={password}
        onChangeText={setPassword}
        secureTextEntry
      />
      
      <Button title="Login" onPress={handleLogin} />
      
      <Button title="Go Back" onPress={() => router.back()} color="gray" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 20, justifyContent: 'center' },
  title: { fontSize: 24, fontWeight: 'bold', marginBottom: 20, textAlign: 'center' },
  input: { borderWidth: 1, borderColor: '#ccc', borderRadius: 5, padding: 10, marginBottom: 15 },
});
