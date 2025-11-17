// =====================================================
// TIPOS DE BASE DE DATOS - FALTA UNO
// Generados desde el schema de Supabase
// =====================================================

export type CategoriaPadel =
  | 'octava'
  | 'septima'
  | 'sexta'
  | 'quinta'
  | 'cuarta'
  | 'tercera'
  | 'segunda'
  | 'primera';

export type EstadoPartido = 'abierto' | 'completo' | 'finalizado' | 'cancelado';

export type EstadoParticipacion = 'pendiente' | 'confirmado' | 'rechazado' | 'cancelado';

export type TipoNotificacion =
  | 'nueva_solicitud'
  | 'solicitud_aceptada'
  | 'solicitud_rechazada'
  | 'partido_completo'
  | 'recordatorio'
  | 'cancelacion';

export type PlataformaPush = 'ios' | 'android';

// =====================================================
// INTERFACES DE TABLAS
// =====================================================

export interface Profile {
  id: string;
  full_name: string;
  avatar_url: string | null;
  categoria: CategoriaPadel;
  ubicacion_preferida: string | null;
  lat: number | null;
  lng: number | null;
  bio: string | null;
  telefono: string | null;
  email_verificado: boolean;
  telefono_verificado: boolean;
  rating_promedio: number;
  partidos_jugados: number;
  no_shows: number;
  preferencias: {
    notif_nuevas_solicitudes?: boolean;
    notif_solicitud_aceptada?: boolean;
    notif_recordatorios?: boolean;
  };
  created_at: string;
  updated_at: string;
}

export interface Partido {
  id: string;
  creador_id: string;
  titulo: string;
  descripcion: string | null;
  fecha: string;
  hora: string;
  club_nombre: string;
  club_direccion: string;
  lat: number;
  lng: number;
  categoria_minima: CategoriaPadel;
  categoria_maxima: CategoriaPadel;
  cupos_totales: number;
  cupos_disponibles: number;
  costo_por_persona: number | null;
  nivel_requerido: string | null;
  estado: EstadoPartido;
  created_at: string;
  updated_at: string;
}

export interface Participacion {
  id: string;
  partido_id: string;
  usuario_id: string;
  estado: EstadoParticipacion;
  es_creador: boolean;
  rating_dado: number | null;
  comentario: string | null;
  cancelado_at: string | null;
  penalizacion_aplicada: boolean;
  created_at: string;
  updated_at: string;
}

export interface Rating {
  id: string;
  partido_id: string;
  evaluador_id: string;
  evaluado_id: string;
  puntuacion: number;
  comentario: string | null;
  aspectos: {
    puntualidad?: number;
    nivel?: number;
    actitud?: number;
  };
  created_at: string;
}

export interface Notificacion {
  id: string;
  usuario_id: string;
  tipo: TipoNotificacion;
  partido_id: string | null;
  titulo: string;
  mensaje: string;
  leida: boolean;
  created_at: string;
}

export interface PushToken {
  id: string;
  usuario_id: string;
  token: string;
  plataforma: PlataformaPush;
  activo: boolean;
  created_at: string;
  updated_at: string;
}

// =====================================================
// TIPOS EXTENDIDOS CON RELACIONES
// =====================================================

export interface PartidoConCreador extends Partido {
  creador: Profile;
}

export interface ParticipacionDetalle extends Participacion {
  usuario: Profile;
  partido: Partido;
}

// =====================================================
// TIPOS PARA INSERTS/UPDATES
// =====================================================

export type ProfileInsert = Omit<Profile, 'id' | 'created_at' | 'updated_at'>;
export type ProfileUpdate = Partial<ProfileInsert>;

export type PartidoInsert = Omit<Partido, 'id' | 'created_at' | 'updated_at' | 'cupos_disponibles'>;
export type PartidoUpdate = Partial<PartidoInsert>;

export type ParticipacionInsert = Omit<Participacion, 'id' | 'created_at' | 'updated_at'>;
export type ParticipacionUpdate = Partial<ParticipacionInsert>;

export type RatingInsert = Omit<Rating, 'id' | 'created_at'>;

// =====================================================
// TIPOS PARA FORMULARIOS
// =====================================================

export interface CrearPartidoForm {
  titulo: string;
  descripcion?: string;
  fecha: Date;
  hora: string;
  club_nombre: string;
  club_direccion: string;
  lat: number;
  lng: number;
  categoria_minima: CategoriaPadel;
  categoria_maxima: CategoriaPadel;
  cupos_totales: number;
  costo_por_persona?: number;
  nivel_requerido?: string;
}

export interface RegistroForm {
  email: string;
  password: string;
  full_name: string;
  categoria: CategoriaPadel;
}

export interface PerfilForm {
  full_name: string;
  categoria: CategoriaPadel;
  ubicacion_preferida?: string;
  bio?: string;
  telefono?: string;
}
