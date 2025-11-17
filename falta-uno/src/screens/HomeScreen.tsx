import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Alert } from 'react-native';
import { useAuth } from '../hooks/useAuth';

export default function HomeScreen() {
  const { profile, signOut } = useAuth();

  const handleSignOut = async () => {
    Alert.alert('Cerrar sesión', '¿Estás seguro que deseas salir?', [
      { text: 'Cancelar', style: 'cancel' },
      {
        text: 'Salir',
        style: 'destructive',
        onPress: async () => {
          await signOut();
        },
      },
    ]);
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Falta Uno</Text>
        {profile && (
          <View style={styles.profileInfo}>
            <Text style={styles.welcomeText}>Hola, {profile.full_name}</Text>
            <Text style={styles.categoriaText}>Categoría: {profile.categoria.toUpperCase()}</Text>
          </View>
        )}
      </View>

      <View style={styles.content}>
        <Text style={styles.comingSoon}>Próximamente:</Text>
        <View style={styles.featureList}>
          <Text style={styles.featureItem}>• Buscar partidos disponibles</Text>
          <Text style={styles.featureItem}>• Crear nuevos partidos</Text>
          <Text style={styles.featureItem}>• Ver tu historial</Text>
          <Text style={styles.featureItem}>• Sistema de ratings</Text>
        </View>
      </View>

      <TouchableOpacity style={styles.signOutButton} onPress={handleSignOut}>
        <Text style={styles.signOutText}>Cerrar Sesión</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  header: {
    padding: 20,
    paddingTop: 60,
    backgroundColor: '#007AFF',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 8,
  },
  profileInfo: {
    marginTop: 8,
  },
  welcomeText: {
    fontSize: 18,
    color: '#fff',
    marginBottom: 4,
  },
  categoriaText: {
    fontSize: 14,
    color: '#e0e0e0',
  },
  content: {
    flex: 1,
    padding: 20,
    justifyContent: 'center',
  },
  comingSoon: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
    color: '#1a1a1a',
    textAlign: 'center',
  },
  featureList: {
    backgroundColor: '#f5f5f5',
    borderRadius: 12,
    padding: 20,
  },
  featureItem: {
    fontSize: 16,
    marginBottom: 12,
    color: '#666',
  },
  signOutButton: {
    margin: 20,
    padding: 16,
    backgroundColor: '#ff3b30',
    borderRadius: 8,
    alignItems: 'center',
  },
  signOutText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
});
