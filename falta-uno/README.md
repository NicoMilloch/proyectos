# Falta Uno

Una aplicación móvil para encontrar jugadores de pádel y completar equipos.

## Descripción

Falta Uno es un pool de jugadores de pádel que permite:
- Publicar partidos con cupos disponibles
- Buscar partidos por ubicación, fecha y categoría
- Sistema de reputación y ratings entre jugadores
- Historial de partidos jugados
- Gestión de categorías (8ª a 1ª)

## Stack Tecnológico

- **Frontend**: React Native + Expo
- **Backend**: Supabase (PostgreSQL + Auth + Storage)
- **Navegación**: React Navigation
- **Autenticación**: Supabase Auth (Email/Password + Google OAuth)

## Requisitos Previos

- Node.js 18+ instalado
- npm o yarn
- Cuenta en Supabase (gratis)
- Expo Go app en tu teléfono (opcional, para testing)

## Configuración Inicial

### 1. Clonar el repositorio

```bash
git clone <repository-url>
cd falta-uno
```

### 2. Instalar dependencias

```bash
npm install
```

### 3. Configurar Supabase

#### 3.1 Crear proyecto en Supabase

1. Ve a [https://app.supabase.com](https://app.supabase.com)
2. Crea un nuevo proyecto
3. Espera a que termine de inicializarse

#### 3.2 Ejecutar el schema de base de datos

1. Abre el **SQL Editor** en Supabase
2. Copia todo el contenido del archivo `../supabase-schema.sql` (en el directorio padre)
3. Pega y ejecuta el script
4. Verifica que se crearon las 7 tablas:
   - profiles
   - partidos
   - participaciones
   - ratings
   - notificaciones
   - push_tokens

#### 3.3 Configurar variables de entorno

1. Copia el archivo `.env.example` a `.env`:
   ```bash
   cp .env.example .env
   ```

2. En Supabase, ve a **Settings > API**

3. Copia los siguientes valores a tu archivo `.env`:
   ```
   EXPO_PUBLIC_SUPABASE_URL=https://tu-proyecto.supabase.co
   EXPO_PUBLIC_SUPABASE_ANON_KEY=tu-anon-key-aqui
   ```

### 4. Ejecutar la aplicación

```bash
npm start
```

Esto abrirá Expo Developer Tools. Desde ahí puedes:
- Escanear el QR con la app **Expo Go** (iOS/Android)
- Presionar `i` para abrir en iOS Simulator
- Presionar `a` para abrir en Android Emulator
- Presionar `w` para abrir en el navegador web

## Estructura del Proyecto

```
falta-uno/
├── src/
│   ├── config/           # Configuración de Supabase
│   ├── screens/          # Pantallas de la app
│   │   ├── LoginScreen.tsx
│   │   ├── RegisterScreen.tsx
│   │   └── HomeScreen.tsx
│   ├── navigation/       # Configuración de navegación
│   ├── components/       # Componentes reutilizables
│   ├── hooks/           # Custom hooks (useAuth, etc.)
│   ├── types/           # Tipos de TypeScript
│   └── utils/           # Funciones utilitarias
├── assets/              # Imágenes, fuentes, etc.
├── App.tsx              # Punto de entrada
├── .env                 # Variables de entorno (NO COMMITEAR)
└── package.json
```

## Categorías de Pádel

La app utiliza el sistema estándar de categorías:

- **8ª (Octava)**: Principiante
- **7ª (Séptima)**: Novato
- **6ª (Sexta)**: Recreativo
- **5ª (Quinta)**: Intermedio bajo
- **4ª (Cuarta)**: Intermedio
- **3ª (Tercera)**: Intermedio avanzado
- **2ª (Segunda)**: Avanzado
- **1ª (Primera)**: Profesional

## Funcionalidades Actuales (MVP)

### ✅ Implementado
- [x] Registro de usuarios con categoría
- [x] Login/Logout
- [x] Autenticación con Supabase
- [x] Navegación básica
- [x] Persistencia de sesión

### 🚧 En desarrollo
- [ ] Crear partidos
- [ ] Buscar partidos disponibles
- [ ] Unirse a partidos
- [ ] Sistema de ratings
- [ ] Perfil de usuario
- [ ] Historial de partidos
- [ ] Notificaciones push

### 📋 Planificado para V2
- [ ] Chat entre jugadores
- [ ] Sistema de bloqueos
- [ ] Reportes
- [ ] Google Sign-In
- [ ] Favoritos

## Políticas de Cancelación

- ✅ Cancelar con **≥12 horas** de anticipación: Sin penalización
- ❌ Cancelar con **<12 horas** de anticipación: Incrementa contador `no_shows`

## Scripts Disponibles

```bash
# Iniciar el servidor de desarrollo
npm start

# Iniciar en Android
npm run android

# Iniciar en iOS (requiere macOS)
npm run ios

# Iniciar en web
npm run web

# Limpiar caché
npm start -- --clear
```

## Troubleshooting

### Error: "Supabase URL and Anon Key must be provided"
- Verifica que el archivo `.env` exista y tenga las variables correctas
- Reinicia el servidor Expo después de cambiar `.env`

### No puedo registrarme
- Verifica que el schema de Supabase esté correctamente ejecutado
- Revisa los logs de Supabase en la consola
- Asegúrate de que RLS (Row Level Security) esté configurado

### La app no carga
- Ejecuta `npm start -- --clear` para limpiar caché
- Verifica que todas las dependencias estén instaladas: `npm install`
- Revisa la consola de Expo para errores específicos

## Seguridad

- ✅ Row Level Security (RLS) habilitado en todas las tablas
- ✅ Variables de entorno para credenciales sensibles
- ✅ `.env` incluido en `.gitignore`
- ✅ Validaciones de formularios
- ✅ Autenticación segura con Supabase

## Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -m 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## Licencia

[Especificar licencia]

## Contacto

[Tu información de contacto]

---

**Versión**: 0.1.0 (MVP)
**Última actualización**: Noviembre 2025
