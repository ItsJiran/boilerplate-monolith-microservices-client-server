  import { View, Text, StyleSheet, Button, ActivityIndicator, Image, FlatList } from 'react-native';
import { useEffect, useState } from 'react';
import { router } from 'expo-router';

interface User {
  id: number;
  name: string;
  email: string;
  username: string;
  phone: string;
}

export default function SSRTest() {
  const [data, setData] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);
      setError(null);
      // Using jsonplaceholder as a mock API since local Laravel might not be reachable from emulator easily without proxy
      const response = await fetch('https://jsonplaceholder.typicode.com/users');
      if (!response.ok) throw new Error('Network response was not ok');
      const json = await response.json();
      setData(json);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <View style={styles.center}>
        <ActivityIndicator size="large" />
        <Text>Loading users...</Text>
      </View>
    );
  }

  if (error) {
    return (
      <View style={styles.center}>
        <Text style={styles.error}>Error: {error}</Text>
        <Button title="Retry" onPress={fetchData} />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Text style={styles.header}>Users List (Mock API)</Text>
      <FlatList
        data={data}
        keyExtractor={(item) => item.id.toString()}
        renderItem={({ item }) => (
          <View style={styles.item}>
            <Text style={styles.name}>{item.name}</Text>
            <Text style={styles.email}>{item.email}</Text>
            <Text style={styles.detail}>{item.phone}</Text>
          </View>
        )}
      />
      <Button title="Go Home" onPress={() => router.push('/')} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 20 },
  center: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  header: { fontSize: 24, fontWeight: 'bold', marginBottom: 20, textAlign: 'center' },
  item: { padding: 15, marginBottom: 10, backgroundColor: '#f9f9f9', borderRadius: 8, borderWidth: 1, borderColor: '#eee' },
  name: { fontSize: 18, fontWeight: '600' },
  email: { color: '#666', marginTop: 4 },
  detail: { color: '#999', marginTop: 2, fontSize: 12 },
  error: { color: 'red', marginBottom: 10, fontSize: 16 }
});
