import { useEffect } from 'react';
import { StatusBar } from 'expo-status-bar';
import AsyncStorage from '@react-native-async-storage/async-storage';
import AppNavigator from './src/navigation/AppNavigator';

export default function App() {
  useEffect(() => {
    // Clear any corrupted AsyncStorage data on first load
    // This fixes "expected dynamic type 'boolean', but had type 'string'" errors
    const clearCorruptedStorage = async () => {
      try {
        await AsyncStorage.clear();
        console.log('AsyncStorage cleared successfully');
      } catch (error) {
        console.error('Error clearing AsyncStorage:', error);
      }
    };

    clearCorruptedStorage();
  }, []);

  return (
    <>
      <AppNavigator />
      <StatusBar style="auto" />
    </>
  );
}
