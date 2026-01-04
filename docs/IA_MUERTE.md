# IA de La Muerte - Documentación Técnica

## Índice
1. [Descripción General](#descripción-general)
2. [Arquitectura](#arquitectura)
3. [Sistema de Evaluación](#sistema-de-evaluación)
4. [Estrategia de Juego](#estrategia-de-juego)
5. [Decisiones de Envido](#decisiones-de-envido)
6. [Decisiones de Truco](#decisiones-de-truco)
7. [Flujo de Integración](#flujo-de-integración)
8. [Ajuste de Dificultad](#ajuste-de-dificultad)

---

## Descripción General

La IA de La Muerte (`scenes/truco/ia_muerte.gd`) es un sistema estratégico por niveles diseñado para jugar Truco Argentino de manera inteligente y realista. La IA no hace trampa - solo conoce sus propias cartas y toma decisiones basadas en probabilidad, fuerza de mano y situación de partida.

**Características principales:**
- Sistema de evaluación de cartas y manos (0-100)
- Estrategia adaptativa según la ronda (1, 2 o 3)
- Decisiones probabilísticas de Truco/Envido
- Comportamiento realista con bluffing ocasional
- 100% métodos estáticos (sin estado interno)

---

## Arquitectura

### Organización por Niveles

La IA está estructurada en 4 niveles jerárquicos:

```
NIVEL 1: Evaluación Básica
├── evaluar_fuerza_carta()      # 0-100 por carta
├── evaluar_fuerza_mano()       # 0-100 ponderado
└── categorizar_mano()          # excelente/buena/regular/mala

NIVEL 2: Estrategia por Ronda
├── seleccionar_carta_estrategico()
├── estrategia_ronda_1()        # Tanteo
├── estrategia_ronda_2()        # Ajuste según R1
└── estrategia_ronda_3()        # Todo o nada

NIVEL 3: Decisiones de Truco
├── debe_cantar_truco()
├── responder_truco()
└── debe_irse_al_mazo()

NIVEL 4: Decisiones de Envido
├── debe_cantar_envido()
├── responder_envido()
└── debe_cantar_falta_envido()
```

### Principios de Diseño

1. **Sin estado interno**: Todos los métodos son estáticos
2. **Contexto explícito**: Toda la información se pasa por parámetros
3. **Probabilidad realista**: Usa `randf()` para variabilidad
4. **Separación de responsabilidades**: Cada nivel tiene un propósito claro

---

## Sistema de Evaluación

### Evaluación de Cartas Individuales

```gdscript
static func evaluar_fuerza_carta(carta: Carta) -> float
```

**Entrada**: Una carta con su valor de truco (1-14)

**Salida**: Fuerza normalizada (0-100)

**Fórmula**:
```
fuerza = (valor_truco / 14.0) * 100.0
```

**Ejemplos**:
- 1 de Espadas (valor 14) → 100.0
- 7 de Oros (valor 11) → 78.6
- 4 de cualquier palo (valor 1) → 7.1

### Evaluación de Mano Completa

```gdscript
static func evaluar_fuerza_mano(cartas: Array) -> float
```

**Ponderación**:
- Carta más fuerte: **50%**
- Segunda carta: **30%**
- Tercera carta: **20%**

**Ejemplo**:
```
Mano: [1 Espadas (100), 7 Oros (78.6), 4 Oros (7.1)]
Fuerza = 100*0.5 + 78.6*0.3 + 7.1*0.2
       = 50 + 23.58 + 1.42
       = 75.0 (Excelente)
```

### Categorización de Mano

```gdscript
static func categorizar_mano(fuerza: float) -> String
```

| Rango | Categoría | Descripción |
|-------|-----------|-------------|
| 75-100 | `excelente` | Al menos una carta muy fuerte |
| 55-74 | `buena` | Mano sólida |
| 35-54 | `regular` | Mano promedio |
| 0-34 | `mala` | Mano débil |

---

## Estrategia de Juego

### Contexto de Decisión

Todas las funciones estratégicas reciben un diccionario de contexto:

```gdscript
var contexto = {
    "ronda_actual": int,           # 1, 2 o 3
    "resultado_ronda_1": int,      # 0=no jugada, 1=jugador, 2=muerte, 3=empate
    "resultado_ronda_2": int,
    "es_mano": bool,               # ¿La Muerte es mano?
    "carta_jugador": Carta,        # Carta jugada por el jugador (o null)
    "puntos_jugador": int,
    "puntos_muerte": int,
    "puntos_para_ganar": int,
    "estado_truco": int,
    "puntos_en_juego": int
}
```

### Ronda 1: Estrategia de Tanteo

```gdscript
static func estrategia_ronda_1(cartas: Array, es_mano: bool, carta_jugador: Carta) -> Carta
```

#### Si la Muerte es MANO (juega primero):
- **Mano muy mala** (fuerza < 25): Juega la peor carta
- **Mano normal/buena**: Juega carta media para tantear

#### Si la Muerte es PIE (juega segundo):
- Busca la carta más débil que le gane al jugador
- Si no puede ganar sin desperdiciar (diferencia > 5): Sacrifica la peor
- **Objetivo**: Conservar cartas fuertes para rondas 2 y 3

**Ejemplo**:
```gdscript
# Muerte tiene: [12 Copa (50.0), 7 Copa (28.6), 5 Basto (14.3)]
# Jugador jugó: 6 Oro (21.4)

# IA busca carta que gane con menor diferencia:
# - 12 Copa: gana, diferencia = 50.0 - 21.4 = 28.6 (muy alta)
# - 7 Copa: gana, diferencia = 28.6 - 21.4 = 7.2 (alta)
# - 5 Basto: pierde

# Diferencia > 5 → Juega la peor (5 Basto) para conservar las buenas
```

### Ronda 2: Estrategia de Ajuste

```gdscript
static func estrategia_ronda_2(cartas: Array, resultado_r1: int, es_mano: bool, carta_jugador: Carta) -> Carta
```

#### Si GANÓ la Ronda 1 (resultado_r1 == 2):
- **Es mano**: Juega carta media (puede arriesgar)
- **Es pie**: Responde conservadoramente

#### Si PERDIÓ la Ronda 1 (resultado_r1 == 1):
- **CRÍTICO**: Debe ganar esta ronda o pierde la mano
- Juega la **mejor carta disponible**

#### Si EMPATÓ la Ronda 1 (resultado_r1 == 3):
- Esta ronda es decisiva
- Juega la mejor carta

**Tabla de decisión**:

| Resultado R1 | Es Mano | Es Pie | Estrategia |
|--------------|---------|--------|------------|
| Ganó (2) | ✓ | - | Carta media |
| Ganó (2) | - | ✓ | Primera que gane |
| Perdió (1) | ✓/- | ✓/- | **Mejor carta** |
| Empate (3) | ✓/- | ✓/- | Mejor carta |

### Ronda 3: Todo o Nada

```gdscript
static func estrategia_ronda_3(cartas: Array, ...) -> Carta
```

- Solo queda una carta
- Se juega sin opción
- Aquí podría evaluarse irse al mazo (no implementado aún)

---

## Decisiones de Envido

### Cuándo Cantar Envido

```gdscript
static func debe_cantar_envido(contexto: Dictionary) -> bool
```

**Condiciones base**:
- Solo en **Ronda 1** (antes de jugar carta)
- `estado_envido == NINGUNO`

**Probabilidades según puntos de envido**:

| Puntos Envido | Categoría | Probabilidad Base | Con Presión |
|---------------|-----------|-------------------|-------------|
| 28+ | Excelente | 80% | 90% |
| 25-27 | Muy bueno | 50% | 70% |
| 22-24 | Bueno | 30% | 50% |
| 18-21 | Regular | 0% | 20% (bluff) |
| < 18 | Bajo | 0% | 5% (bluff extremo) |

**Factores de presión**:
- `esta_cerca_de_ganar`: Falta <= 5 puntos para ganar
- `esta_perdiendo`: Jugador lleva +3 puntos de ventaja

**Ejemplo**:
```gdscript
# Muerte tiene 26 de envido
# Puntos: Muerte 8, Jugador 12
# Faltantes: Muerte 7, Jugador 3

# esta_perdiendo = 12 > 8 + 3 = true
# Probabilidad = 70% (muy bueno + perdiendo)
```

### Cómo Responder al Envido

```gdscript
static func responder_envido(contexto: Dictionary) -> String
```

**Retorna**: `"envido"`, `"real_envido"`, `"falta_envido"`, `"quiero"`, `"no_quiero"`

**Lógica por nivel de envido**:

#### Envido Excelente (28+)
```gdscript
# Estado: ENVIDO
if randf() < 0.6:
    return "real_envido"  # 60% sube a real
elif randf() < 0.3:
    return "envido"       # 30% sube a envido-envido
else:
    return "quiero"       # 10% acepta directo
```

#### Envido Muy Bueno (25-27)
- **ENVIDO**: 30% sube, 70% acepta
- **REAL ENVIDO**: 70% acepta, 30% rechaza
- **FALTA ENVIDO**: Depende de situación

#### Envido Bueno (22-24)
- **ENVIDO**: 60% acepta, 40% rechaza
- **ENVIDO-ENVIDO**: 40% acepta, 60% rechaza
- **REAL/FALTA**: Rechaza

#### Envido Regular/Bajo (< 22)
- Generalmente rechaza
- Acepta solo si está cerca de ganar y es un último intento

### Falta Envido

```gdscript
static func debe_cantar_falta_envido(contexto: Dictionary) -> bool
```

**Condiciones**:
1. `puntos_envido >= 28` (excelente)
2. `puntos_muerte + puntos_falta >= PUNTOS_PARA_GANAR`
3. Probabilidad: **40%** (movimiento arriesgado)

**Ejemplo**:
```gdscript
# Muerte tiene 30 de envido
# Puntos para ganar: 15
# Muerte: 10 puntos, Jugador: 8 puntos
# Falta envido vale: 15 - 8 = 7 puntos

# Si gana: 10 + 7 = 17 >= 15 → ¡GANA LA PARTIDA!
# Probabilidad de cantar: 40%
```

---

## Decisiones de Truco

### Cuándo Cantar Truco

```gdscript
static func debe_cantar_truco(cartas: Array, contexto: Dictionary) -> bool
```

**Condiciones base**:
- Solo en **Ronda 1 o 2**
- `estado_truco == NINGUNO`

**Probabilidades según fuerza de mano**:

| Fuerza Mano | Base | Cerca de Ganar | Perdiendo Mucho |
|-------------|------|----------------|-----------------|
| 75+ (Excelente) | 70% | 70% | 70% |
| 55-74 (Buena) | 30% | 50% | 50% |
| 35-54 (Regular) | 0% | 0% | 30% (bluff) |
| < 35 (Mala) | 0% | 0% | 5% (bluff extremo) |

**Factores**:
- `esta_cerca_de_ganar`: Faltan <= 5 puntos
- `esta_perdiendo_mucho`: Jugador lleva +5 puntos

### Cómo Responder al Truco

```gdscript
static func responder_truco(cartas: Array, contexto: Dictionary) -> String
```

**Retorna**: `"retruco"`, `"vale_cuatro"`, `"quiero"`, `"no_quiero"`

**Matriz de decisión**:

| Fuerza | Estado: TRUCO | Estado: RETRUCO | Estado: VALE_CUATRO |
|--------|---------------|-----------------|---------------------|
| 75+ | 70% retruco, 30% quiero | 50% vale_cuatro, 50% quiero | Quiero |
| 55-74 | 30% retruco, 70% quiero | Quiero | Quiero |
| 35-54 | Depende situación | Depende situación | No quiero |
| < 35 | No quiero (excepto si muy cerca de ganar) | No quiero | No quiero |

**Casos especiales**:

```gdscript
# Si está MUY cerca de ganar (faltan <= puntos_en_juego + 2)
if esta_cerca_de_ganar and fuerza >= 45:
    if fuerza >= 70:
        return "retruco"  # Agresivo
    return "quiero"       # Conservador
```

### Irse al Mazo

```gdscript
static func debe_irse_al_mazo(cartas: Array, contexto: Dictionary) -> bool
```

**Criterios**:
- `puntos_en_juego > 1` (no vale la pena irse por 1 punto)
- `puntos_faltantes > 3` (no irse si está muy cerca de ganar)

**Por ronda**:
- **Ronda 1**: Si `fuerza < 20` y `puntos_en_juego >= 3` → 40%
- **Ronda 2**: Si perdió R1, `fuerza < 30` y `puntos_en_juego >= 3` → 50%
- **Ronda 3**: Casi nunca (ya invertiste 2 cartas)

---

## Flujo de Integración

### En el archivo `truco.gd`

#### 1. Turno de la Muerte

```gdscript
func turno_muerte():
    # 1. Evaluar ENVIDO (solo ronda 1)
    if ronda_actual == 1 and not envido_ya_cantado:
        if await ia_evaluar_cantar_envido():
            return  # Espera respuesta del jugador

    # 2. Evaluar TRUCO (rondas 1 o 2)
    if ronda_actual <= 2 and estado_truco == EstadoTruco.NINGUNO:
        await ia_evaluar_cantar_truco()
        # Ahora continúa jugando carta (no espera respuesta)

    # 3. Preparar contexto
    var contexto = {
        "ronda_actual": ronda_actual,
        "resultado_ronda_1": resultado_ronda_1,
        "resultado_ronda_2": resultado_ronda_2,
        "es_mano": not es_mano_jugador,
        "carta_jugador": carta_jugada_jugador
    }

    # 4. Seleccionar carta estratégicamente
    var carta = IAMuerte.seleccionar_carta_estrategico(cartas_muerte, contexto)

    # 5. Jugar carta
    jugar_carta_muerte(carta)
```

#### 2. Evaluación de Envido

```gdscript
func ia_evaluar_cantar_envido() -> bool:
    var fuerza_mano = IAMuerte.evaluar_fuerza_mano(cartas_muerte)

    var contexto = {
        "puntos_envido_muerte": puntos_envido_muerte,
        "puntos_muerte": puntos_muerte,
        "puntos_jugador": puntos_jugador,
        "puntos_para_ganar": PUNTOS_PARA_GANAR,
        "fuerza_mano": fuerza_mano,
        "ronda_actual": ronda_actual
    }

    # IA decide si cantar
    if IAMuerte.debe_cantar_envido(contexto):
        # Considerar falta envido
        if IAMuerte.debe_cantar_falta_envido(contexto):
            await ia_cantar_falta_envido()
            return true
        else:
            await ia_cantar_envido()
            return true

    return false
```

#### 3. Respuesta del Jugador

```gdscript
func muerte_responde_envido():
    var contexto = {
        "puntos_envido_muerte": puntos_envido_muerte,
        "estado_envido": int(estado_envido),
        "puntos_envido_en_juego": puntos_envido_en_juego,
        # ... más contexto
    }

    var respuesta = IAMuerte.responder_envido(contexto)

    match respuesta:
        "envido":
            muerte_sube_envido("envido")
        "real_envido":
            muerte_sube_envido("real_envido")
        "falta_envido":
            muerte_sube_envido("falta_envido")
        "quiero":
            await resolver_envido()
        "no_quiero":
            # Dar puntos al jugador
            puntos_jugador += calcular_puntos_rechazo_envido()
```

#### 4. Continuación de Turno

Después de resolver envido/truco, si la Muerte cantó y aún no jugó carta:

```gdscript
func _on_quiero_envido_pressed():
    await resolver_envido()

    # Si la Muerte cantó el envido y aún no jugó carta
    if not envido_cantado_por_jugador and not es_turno_jugador and not carta_jugada_muerte:
        await get_tree().create_timer(1.0).timeout
        turno_muerte()  # Continúa su turno
```

---

## Ajuste de Dificultad

### Parámetros Configurables

Para modificar la dificultad, ajusta las probabilidades en `ia_muerte.gd`:

#### Dificultad FÁCIL
```gdscript
# En debe_cantar_truco():
if fuerza >= 75:
    return randf() < 0.4  # Reducido de 0.7

# En responder_truco():
if fuerza >= 75:
    if estado_truco == 1 and randf() < 0.3:  # Reducido de 0.7
        return "retruco"
```

#### Dificultad DIFÍCIL
```gdscript
# En debe_cantar_truco():
if fuerza >= 55:  # Reducido de 75
    return randf() < 0.8  # Aumentado

# En debe_cantar_envido():
if puntos_envido >= 22:  # Reducido de 28
    return randf() < 0.9
```

#### Dificultad EXPERTO
```gdscript
# Hacer que la IA "vea" la carta del jugador en ronda 1
if carta_jugador:
    var valor_jugador = carta_jugador.obtener_valor_truco()
    # Ajustar decisión basada en esto
```

### Valores Recomendados

| Parámetro | Fácil | Normal | Difícil |
|-----------|-------|--------|---------|
| Probabilidad truco (fuerza 75+) | 40% | 70% | 85% |
| Probabilidad envido (28+) | 50% | 80% | 95% |
| Umbral fuerza mano | 75 | 75 | 55 |
| Bluffing | Raro | Ocasional | Frecuente |

### Debug y Testing

Activa el debug para ver decisiones de la IA:

```gdscript
# En truco.gd, línea 373
IAMuerte.debug_mano(cartas_muerte)  # Descomentar esta línea
```

**Salida**:
```
=== DEBUG IA MUERTE ===
Cartas en mano:
  - 1 de ESPADA | Valor: 14 | Fuerza: 100.0
  - 7 de ORO | Valor: 11 | Fuerza: 78.6
  - 5 de BASTO | Valor: 2 | Fuerza: 14.3
Fuerza de mano: 75.0 (excelente)
=======================
```

---

## Ejemplos Completos

### Ejemplo 1: Decisión de Envido

```gdscript
# Situación:
# - Ronda 1
# - Muerte tiene: [6 ORO, 7 ORO, 2 COPA] → Envido 33 (6+7+20)
# - Puntos: Muerte 5, Jugador 8
# - Fuerza mano: 45 (regular)

var contexto = {
    "puntos_envido_muerte": 33,
    "puntos_muerte": 5,
    "puntos_jugador": 8,
    "puntos_para_ganar": 15,
    "fuerza_mano": 45.0,
    "ronda_actual": 1
}

# IA evalúa:
# - puntos_envido = 33 → EXCELENTE (>= 28)
# - esta_perdiendo = 8 > 5 + 3 = false
# - Probabilidad base: 80%

if IAMuerte.debe_cantar_envido(contexto):  # 80% true
    # Evalúa falta envido:
    # - puntos_falta = 15 - 8 = 7
    # - Si gana: 5 + 7 = 12 (no llega a 15)
    # - No canta falta

    # Canta envido normal
    await ia_cantar_envido()
```

### Ejemplo 2: Selección de Carta

```gdscript
# Situación:
# - Ronda 2
# - Muerte tiene: [3 BASTO (71.4), 5 ORO (14.3)]
# - Resultado R1: Jugador ganó (1)
# - Jugador jugó: 12 ESPADA (50.0)

var contexto = {
    "ronda_actual": 2,
    "resultado_ronda_1": 1,  # Perdió la primera
    "es_mano": false,
    "carta_jugador": carta_12_espada
}

# IA evalúa estrategia_ronda_2:
# - resultado_r1 == 1 → PERDIÓ R1
# - DEBE ganar esta ronda o pierde la mano
# - Juega la MEJOR carta disponible

var carta = IAMuerte.seleccionar_carta_estrategico(cartas_muerte, contexto)
# Retorna: 3 BASTO (71.4)
```

### Ejemplo 3: Respuesta a Truco

```gdscript
# Situación:
# - Jugador canta TRUCO
# - Muerte tiene: [7 ESPADA (85.7), 4 ORO (7.1)]
# - Fuerza mano: 50.0 (regular-buena)
# - Puntos: Muerte 12, Jugador 10
# - Ronda 1

var contexto = {
    "ronda_actual": 1,
    "puntos_jugador": 10,
    "puntos_muerte": 12,
    "puntos_para_ganar": 15,
    "estado_truco": 1,  # TRUCO
    "puntos_en_juego": 2
}

# IA evalúa:
# - fuerza = 50.0 → entre 35-54 (regular)
# - esta_perdiendo_mucho = 10 > 12 + 7 = false
# - No está cerca de ganar

# Decisión: 50% quiero, 50% no quiero (depende de randf)
var respuesta = IAMuerte.responder_truco(cartas_muerte, contexto)
```

---

## Notas Técnicas

### Performance
- Todas las funciones son O(n) donde n = cantidad de cartas (máximo 3)
- Sin asignaciones dinámicas pesadas
- `randf()` se llama múltiples veces por decisión (variabilidad)

### Testing
Para testear la IA aisladamente:

```gdscript
# Crear cartas de prueba
var carta1 = Carta.new()
carta1.setup(1, Carta.Palo.ESPADA)  # Ancho de espadas

var carta2 = Carta.new()
carta2.setup(7, Carta.Palo.ORO)     # Siete de oros

var cartas = [carta1, carta2]

# Evaluar
var fuerza = IAMuerte.evaluar_fuerza_mano(cartas)
print(fuerza)  # ~89.3 (excelente)

var categoria = IAMuerte.categorizar_mano(fuerza)
print(categoria)  # "excelente"
```

### Extensiones Futuras

Ideas para mejorar la IA:

1. **Memoria de partida**: Recordar patrones de juego del jugador
2. **Conteo de cartas**: Inferir cartas restantes en el mazo
3. **Psicología**: Detectar si el jugador hace bluff frecuente
4. **Niveles de dificultad**: Presets configurables
5. **Machine Learning**: Entrenar con partidas reales

---

## Recursos Adicionales

- **Reglas del Truco**: [Wikipedia - Truco Argentino](https://es.wikipedia.org/wiki/Truco_argentino)
- **Código fuente**: `scenes/truco/ia_muerte.gd`
- **Integración**: `scenes/truco/truco.gd`
- **Valores de cartas**: `scenes/truco/carta.gd::obtener_valor_truco()`

---

**Versión**: 1.0.
**Última actualización**: Enero 2026
