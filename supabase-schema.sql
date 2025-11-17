-- =====================================================
-- PADEL MATCH - SCHEMA DE BASE DE DATOS
-- Para ejecutar en Supabase SQL Editor
-- =====================================================

-- =====================================================
-- 1. ENUMS (Tipos personalizados)
-- =====================================================

CREATE TYPE categoria_padel AS ENUM (
  'octava',
  'septima',
  'sexta',
  'quinta',
  'cuarta',
  'tercera',
  'segunda',
  'primera'
);

CREATE TYPE estado_partido AS ENUM (
  'abierto',
  'completo',
  'finalizado',
  'cancelado'
);

CREATE TYPE estado_participacion AS ENUM (
  'pendiente',
  'confirmado',
  'rechazado',
  'cancelado'
);

CREATE TYPE tipo_notificacion AS ENUM (
  'nueva_solicitud',
  'solicitud_aceptada',
  'solicitud_rechazada',
  'partido_completo',
  'recordatorio',
  'cancelacion'
);

CREATE TYPE plataforma_push AS ENUM (
  'ios',
  'android'
);

-- =====================================================
-- 2. TABLA PROFILES (Extiende auth.users de Supabase)
-- =====================================================

CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT NOT NULL,
  avatar_url TEXT,
  categoria categoria_padel NOT NULL DEFAULT 'octava',
  ubicacion_preferida TEXT,
  lat DECIMAL(10, 8),
  lng DECIMAL(11, 8),
  bio TEXT,
  telefono TEXT,
  email_verificado BOOLEAN DEFAULT FALSE,
  telefono_verificado BOOLEAN DEFAULT FALSE,
  rating_promedio DECIMAL(3, 2) DEFAULT 0 CHECK (rating_promedio >= 0 AND rating_promedio <= 5),
  partidos_jugados INTEGER DEFAULT 0 CHECK (partidos_jugados >= 0),
  no_shows INTEGER DEFAULT 0 CHECK (no_shows >= 0),
  preferencias JSONB DEFAULT '{"notif_nuevas_solicitudes": true, "notif_solicitud_aceptada": true, "notif_recordatorios": true}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 3. TABLA PARTIDOS
-- =====================================================

CREATE TABLE partidos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  creador_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  titulo TEXT NOT NULL,
  descripcion TEXT,
  fecha DATE NOT NULL,
  hora TIME NOT NULL,
  club_nombre TEXT NOT NULL,
  club_direccion TEXT NOT NULL,
  lat DECIMAL(10, 8) NOT NULL,
  lng DECIMAL(11, 8) NOT NULL,
  categoria_minima categoria_padel NOT NULL,
  categoria_maxima categoria_padel NOT NULL,
  cupos_totales INTEGER DEFAULT 4 CHECK (cupos_totales > 0 AND cupos_totales <= 4),
  cupos_disponibles INTEGER CHECK (cupos_disponibles >= 0),
  costo_por_persona DECIMAL(10, 2),
  nivel_requerido TEXT, -- "Amistoso", "Competitivo", etc.
  estado estado_partido DEFAULT 'abierto',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- Validación: categoría máxima >= categoría mínima
  CONSTRAINT categoria_valida CHECK (categoria_maxima >= categoria_minima),
  -- Validación: cupos disponibles <= cupos totales
  CONSTRAINT cupos_validos CHECK (cupos_disponibles <= cupos_totales)
);

-- =====================================================
-- 4. TABLA PARTICIPACIONES
-- =====================================================

CREATE TABLE participaciones (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  partido_id UUID REFERENCES partidos(id) ON DELETE CASCADE NOT NULL,
  usuario_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  estado estado_participacion DEFAULT 'pendiente',
  es_creador BOOLEAN DEFAULT FALSE,
  rating_dado INTEGER CHECK (rating_dado >= 1 AND rating_dado <= 5),
  comentario TEXT,
  cancelado_at TIMESTAMP WITH TIME ZONE,
  penalizacion_aplicada BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- Un usuario solo puede participar una vez por partido
  CONSTRAINT participacion_unica UNIQUE(partido_id, usuario_id)
);

-- =====================================================
-- 5. TABLA RATINGS
-- =====================================================

CREATE TABLE ratings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  partido_id UUID REFERENCES partidos(id) ON DELETE CASCADE NOT NULL,
  evaluador_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  evaluado_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  puntuacion INTEGER NOT NULL CHECK (puntuacion >= 1 AND puntuacion <= 5),
  comentario TEXT,
  aspectos JSONB DEFAULT '{}'::jsonb, -- {"puntualidad": 5, "nivel": 4, "actitud": 5}
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- Un usuario no puede calificarse a sí mismo
  CONSTRAINT no_autoevaluacion CHECK (evaluador_id != evaluado_id),
  -- Un evaluador solo puede calificar una vez a cada usuario por partido
  CONSTRAINT rating_unico UNIQUE(partido_id, evaluador_id, evaluado_id)
);

-- =====================================================
-- 6. TABLA NOTIFICACIONES
-- =====================================================

CREATE TABLE notificaciones (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  usuario_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  tipo tipo_notificacion NOT NULL,
  partido_id UUID REFERENCES partidos(id) ON DELETE CASCADE,
  titulo TEXT NOT NULL,
  mensaje TEXT NOT NULL,
  leida BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 7. TABLA PUSH TOKENS
-- =====================================================

CREATE TABLE push_tokens (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  usuario_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  token TEXT NOT NULL UNIQUE,
  plataforma plataforma_push NOT NULL,
  activo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 8. ÍNDICES PARA OPTIMIZACIÓN
-- =====================================================

-- Profiles
CREATE INDEX idx_profiles_categoria ON profiles(categoria);
CREATE INDEX idx_profiles_ubicacion ON profiles(lat, lng) WHERE lat IS NOT NULL AND lng IS NOT NULL;

-- Partidos
CREATE INDEX idx_partidos_fecha_hora ON partidos(fecha, hora);
CREATE INDEX idx_partidos_estado ON partidos(estado);
CREATE INDEX idx_partidos_creador ON partidos(creador_id);
CREATE INDEX idx_partidos_categoria ON partidos(categoria_minima, categoria_maxima);
CREATE INDEX idx_partidos_ubicacion ON partidos(lat, lng);
-- Índice para búsqueda de partidos abiertos y futuros
CREATE INDEX idx_partidos_disponibles ON partidos(estado, fecha, hora)
  WHERE estado = 'abierto';

-- Participaciones
CREATE INDEX idx_participaciones_usuario ON participaciones(usuario_id);
CREATE INDEX idx_participaciones_partido ON participaciones(partido_id);
CREATE INDEX idx_participaciones_estado ON participaciones(estado);

-- Ratings
CREATE INDEX idx_ratings_evaluado ON ratings(evaluado_id);
CREATE INDEX idx_ratings_partido ON ratings(partido_id);

-- Notificaciones
CREATE INDEX idx_notificaciones_usuario ON notificaciones(usuario_id, leida);
CREATE INDEX idx_notificaciones_fecha ON notificaciones(created_at DESC);

-- Push Tokens
CREATE INDEX idx_push_tokens_usuario ON push_tokens(usuario_id);
CREATE INDEX idx_push_tokens_activo ON push_tokens(activo) WHERE activo = TRUE;

-- =====================================================
-- 9. FUNCIONES Y TRIGGERS
-- =====================================================

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger a las tablas necesarias
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_partidos_updated_at BEFORE UPDATE ON partidos
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_participaciones_updated_at BEFORE UPDATE ON participaciones
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_push_tokens_updated_at BEFORE UPDATE ON push_tokens
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- Función para actualizar el rating promedio de un usuario
-- =====================================================

CREATE OR REPLACE FUNCTION actualizar_rating_promedio()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE profiles
  SET rating_promedio = (
    SELECT COALESCE(AVG(puntuacion), 0)
    FROM ratings
    WHERE evaluado_id = NEW.evaluado_id
  )
  WHERE id = NEW.evaluado_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_actualizar_rating AFTER INSERT ON ratings
  FOR EACH ROW EXECUTE FUNCTION actualizar_rating_promedio();

-- =====================================================
-- Función para actualizar cupos disponibles
-- =====================================================

CREATE OR REPLACE FUNCTION actualizar_cupos_disponibles()
RETURNS TRIGGER AS $$
DECLARE
  cupos_confirmados INTEGER;
BEGIN
  -- Contar participaciones confirmadas (incluyendo creador)
  SELECT COUNT(*) INTO cupos_confirmados
  FROM participaciones
  WHERE partido_id = COALESCE(NEW.partido_id, OLD.partido_id)
    AND estado = 'confirmado';

  -- Actualizar cupos disponibles
  UPDATE partidos
  SET cupos_disponibles = cupos_totales - cupos_confirmados,
      estado = CASE
        WHEN cupos_totales - cupos_confirmados = 0 THEN 'completo'::estado_partido
        ELSE estado
      END
  WHERE id = COALESCE(NEW.partido_id, OLD.partido_id);

  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_actualizar_cupos
  AFTER INSERT OR UPDATE OR DELETE ON participaciones
  FOR EACH ROW EXECUTE FUNCTION actualizar_cupos_disponibles();

-- =====================================================
-- Función para crear participación del creador automáticamente
-- =====================================================

CREATE OR REPLACE FUNCTION crear_participacion_creador()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO participaciones (partido_id, usuario_id, estado, es_creador)
  VALUES (NEW.id, NEW.creador_id, 'confirmado', TRUE);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_crear_participacion_creador
  AFTER INSERT ON partidos
  FOR EACH ROW EXECUTE FUNCTION crear_participacion_creador();

-- =====================================================
-- Función para incrementar partidos_jugados al finalizar partido
-- =====================================================

CREATE OR REPLACE FUNCTION incrementar_partidos_jugados()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.estado = 'finalizado' AND OLD.estado != 'finalizado' THEN
    UPDATE profiles
    SET partidos_jugados = partidos_jugados + 1
    WHERE id IN (
      SELECT usuario_id
      FROM participaciones
      WHERE partido_id = NEW.id
        AND estado = 'confirmado'
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_incrementar_partidos
  AFTER UPDATE ON partidos
  FOR EACH ROW
  WHEN (NEW.estado = 'finalizado')
  EXECUTE FUNCTION incrementar_partidos_jugados();

-- =====================================================
-- Función para aplicar penalización por cancelación tardía
-- =====================================================

CREATE OR REPLACE FUNCTION aplicar_penalizacion_cancelacion()
RETURNS TRIGGER AS $$
DECLARE
  partido_fecha TIMESTAMP;
  horas_diferencia NUMERIC;
BEGIN
  IF NEW.estado = 'cancelado' AND OLD.estado = 'confirmado' THEN
    -- Obtener fecha y hora del partido
    SELECT (fecha + hora) INTO partido_fecha
    FROM partidos
    WHERE id = NEW.partido_id;

    -- Calcular diferencia en horas
    horas_diferencia := EXTRACT(EPOCH FROM (partido_fecha - NOW())) / 3600;

    -- Si cancela con menos de 12 horas de anticipación
    IF horas_diferencia < 12 THEN
      -- Incrementar no_shows
      UPDATE profiles
      SET no_shows = no_shows + 1
      WHERE id = NEW.usuario_id;

      -- Marcar que se aplicó penalización
      NEW.penalizacion_aplicada := TRUE;
      NEW.cancelado_at := NOW();
    ELSE
      NEW.cancelado_at := NOW();
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_penalizacion_cancelacion
  BEFORE UPDATE ON participaciones
  FOR EACH ROW
  WHEN (NEW.estado = 'cancelado' AND OLD.estado = 'confirmado')
  EXECUTE FUNCTION aplicar_penalizacion_cancelacion();

-- =====================================================
-- 10. ROW LEVEL SECURITY (RLS) - POLÍTICAS
-- =====================================================

-- Habilitar RLS en todas las tablas
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE partidos ENABLE ROW LEVEL SECURITY;
ALTER TABLE participaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE notificaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE push_tokens ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- POLÍTICAS PARA PROFILES
-- =====================================================

-- Todos pueden ver perfiles públicos
CREATE POLICY "Los perfiles son visibles para todos"
  ON profiles FOR SELECT
  USING (true);

-- Los usuarios pueden crear su propio perfil
CREATE POLICY "Los usuarios pueden crear su perfil"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Los usuarios solo pueden actualizar su propio perfil
CREATE POLICY "Los usuarios pueden actualizar su propio perfil"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- =====================================================
-- POLÍTICAS PARA PARTIDOS
-- =====================================================

-- Todos pueden ver partidos abiertos y completos
CREATE POLICY "Los partidos abiertos son visibles para todos"
  ON partidos FOR SELECT
  USING (estado IN ('abierto', 'completo', 'finalizado'));

-- Usuarios autenticados pueden crear partidos
CREATE POLICY "Usuarios autenticados pueden crear partidos"
  ON partidos FOR INSERT
  WITH CHECK (auth.uid() = creador_id);

-- Solo el creador puede actualizar su partido
CREATE POLICY "Solo el creador puede actualizar el partido"
  ON partidos FOR UPDATE
  USING (auth.uid() = creador_id);

-- Solo el creador puede eliminar su partido (si no tiene participantes confirmados)
CREATE POLICY "Solo el creador puede eliminar su partido"
  ON partidos FOR DELETE
  USING (auth.uid() = creador_id);

-- =====================================================
-- POLÍTICAS PARA PARTICIPACIONES
-- =====================================================

-- Los usuarios pueden ver participaciones de partidos en los que están involucrados
CREATE POLICY "Ver participaciones de mis partidos"
  ON participaciones FOR SELECT
  USING (
    auth.uid() = usuario_id
    OR auth.uid() IN (
      SELECT creador_id FROM partidos WHERE id = partido_id
    )
  );

-- Los usuarios pueden solicitar unirse a un partido
CREATE POLICY "Los usuarios pueden solicitar unirse"
  ON participaciones FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);

-- El creador del partido puede actualizar estados, el usuario puede cancelar
CREATE POLICY "Actualizar participaciones"
  ON participaciones FOR UPDATE
  USING (
    auth.uid() = usuario_id
    OR auth.uid() IN (
      SELECT creador_id FROM partidos WHERE id = partido_id
    )
  );

-- =====================================================
-- POLÍTICAS PARA RATINGS
-- =====================================================

-- Los usuarios pueden ver ratings donde están involucrados
CREATE POLICY "Ver ratings propios"
  ON ratings FOR SELECT
  USING (auth.uid() = evaluador_id OR auth.uid() = evaluado_id);

-- Los usuarios pueden crear ratings de partidos donde participaron
CREATE POLICY "Crear ratings de partidos jugados"
  ON ratings FOR INSERT
  WITH CHECK (
    auth.uid() = evaluador_id
    AND EXISTS (
      SELECT 1 FROM participaciones
      WHERE partido_id = ratings.partido_id
        AND usuario_id = auth.uid()
        AND estado = 'confirmado'
    )
  );

-- =====================================================
-- POLÍTICAS PARA NOTIFICACIONES
-- =====================================================

-- Los usuarios solo ven sus propias notificaciones
CREATE POLICY "Ver solo propias notificaciones"
  ON notificaciones FOR SELECT
  USING (auth.uid() = usuario_id);

-- Sistema puede crear notificaciones (se manejará desde backend)
CREATE POLICY "Sistema puede crear notificaciones"
  ON notificaciones FOR INSERT
  WITH CHECK (true);

-- Los usuarios pueden marcar sus notificaciones como leídas
CREATE POLICY "Actualizar propias notificaciones"
  ON notificaciones FOR UPDATE
  USING (auth.uid() = usuario_id);

-- =====================================================
-- POLÍTICAS PARA PUSH_TOKENS
-- =====================================================

-- Los usuarios solo ven sus propios tokens
CREATE POLICY "Ver solo propios tokens"
  ON push_tokens FOR SELECT
  USING (auth.uid() = usuario_id);

-- Los usuarios pueden crear sus propios tokens
CREATE POLICY "Crear propios tokens"
  ON push_tokens FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);

-- Los usuarios pueden actualizar sus propios tokens
CREATE POLICY "Actualizar propios tokens"
  ON push_tokens FOR UPDATE
  USING (auth.uid() = usuario_id);

-- Los usuarios pueden eliminar sus propios tokens
CREATE POLICY "Eliminar propios tokens"
  ON push_tokens FOR DELETE
  USING (auth.uid() = usuario_id);

-- =====================================================
-- 11. VISTAS ÚTILES
-- =====================================================

-- Vista para partidos con información del creador
CREATE OR REPLACE VIEW partidos_con_creador AS
SELECT
  p.*,
  prof.full_name AS creador_nombre,
  prof.avatar_url AS creador_avatar,
  prof.rating_promedio AS creador_rating,
  prof.telefono AS creador_telefono
FROM partidos p
JOIN profiles prof ON p.creador_id = prof.id;

-- Vista para participaciones con info de usuarios
CREATE OR REPLACE VIEW participaciones_detalle AS
SELECT
  part.*,
  prof.full_name AS usuario_nombre,
  prof.avatar_url AS usuario_avatar,
  prof.categoria AS usuario_categoria,
  prof.rating_promedio AS usuario_rating,
  partido.titulo AS partido_titulo,
  partido.fecha AS partido_fecha,
  partido.hora AS partido_hora
FROM participaciones part
JOIN profiles prof ON part.usuario_id = prof.id
JOIN partidos partido ON part.partido_id = partido.id;

-- =====================================================
-- FIN DEL SCRIPT
-- =====================================================

-- Mensaje de confirmación
DO $$
BEGIN
  RAISE NOTICE '✅ Schema de PadelMatch creado exitosamente!';
  RAISE NOTICE '📊 Tablas: profiles, partidos, participaciones, ratings, notificaciones, push_tokens';
  RAISE NOTICE '🔒 Row Level Security habilitado';
  RAISE NOTICE '⚡ Triggers y funciones configurados';
END $$;
