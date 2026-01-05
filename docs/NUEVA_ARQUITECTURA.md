# 🏗️ Nueva Arquitectura del Proyecto - La Odisea del Gaucho

> **Versión:** 2.0
> **Fecha:** 2026-01-05
> **Estado:** Propuesta - Pendiente de implementación

---

## 📋 Tabla de Contenidos

1. [Motivación](#-motivación)
2. [Estructura de Carpetas](#-estructura-de-carpetas)
3. [Core - Núcleo del Juego](#-core---núcleo-del-juego)
4. [Systems - Sistemas Independientes](#-systems---sistemas-independientes)
5. [Entities - Entidades del Juego](#-entities---entidades-del-juego)
6. [UI - Interfaces de Usuario](#-ui---interfaces-de-usuario)
7. [Scenes - Escenas Principales](#-scenes---escenas-principales)
8. [Data - Datos del Juego](#-data---datos-del-juego)
9. [Diagramas de Arquitectura](#-diagramas-de-arquitectura)
10. [Guía de Migración](#-guía-de-migración)
11. [Convenciones y Reglas](#-convenciones-y-reglas)

---

## 🎯 Motivación

### Problemas de la Arquitectura Actual

#### ❌ **Scripts Monstruosos**
- `truco.gd`: **1189 líneas** (límite recomendado: 300)
- `ia_muerte.gd`: **617 líneas** (límite recomendado: 300)
- Difíciles de mantener, testear y entender

#### ❌ **Organización por Tipo**
```
❌ Actual:
scenes/
  cinematica/
  jugador/
  obstaculo/
  truco/
scripts/
  dialogue_manager.gd
  game_manager.gd
```

#### ❌ **Responsabilidades Mezcladas**
- `jugador.gd`: física + animación + muerte + colisiones + audio
- `GameManager`: estado + velocidad + mates + vidas + config + transiciones
- Sin separación entre lógica y presentación

### Objetivos de la Nueva Arquitectura

✅ **Todos los scripts < 300 líneas**
✅ **Una responsabilidad por script**
✅ **Separación lógica/presentación (Controllers/Visual)**
✅ **Organización por funcionalidad**
✅ **Escalable y mantenible**
✅ **Comunicación por signals (bajo acoplamiento)**

---

## 📁 Estructura de Carpetas

```
gaucholand/
├── core/                          # 🎯 Lógica fundamental
│   ├── game_manager.gd
│   ├── difficulty_manager.gd
│   ├── config_manager.gd
│   └── scene_manager.gd
│
├── systems/                       # 🔧 Sistemas independientes
│   ├── dialogue/
│   │   ├── dialogue_manager.gd
│   │   ├── dialogue_loader.gd
│   │   └── dialogue_ui.tscn
│   │
│   ├── spawning/
│   │   ├── obstacle_spawner.tscn
│   │   ├── obstacle_spawner.gd
│   │   ├── mate_spawner.tscn
│   │   └── mate_spawner.gd
│   │
│   ├── score/
│   │   └── score_manager.gd
│   │
│   ├── lives/
│   │   └── lives_manager.gd
│   │
│   └── audio/
│       └── audio_manager.gd
│
├── entities/                      # 🎮 Entidades del juego
│   ├── player/
│   │   ├── player.tscn
│   │   ├── player_controller.gd
│   │   ├── player_visual.gd
│   │   ├── player_death.gd
│   │   └── player_collision.gd
│   │
│   ├── obstacles/
│   │   ├── obstacle.tscn
│   │   ├── obstacle.gd
│   │   └── obstacle_types.gd
│   │
│   ├── collectibles/
│   │   ├── mate.tscn
│   │   └── mate.gd
│   │
│   └── environment/
│       ├── ground.tscn
│       └── ground.gd
│
├── ui/                            # 🖼️ Interfaces de usuario
│   ├── menus/
│   │   ├── main_menu/
│   │   ├── pause_menu/
│   │   └── config_menu/
│   │
│   ├── hud/
│   │   ├── score_display.tscn
│   │   └── lives_display.tscn
│   │
│   ├── screens/
│   │   ├── game_over/
│   │   ├── congratulations/
│   │   └── how_to_play/
│   │
│   └── dialogue/
│       ├── dialogue_box.tscn
│       └── dialogue_box.gd
│
├── scenes/                        # 🎬 Escenas principales
│   ├── levels/
│   │   ├── base_level.tscn
│   │   └── pampa_level.tscn
│   │
│   ├── cinematics/
│   │   ├── intro_cinematic/
│   │   └── rancho_transition/
│   │
│   └── truco_game/
│       ├── truco_game.tscn
│       ├── truco_controller.gd
│       ├── truco_ui.gd
│       ├── truco_state.gd
│       ├── truco_rules.gd
│       ├── envido_system.gd
│       ├── truco_betting.gd
│       ├── ai_muerte.gd
│       ├── ai_strategy.gd
│       ├── ai_decision.gd
│       ├── card.tscn
│       ├── card.gd
│       ├── deck.gd
│       └── hand_evaluator.gd
│
├── data/                          # 📊 Datos del juego
│   ├── dialogues/
│   ├── config/
│   └── cards/
│
├── assets/                        # 🎨 Recursos
│   ├── sprites/
│   ├── sounds/
│   ├── music/
│   └── fonts/
│
└── docs/                          # 📚 Documentación
    ├── CLAUDE.md
    ├── BUENAS_PRACTICAS.md
    └── NUEVA_ARQUITECTURA.md
```

---

## 🎯 Core - Núcleo del Juego

Contiene los **autoloads** (singletons) y lógica fundamental del juego.

### `core/game_manager.gd`

**Responsabilidad:** Estado global básico del juego

```gdscript
extends Node

# Señales
signal game_started()
signal game_ended()
signal game_paused(paused: bool)

# Estado mínimo
var is_game_running: bool = false
var current_level: String = ""

func start_game() -> void:
    is_game_running = true
    game_started.emit()

func end_game() -> void:
    is_game_running = false
    game_ended.emit()
```

**Tamaño estimado:** ~100 líneas
**Migración desde:** `scripts/game_manager.gd` (extraer solo estado básico)

---

### `core/difficulty_manager.gd`

**Responsabilidad:** Sistema de dificultad progresiva

```gdscript
extends Node

signal velocidad_cambiada(nueva_velocidad: float)

const VELOCIDAD_BASE: float = 200.0
const INCREMENTO_VELOCIDAD: float = 10.0
const MATES_POR_NIVEL: int = 10

var velocidad_actual: float = VELOCIDAD_BASE
var nivel_actual: int = 0

func aumentar_dificultad() -> void:
    nivel_actual += 1
    velocidad_actual = VELOCIDAD_BASE + (nivel_actual * INCREMENTO_VELOCIDAD)
    velocidad_cambiada.emit(velocidad_actual)

func reiniciar() -> void:
    nivel_actual = 0
    velocidad_actual = VELOCIDAD_BASE
    velocidad_cambiada.emit(velocidad_actual)
```

**Tamaño estimado:** ~80 líneas
**Migración desde:** `scripts/game_manager.gd` (extraer sistema de velocidad)

---

### `core/config_manager.gd`

**Responsabilidad:** Gestión de configuración del juego

```gdscript
extends Node

signal config_changed(key: String, value: Variant)

const CONFIG_FILE: String = "user://settings.cfg"
var config: ConfigFile = ConfigFile.new()

func cargar_configuracion() -> void:
    var err = config.load(CONFIG_FILE)
    if err == OK:
        aplicar_audio()
        aplicar_video()

func guardar_configuracion() -> void:
    config.save(CONFIG_FILE)

func aplicar_audio() -> void:
    var volumen = config.get_value("audio", "volumen_musica", 80)
    var db = linear_to_db(volumen / 100.0)
    AudioServer.set_bus_volume_db(0, db)

func aplicar_video() -> void:
    var fullscreen = config.get_value("video", "pantalla_completa", false)
    if fullscreen:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
```

**Tamaño estimado:** ~120 líneas
**Migración desde:** `scripts/game_manager.gd` (extraer configuración)

---

### `core/scene_manager.gd`

**Responsabilidad:** Transiciones entre escenas con efectos

```gdscript
extends Node

signal transition_started()
signal transition_finished()

var en_transicion: bool = false

func cambiar_escena_con_fade(ruta: String, duracion: float = 1.0) -> void:
    en_transicion = true
    transition_started.emit()

    # Fade out
    await crear_fade(0.0, 1.0, duracion / 2)

    # Cambiar escena
    get_tree().change_scene_to_file(ruta)

    # Fade in
    await crear_fade(1.0, 0.0, duracion / 2)

    en_transicion = false
    transition_finished.emit()

func slow_motion(escala: float, duracion: float) -> void:
    Engine.time_scale = escala
    await get_tree().create_timer(duracion).timeout
    Engine.time_scale = 1.0
```

**Tamaño estimado:** ~150 líneas
**Migración desde:** `scripts/game_manager.gd` (extraer transiciones)

---

## 🔧 Systems - Sistemas Independientes

Módulos autónomos que proporcionan funcionalidad específica.

### `systems/dialogue/`

Sistema completo de diálogos con typewriter effect.

**Archivos:**
- `dialogue_manager.gd` - Gestión de diálogos y estados
- `dialogue_loader.gd` - Carga de CSVs
- `dialogue_ui.tscn` - UI del diálogo

**Migración desde:** `scripts/dialogue_*.gd` y `scenes/dialogue_ui/`

---

### `systems/spawning/`

Sistema de generación de obstáculos y coleccionables.

**Archivos:**
- `obstacle_spawner.tscn` + `obstacle_spawner.gd`
- `mate_spawner.tscn` + `mate_spawner.gd`

**Responsabilidad:** Spawning basado en distancia, sincronización de velocidad

**Migración desde:** `scenes/obstaculo/obstacle_spawner.*` y `scenes/puntaje/mate_spawner.*`

---

### `systems/score/`

**`score_manager.gd`**

```gdscript
extends Node

signal mates_cambiados(nuevos_mates: int)
signal objetivo_alcanzado()

const OBJETIVO_MATES: int = 100

var mates_totales: int = 0

func agregar_mates(cantidad: int) -> void:
    mates_totales += cantidad
    mates_cambiados.emit(mates_totales)

    if mates_totales >= OBJETIVO_MATES:
        objetivo_alcanzado.emit()

func reiniciar() -> void:
    mates_totales = 0
    mates_cambiados.emit(mates_totales)
```

**Tamaño estimado:** ~60 líneas
**Migración desde:** `scripts/game_manager.gd` (extraer sistema de mates)

---

### `systems/lives/`

**`lives_manager.gd`**

```gdscript
extends Node

signal vidas_cambiadas(vidas_restantes: int)
signal sin_vidas()

const MAX_VIDAS: int = 3
var vidas: int = MAX_VIDAS

func descontar_vida() -> bool:
    vidas -= 1
    vidas_cambiadas.emit(vidas)

    if vidas <= 0:
        sin_vidas.emit()
        return false

    return true

func reiniciar() -> void:
    vidas = MAX_VIDAS
    vidas_cambiadas.emit(vidas)
```

**Tamaño estimado:** ~50 líneas
**Migración desde:** `scripts/game_manager.gd` (extraer sistema de vidas)

---

### `systems/audio/`

**`audio_manager.gd`**

```gdscript
extends Node

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []

func play_music(stream: AudioStream, fade_duration: float = 1.0) -> void:
    # Fade out música actual
    # Fade in nueva música
    pass

func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
    # Pool de AudioStreamPlayers para SFX
    pass

func stop_all() -> void:
    pass
```

**Tamaño estimado:** ~100 líneas
**Nueva funcionalidad** - Centralizar audio

---

## 🎮 Entities - Entidades del Juego

Objetos del juego con comportamiento.

### `entities/player/`

**Separación de responsabilidades en 4 scripts:**

#### **`player_controller.gd`** (~100 líneas)

```gdscript
extends Node

# Referencias
@onready var body: CharacterBody2D = get_parent()
@onready var visual: PlayerVisual = $"../PlayerVisual"
@onready var collision_mgr: PlayerCollision = $"../CollisionManager"

@export var gravity: float = 1000.0
@export var jump_force: float = -420.0

var esta_vivo: bool = true
var esta_agachado: bool = false

func _physics_process(delta: float) -> void:
    if not esta_vivo:
        return

    # Física
    body.velocity.y += gravity * delta

    # Input
    manejar_input()

    body.move_and_slide()

func manejar_input() -> void:
    if Input.is_action_just_pressed("salto") and body.is_on_floor() and not esta_agachado:
        saltar()

    if Input.is_action_pressed("agacharse") and body.is_on_floor():
        agacharse()
    else:
        levantarse()

func saltar() -> void:
    body.velocity.y = jump_force
    visual.play_animation("salto")

func agacharse() -> void:
    if esta_agachado:
        return

    esta_agachado = true
    visual.play_animation("agacharse")
    collision_mgr.reducir_colision()

func levantarse() -> void:
    if not esta_agachado:
        return

    esta_agachado = false
    visual.play_animation("correr")
    collision_mgr.restaurar_colision()
```

**Responsabilidad:** Física, input, lógica de movimiento
**Tamaño:** ~100 líneas

---

#### **`player_visual.gd`** (~50 líneas)

```gdscript
extends Node

@onready var sprite: AnimatedSprite2D = $"../AnimatedSprite2D"

func play_animation(anim_name: String) -> void:
    if sprite.animation != anim_name:
        sprite.play(anim_name)

func set_tint(color: Color) -> void:
    sprite.modulate = color

func parpadeo_invencibilidad() -> void:
    var tween = create_tween()
    tween.set_loops(6)
    tween.tween_property(sprite, "modulate:a", 0.5, 0.1)
    tween.tween_property(sprite, "modulate:a", 1.0, 0.1)
```

**Responsabilidad:** Animaciones y efectos visuales
**Tamaño:** ~50 líneas

---

#### **`player_death.gd`** (~80 líneas)

```gdscript
extends Node

signal muerte_completada()

@onready var visual: PlayerVisual = $"../PlayerVisual"
@onready var sfx_morir: AudioStreamPlayer = $"../SonidoMorir"

func iniciar_secuencia_muerte(causa: String) -> void:
    # 1. Slow motion
    Engine.time_scale = 0.3

    # 2. Animación de muerte
    var tween = create_tween()
    tween.tween_property(visual.sprite, "rotation", -PI/4, 0.3)
    tween.parallel().tween_property(visual.sprite, "modulate", Color(1, 0.3, 0.3), 0.3)

    # 3. Sonido
    sfx_morir.play()

    await get_tree().create_timer(0.4).timeout

    # 4. Fade a negro
    await crear_fade_negro()

    # 5. Cambiar a game over
    Engine.time_scale = 1.0
    get_tree().change_scene_to_file("res://ui/screens/game_over/game_over.tscn")

    muerte_completada.emit()

func crear_fade_negro() -> void:
    # Implementación del fade
    pass
```

**Responsabilidad:** Secuencia cinemática de muerte
**Tamaño:** ~80 líneas

---

#### **`player_collision.gd`** (~40 líneas)

```gdscript
extends Node

@onready var collision: CollisionShape2D = $"../CollisionShape2D"

var tamano_original: Vector2
var posicion_original: Vector2

func _ready() -> void:
    tamano_original = collision.shape.size
    posicion_original = collision.position

func reducir_colision(factor: float = 0.5) -> void:
    collision.shape.size.y = tamano_original.y * factor
    var offset = tamano_original.y * (1 - factor) / 2
    collision.position.y = posicion_original.y + offset

func restaurar_colision() -> void:
    collision.shape.size = tamano_original
    collision.position = posicion_original
```

**Responsabilidad:** Manejo dinámico de colisiones
**Tamaño:** ~40 líneas

---

#### **Estructura de la escena `player.tscn`:**

```
Player (CharacterBody2D)
├─ PlayerController (Node) → player_controller.gd
├─ PlayerVisual (Node) → player_visual.gd
│  └─ AnimatedSprite2D
├─ PlayerDeath (Node) → player_death.gd
├─ CollisionManager (Node) → player_collision.gd
│  └─ CollisionShape2D
├─ SonidoSalto (AudioStreamPlayer)
└─ SonidoMorir (AudioStreamPlayer)
```

**Migración desde:** `scenes/jugador/jugador.gd` (dividir en 4 scripts)

---

### `entities/obstacles/`

**Archivos:**
- `obstacle.tscn` - Escena del obstáculo
- `obstacle.gd` - Lógica simplificada (~80 líneas)
- `obstacle_types.gd` - Configuración de tipos

**`obstacle_types.gd`:**

```gdscript
class_name ObstacleTypes
extends Resource

enum Tipo {
    CACTUS_ALTO,
    PIEDRA_BAJA,
    ARBUSTO_MEDIO,
    TERO
}

static func get_config(tipo: Tipo) -> Dictionary:
    match tipo:
        Tipo.CACTUS_ALTO:
            return {
                "animation": "cactus_alto",
                "scale": Vector2(1.5, 1.5),
                "collision_size": Vector2(20, 60),
                "y_offset": -30
            }
        Tipo.PIEDRA_BAJA:
            return {
                "animation": "piedra_baja",
                "scale": Vector2(1.2, 1.2),
                "collision_size": Vector2(30, 20),
                "y_offset": -10
            }
        # ...
```

**Migración desde:** `scenes/obstaculo/obstacle.gd` (extraer configuración)

---

### `entities/collectibles/`

**`mate.gd`** - Simplificado, sin cambios mayores

**Migración desde:** `scenes/puntaje/mate.gd`

---

### `entities/environment/`

**`ground.gd`** - Sistema de scrolling infinito

**Migración desde:** `scenes/suelo/suelo.gd`

---

## 🖼️ UI - Interfaces de Usuario

Todas las interfaces visuales del juego.

### `ui/menus/`

- **`main_menu/`** - Menú principal
- **`pause_menu/`** - Menú de pausa
- **`config_menu/`** - Configuración

**Migración desde:** `scenes/menu_principal/`, `scenes/pause_menu/`, `scenes/configuracion/`

---

### `ui/hud/`

**`score_display.tscn` + `score_display.gd`**

```gdscript
extends Control

@onready var label: Label = $Label

func _ready() -> void:
    ScoreManager.mates_cambiados.connect(_on_mates_cambiados)

func _on_mates_cambiados(nuevos_mates: int) -> void:
    label.text = "Mates: %d / 100" % nuevos_mates
```

**Migración desde:** `scenes/puntaje/ui_puntaje.tscn`

---

**`lives_display.tscn` + `lives_display.gd`**

```gdscript
extends Control

@onready var hearts: Array[TextureRect] = []

func _ready() -> void:
    LivesManager.vidas_cambiadas.connect(_on_vidas_cambiadas)

func _on_vidas_cambiadas(vidas: int) -> void:
    for i in hearts.size():
        hearts[i].visible = i < vidas
```

**Nueva funcionalidad** - Mostrar vidas visualmente

---

### `ui/screens/`

- **`game_over/`** - Pantalla de game over
- **`congratulations/`** - Pantalla de victoria
- **`how_to_play/`** - Tutorial

**Migración desde:** `scenes/game_over/`, `scenes/felicitaciones/`, `scenes/como_jugar/`

---

### `ui/dialogue/`

**`dialogue_box.tscn` + `dialogue_box.gd`**

**Migración desde:** `scenes/dialogue_ui/`

---

## 🎬 Scenes - Escenas Principales

Niveles y escenas complejas que coordinan múltiples sistemas.

### `scenes/levels/`

**`base_level.tscn`** - Nivel base con ground, spawners

**`pampa_level.tscn`** - Nivel pampa que instancia base + player + camera

**Migración desde:** `scenes/nivel/nivel.tscn`, `scenes/nivel_pampa/nivel_pampa.tscn`

---

### `scenes/cinematics/`

**`intro_cinematic/`** - Cinemática de inicio

**`rancho_transition/`** - Transición al rancho

**Migración desde:** `scenes/cinematica/`, `scenes/transicion_rancho/`

---

### `scenes/truco_game/`

**⚠️ REFACTORIZACIÓN CRÍTICA - 1189 líneas → 10 archivos**

#### Arquitectura del Truco:

```
TrucoGame (Control)
├─ TrucoController (Node)     → truco_controller.gd
├─ TrucoState (Node)          → truco_state.gd
├─ TrucoRules (Node)          → truco_rules.gd
├─ EnvidoSystem (Node)        → envido_system.gd
├─ TrucoBetting (Node)        → truco_betting.gd
├─ TrucoUI (Node)             → truco_ui.gd
└─ AIMuerte (Node)            → ai_muerte.gd
   ├─ AIStrategy (Node)       → ai_strategy.gd
   └─ AIDecision (Node)       → ai_decision.gd
```

---

#### **`truco_controller.gd`** (~300 líneas)

**Responsabilidad:** Orquestador principal, flujo del juego

```gdscript
extends Node

# Referencias a sistemas
@onready var state: TrucoState = $TrucoState
@onready var rules: TrucoRules = $TrucoRules
@onready var envido_sys: EnvidoSystem = $EnvidoSystem
@onready var betting: TrucoBetting = $TrucoBetting
@onready var ui: TrucoUI = $TrucoUI
@onready var ai: AIMuerte = $AIMuerte

func _ready() -> void:
    inicializar_juego()
    conectar_senales()
    repartir_cartas()

func inicializar_juego() -> void:
    state.resetear_estado()
    ui.actualizar_todo()

func turno_jugador() -> void:
    ui.habilitar_controles_jugador()

func turno_muerte() -> void:
    ui.deshabilitar_controles_jugador()
    await get_tree().create_timer(1.0).timeout
    ai.ejecutar_turno()

func procesar_ronda() -> void:
    var ganador = rules.determinar_ganador_ronda(
        state.carta_jugada_jugador,
        state.carta_jugada_muerte
    )
    state.registrar_resultado_ronda(ganador)

    if rules.es_fin_de_mano(state):
        finalizar_mano()
```

**Divide:** Inicialización, flujo principal, coordinación

---

#### **`truco_state.gd`** (~150 líneas)

**Responsabilidad:** Estado completo del juego

```gdscript
extends Node

# Estado de la partida
var puntos_jugador: int = 0
var puntos_muerte: int = 0

# Estado de la mano
var cartas_jugador: Array = []
var cartas_muerte: Array = []
var ronda_actual: int = 1
var carta_jugada_jugador: Carta = null
var carta_jugada_muerte: Carta = null

# Resultados de rondas
var resultados_rondas: Array[int] = [0, 0, 0]

# Estado de apuestas
var estado_truco: int = 0  # 0=ninguno, 1=truco, 2=retruco, 3=vale4
var estado_envido: int = 0
var puntos_en_juego: int = 1

# Getters/Setters
func agregar_puntos_jugador(puntos: int) -> void:
    puntos_jugador += puntos

func registrar_resultado_ronda(ganador: int) -> void:
    resultados_rondas[ronda_actual - 1] = ganador
    ronda_actual += 1

func resetear_mano() -> void:
    cartas_jugador.clear()
    cartas_muerte.clear()
    ronda_actual = 1
    resultados_rondas = [0, 0, 0]
    estado_truco = 0
    estado_envido = 0
    puntos_en_juego = 1
```

**Divide:** Todo el estado en un solo lugar

---

#### **`truco_rules.gd`** (~200 líneas)

**Responsabilidad:** Reglas del truco, comparación de cartas

```gdscript
extends Node

const JERARQUIA_CARTAS = {
    "1_espadas": 14,
    "1_bastos": 13,
    "7_espadas": 12,
    "7_oros": 11,
    # ...
}

func comparar_cartas(carta1: Carta, carta2: Carta) -> int:
    var valor1 = obtener_valor_truco(carta1)
    var valor2 = obtener_valor_truco(carta2)

    if valor1 > valor2:
        return 1  # Carta1 gana
    elif valor2 > valor1:
        return 2  # Carta2 gana
    else:
        return 3  # Empate

func obtener_valor_truco(carta: Carta) -> int:
    var clave = "%d_%s" % [carta.numero, carta.palo]
    return JERARQUIA_CARTAS.get(clave, carta.numero)

func determinar_ganador_ronda(carta_jugador: Carta, carta_muerte: Carta) -> int:
    return comparar_cartas(carta_jugador, carta_muerte)

func determinar_ganador_mano(resultados: Array[int]) -> int:
    # Lógica de "mejor de 3" con empates
    var victorias_jugador = resultados.count(1)
    var victorias_muerte = resultados.count(2)

    if victorias_jugador > victorias_muerte:
        return 1
    elif victorias_muerte > victorias_jugador:
        return 2
    else:
        # Reglas de empate del truco
        return determinar_empate(resultados)

func es_fin_de_mano(state: TrucoState) -> bool:
    # Termina si alguien ganó 2 rondas o se jugaron las 3
    var victorias_jugador = state.resultados_rondas.count(1)
    var victorias_muerte = state.resultados_rondas.count(2)

    return victorias_jugador >= 2 or victorias_muerte >= 2 or state.ronda_actual > 3
```

**Divide:** Toda la lógica de reglas y comparaciones

---

#### **`envido_system.gd`** (~150 líneas)

**Responsabilidad:** Sistema de envido

```gdscript
extends Node

signal envido_cantado(quien: String, tipo: String)
signal envido_resuelto(ganador: String, puntos: int)

enum TipoEnvido { ENVIDO, ENVIDO_ENVIDO, REAL_ENVIDO, FALTA_ENVIDO }

var puntos_por_tipo = {
    TipoEnvido.ENVIDO: 2,
    TipoEnvido.ENVIDO_ENVIDO: 2,
    TipoEnvido.REAL_ENVIDO: 3,
    TipoEnvido.FALTA_ENVIDO: 0  # Depende del faltante
}

var puntos_acumulados: int = 0
var tipo_actual: TipoEnvido = TipoEnvido.ENVIDO

func cantar_envido(tipo: TipoEnvido, quien: String) -> void:
    tipo_actual = tipo
    puntos_acumulados += puntos_por_tipo[tipo]
    envido_cantado.emit(quien, TipoEnvido.keys()[tipo])

func calcular_envido(cartas: Array) -> int:
    # Encuentra la mejor suma de 2 cartas del mismo palo
    var mejor_envido = 0

    for palo in ["espadas", "bastos", "oros", "copas"]:
        var cartas_palo = cartas.filter(func(c): return c.palo == palo)

        if cartas_palo.size() >= 2:
            var valores = cartas_palo.map(func(c): return c.numero if c.numero <= 7 else 0)
            valores.sort()
            var envido = 20 + valores[-1] + valores[-2]
            mejor_envido = max(mejor_envido, envido)
        elif cartas_palo.size() == 1:
            var valor = cartas_palo[0].numero if cartas_palo[0].numero <= 7 else 0
            mejor_envido = max(mejor_envido, valor)

    return mejor_envido

func resolver_envido(puntos_jugador: int, puntos_muerte: int) -> Dictionary:
    var ganador = "jugador" if puntos_jugador > puntos_muerte else "muerte"
    var puntos = puntos_acumulados

    envido_resuelto.emit(ganador, puntos)

    return {
        "ganador": ganador,
        "puntos": puntos,
        "puntos_jugador": puntos_jugador,
        "puntos_muerte": puntos_muerte
    }
```

**Divide:** Sistema completo de envido

---

#### **`truco_betting.gd`** (~150 líneas)

**Responsabilidad:** Sistema de truco/retruco/vale 4

```gdscript
extends Node

signal apuesta_cantada(quien: String, tipo: String)
signal apuesta_aceptada()
signal apuesta_rechazada()

enum NivelApuesta { NINGUNO, TRUCO, RETRUCO, VALE_CUATRO }

var nivel_actual: NivelApuesta = NivelApuesta.NINGUNO
var puntos_en_juego: int = 1
var ultimo_apostador: String = ""

var puntos_por_nivel = {
    NivelApuesta.TRUCO: 2,
    NivelApuesta.RETRUCO: 3,
    NivelApuesta.VALE_CUATRO: 4
}

func cantar_truco(quien: String) -> void:
    if nivel_actual < NivelApuesta.TRUCO:
        nivel_actual = NivelApuesta.TRUCO
        puntos_en_juego = puntos_por_nivel[NivelApuesta.TRUCO]
        ultimo_apostador = quien
        apuesta_cantada.emit(quien, "truco")

func cantar_retruco(quien: String) -> void:
    if nivel_actual == NivelApuesta.TRUCO:
        nivel_actual = NivelApuesta.RETRUCO
        puntos_en_juego = puntos_por_nivel[NivelApuesta.RETRUCO]
        ultimo_apostador = quien
        apuesta_cantada.emit(quien, "retruco")

func cantar_vale_cuatro(quien: String) -> void:
    if nivel_actual == NivelApuesta.RETRUCO:
        nivel_actual = NivelApuesta.VALE_CUATRO
        puntos_en_juego = puntos_por_nivel[NivelApuesta.VALE_CUATRO]
        ultimo_apostador = quien
        apuesta_cantada.emit(quien, "vale cuatro")

func aceptar_apuesta() -> void:
    apuesta_aceptada.emit()

func rechazar_apuesta() -> void:
    apuesta_rechazada.emit()
    # El que rechaza pierde 1 punto menos de lo apostado
```

**Divide:** Sistema de apuestas de truco

---

#### **`truco_ui.gd`** (~200 líneas)

**Responsabilidad:** Actualización de interfaz

```gdscript
extends Node

# Referencias UI
@onready var puntos_jugador_label: Label = $"../PuntosJugadorLabel"
@onready var puntos_muerte_label: Label = $"../PuntosMuerteLabel"
@onready var mensaje_label: Label = $"../MensajeLabel"
@onready var btn_envido: Button = $"../BtnEnvido"
@onready var btn_truco: Button = $"../BtnTruco"
# ...

func actualizar_puntos(puntos_jugador: int, puntos_muerte: int) -> void:
    puntos_jugador_label.text = "Puntos: %d" % puntos_jugador
    puntos_muerte_label.text = "Puntos: %d" % puntos_muerte

func mostrar_mensaje(texto: String, duracion: float = 2.0) -> void:
    mensaje_label.text = texto
    mensaje_label.visible = true
    await get_tree().create_timer(duracion).timeout
    mensaje_label.visible = false

func habilitar_controles_jugador() -> void:
    btn_envido.disabled = false
    btn_truco.disabled = false

func deshabilitar_controles_jugador() -> void:
    btn_envido.disabled = true
    btn_truco.disabled = true

func mostrar_cartas_jugador(cartas: Array) -> void:
    # Limpiar cartas anteriores
    # Instanciar nuevas cartas
    # Posicionarlas
    pass

func animar_carta_a_mesa(carta: Carta, destino: Vector2) -> void:
    var tween = create_tween()
    tween.tween_property(carta, "position", destino, 0.5)

func actualizar_todo() -> void:
    # Llamar a todos los métodos de actualización
    pass
```

**Divide:** Toda la lógica de UI

---

#### **`ai_muerte.gd`** (~200 líneas)

**Responsabilidad:** Coordinador de IA

```gdscript
extends Node

@onready var strategy: AIStrategy = $AIStrategy
@onready var decision: AIDecision = $AIDecision
@onready var state: TrucoState = $"../TrucoState"

var dificultad: String = "normal"  # facil, normal, dificil

func ejecutar_turno() -> void:
    var accion = decidir_accion()
    ejecutar_accion(accion)

func decidir_accion() -> Dictionary:
    # Evaluar mano
    var evaluacion = decision.evaluar_mano(state.cartas_muerte)

    # Elegir estrategia
    var estrategia_actual = strategy.elegir_estrategia(evaluacion, state)

    # Decidir acción específica
    return decision.decidir_accion_especifica(estrategia_actual, state)

func ejecutar_accion(accion: Dictionary) -> void:
    match accion.tipo:
        "jugar_carta":
            jugar_carta(accion.carta)
        "cantar_envido":
            cantar_envido(accion.tipo_envido)
        "cantar_truco":
            cantar_truco()
        "irse_al_mazo":
            irse_al_mazo()

func jugar_carta(carta: Carta) -> void:
    # Lógica para jugar carta
    pass
```

**Divide:** Coordinación de IA, fragmentada de ia_muerte.gd original (617 líneas)

---

#### **`ai_strategy.gd`** (~200 líneas)

**Responsabilidad:** Estrategias de la IA

```gdscript
extends Node

enum Estrategia { CONSERVADORA, EQUILIBRADA, AGRESIVA, DESESPERADA }

func elegir_estrategia(evaluacion_mano: Dictionary, state: TrucoState) -> Estrategia:
    var diferencia_puntos = state.puntos_muerte - state.puntos_jugador
    var fuerza_mano = evaluacion_mano.fuerza  # 0.0 - 1.0

    # Si vamos perdiendo por mucho
    if diferencia_puntos < -10:
        return Estrategia.DESESPERADA

    # Si tenemos buena mano
    if fuerza_mano > 0.7:
        return Estrategia.AGRESIVA

    # Si vamos ganando
    if diferencia_puntos > 5:
        return Estrategia.CONSERVADORA

    # Por defecto
    return Estrategia.EQUILIBRADA

func aplicar_estrategia_conservadora(state: TrucoState) -> Dictionary:
    # No arriesgar, jugar seguro
    return {
        "agregar_envido": false,
        "cantar_truco": false,
        "aceptar_apuestas": false
    }

func aplicar_estrategia_agresiva(state: TrucoState) -> Dictionary:
    # Apostar fuerte
    return {
        "agregar_envido": true,
        "cantar_truco": true,
        "aceptar_apuestas": true
    }
```

**Divide:** Lógica de estrategias

---

#### **`ai_decision.gd`** (~200 líneas)

**Responsabilidad:** Decisiones específicas

```gdscript
extends Node

func evaluar_mano(cartas: Array) -> Dictionary:
    # Calcular fuerza de la mano (0.0 - 1.0)
    var fuerza = calcular_fuerza_mano(cartas)

    # Calcular potencial de envido
    var envido = calcular_envido_potencial(cartas)

    return {
        "fuerza": fuerza,
        "envido": envido,
        "tiene_figura": tiene_figura(cartas)
    }

func calcular_fuerza_mano(cartas: Array) -> float:
    # Evalúa qué tan buenas son las cartas
    # Retorna 0.0 (mala) a 1.0 (excelente)
    pass

func decidir_accion_especifica(estrategia: int, state: TrucoState) -> Dictionary:
    # Basado en estrategia y estado, decide qué hacer

    # ¿Cantar envido?
    if should_cantar_envido(estrategia, state):
        return { "tipo": "cantar_envido", "tipo_envido": elegir_tipo_envido() }

    # ¿Cantar truco?
    if should_cantar_truco(estrategia, state):
        return { "tipo": "cantar_truco" }

    # ¿Irse al mazo?
    if should_irse_al_mazo(estrategia, state):
        return { "tipo": "irse_al_mazo" }

    # Jugar carta
    var mejor_carta = elegir_mejor_carta(state.cartas_muerte, state)
    return { "tipo": "jugar_carta", "carta": mejor_carta }

func elegir_mejor_carta(cartas: Array, state: TrucoState) -> Carta:
    # Lógica para elegir la carta óptima
    # Considera: ronda actual, carta del oponente (si ya jugó), etc.
    pass
```

**Divide:** Decisiones y evaluaciones

---

#### **Otros archivos del truco:**

- **`card.gd`** (~150 líneas) - Carta individual
- **`deck.gd`** (~80 líneas) - Mazo de cartas
- **`hand_evaluator.gd`** (~100 líneas) - Evaluador de manos

---

## 📊 Data - Datos del Juego

Archivos de configuración y datos.

### `data/dialogues/`

CSVs con diálogos:
- `intro_cinematic.csv`
- `rancho_transition.csv`

---

### `data/config/`

**`difficulty_settings.tres`**

```gdscript
extends Resource
class_name DifficultySettings

@export var velocidad_base: float = 200.0
@export var incremento_velocidad: float = 10.0
@export var mates_por_nivel: int = 10
@export var objetivo_mates: int = 100
```

---

### `data/cards/`

**`card_values.tres`**

```gdscript
extends Resource
class_name CardValues

@export var jerarquia_truco: Dictionary = {
    "1_espadas": 14,
    "1_bastos": 13,
    # ...
}
```

---

## 🔀 Diagramas de Arquitectura

### Diagrama de Managers (Core)

```
┌─────────────────────────────────────────────┐
│           GameManager (Autoload)            │
│  - Estado global básico                     │
│  - Coordina otros managers                  │
└───────┬─────────────────────────────────────┘
        │
        ├──► DifficultyManager
        │    - Velocidad, niveles
        │    - Signal: velocidad_cambiada
        │
        ├──► ConfigManager
        │    - Audio, video, configuración
        │    - Persistencia
        │
        └──► SceneManager
             - Transiciones con efectos
             - Slow motion, fades
```

---

### Diagrama de Sistemas

```
┌──────────────────┐       ┌──────────────────┐
│  ScoreManager    │       │  LivesManager    │
│  (Autoload)      │       │  (Autoload)      │
└────────┬─────────┘       └────────┬─────────┘
         │                           │
         │ mates_cambiados           │ vidas_cambiadas
         ▼                           ▼
    ┌────────────────────────────────────┐
    │         UI (HUD)                   │
    │  - score_display.tscn              │
    │  - lives_display.tscn              │
    └────────────────────────────────────┘
```

---

### Diagrama del Player

```
Player (CharacterBody2D)
│
├─ PlayerController ──────► Input, física
│  │
│  └──► PlayerVisual ─────► Animaciones
│  └──► CollisionManager ─► Colisiones
│
└─ PlayerDeath ───────────► Secuencia muerte
   │
   └──► SceneManager ─────► Cambio a Game Over
```

---

### Diagrama del Truco

```
TrucoGame (Control)
│
├─ TrucoController ──────► Orquestador
│  │
│  ├──► TrucoState ──────► Estado
│  ├──► TrucoRules ──────► Reglas
│  ├──► EnvidoSystem ────► Envido
│  ├──► TrucoBetting ────► Apuestas
│  ├──► TrucoUI ─────────► Interfaz
│  │
│  └──► AIMuerte ────────► IA
│      │
│      ├──► AIStrategy ──► Estrategias
│      └──► AIDecision ──► Decisiones
│
└─ [Nodos visuales]
```

---

## 🚀 Guía de Migración

### Orden de Migración Recomendado

#### **Fase 1: Core** (Prioridad Alta)

1. Crear `core/difficulty_manager.gd` - Extraer de GameManager
2. Crear `core/config_manager.gd` - Extraer de GameManager
3. Crear `core/scene_manager.gd` - Extraer de GameManager
4. Actualizar `core/game_manager.gd` - Dejar solo estado básico
5. Configurar autoloads

**Riesgo:** Bajo - Son extracciones limpias

---

#### **Fase 2: Sistemas** (Prioridad Alta)

1. Mover `systems/dialogue/` - Desde scripts/ y scenes/dialogue_ui/
2. Crear `systems/score/score_manager.gd` - Extraer de GameManager
3. Crear `systems/lives/lives_manager.gd` - Extraer de GameManager
4. Mover `systems/spawning/` - Desde scenes/obstaculo/ y scenes/puntaje/
5. Configurar autoloads de Score y Lives

**Riesgo:** Medio - Requiere actualizar referencias

---

#### **Fase 3: Entities - Player** (Prioridad Media)

1. Crear estructura de carpetas `entities/player/`
2. Crear `player_controller.gd` - Extraer física e input
3. Crear `player_visual.gd` - Extraer animaciones
4. Crear `player_death.gd` - Extraer secuencia de muerte
5. Crear `player_collision.gd` - Extraer manejo de colisiones
6. Actualizar `player.tscn` con nueva estructura de nodos
7. Testear exhaustivamente

**Riesgo:** Alto - Mucho código acoplado

---

#### **Fase 4: Entities - Resto** (Prioridad Baja)

1. Mover `entities/obstacles/` - Desde scenes/obstaculo/
2. Extraer `obstacle_types.gd` - Configuración de tipos
3. Mover `entities/collectibles/` - Desde scenes/puntaje/
4. Mover `entities/environment/` - Desde scenes/suelo/

**Riesgo:** Bajo - Archivos pequeños

---

#### **Fase 5: UI** (Prioridad Media)

1. Mover `ui/menus/` - Desde scenes/
2. Crear `ui/hud/score_display.tscn` - Conectar a ScoreManager
3. Crear `ui/hud/lives_display.tscn` - Conectar a LivesManager
4. Mover `ui/screens/` - Desde scenes/
5. Mover `ui/dialogue/` - Desde systems/dialogue/

**Riesgo:** Medio - Muchas referencias a actualizar

---

#### **Fase 6: Scenes** (Prioridad Baja)

1. Mover `scenes/levels/` - Renombrar desde scenes/nivel/
2. Mover `scenes/cinematics/` - Desde scenes/cinematica/

**Riesgo:** Bajo

---

#### **Fase 7: Truco Game** (Prioridad Crítica)

**⚠️ Esta es la refactorización más compleja**

1. **Análisis profundo** del código actual (1189 líneas)
2. Crear estructura de nodos en `truco_game.tscn`
3. Crear `truco_state.gd` - Extraer todo el estado
4. Crear `truco_rules.gd` - Extraer lógica de reglas
5. Crear `envido_system.gd` - Extraer sistema de envido
6. Crear `truco_betting.gd` - Extraer sistema de apuestas
7. Crear `truco_ui.gd` - Extraer actualización de UI
8. Dividir `ia_muerte.gd` (617 líneas) en:
   - `ai_muerte.gd` - Coordinador
   - `ai_strategy.gd` - Estrategias
   - `ai_decision.gd` - Decisiones
9. Crear `truco_controller.gd` - Orquestador principal
10. Testear **EXHAUSTIVAMENTE** cada funcionalidad

**Riesgo:** MUY ALTO - Archivo crítico con 1189 líneas

**Estrategia:**
- Hacer en una rama separada
- Migrar función por función
- Testear continuamente
- Considerar crear tests unitarios primero

---

### Checklist de Migración por Archivo

Para cada archivo migrado:

- [ ] Crear nueva estructura de carpetas
- [ ] Crear archivo(s) nuevo(s)
- [ ] Copiar y adaptar código
- [ ] Actualizar referencias en escenas (.tscn)
- [ ] Actualizar imports/preloads
- [ ] Actualizar autoloads (project.godot)
- [ ] Testear funcionalidad
- [ ] Eliminar archivo antiguo
- [ ] Commit incremental

---

## ⚙️ Convenciones y Reglas

### Naming Conventions

**Carpetas:** `snake_case`
```
entities/player/
systems/dialogue/
```

**Archivos:** `snake_case`
```
player_controller.gd
difficulty_manager.gd
```

**Clases:** `PascalCase`
```gdscript
class_name PlayerController
class_name DifficultyManager
```

**Variables:** `snake_case`
```gdscript
var velocidad_actual: float
var mates_totales: int
```

**Señales:** `snake_case`
```gdscript
signal mates_cambiados(nuevos_mates: int)
signal velocidad_cambiada(nueva_velocidad: float)
```

**Constantes:** `UPPER_SNAKE_CASE`
```gdscript
const MAX_VIDAS: int = 3
const VELOCIDAD_BASE: float = 200.0
```

---

### Reglas de Scripts

✅ **Un script = una responsabilidad**
✅ **Máximo 300 líneas por script**
✅ **Separar lógica de presentación**
✅ **Preferir signals sobre referencias directas**
✅ **Evitar `get_parent().get_parent()`**

---

### Estructura de un Script

```gdscript
# nombre_script.gd
extends Node

# ============================================================
# SIGNALS
# ============================================================
signal algo_paso(dato: int)

# ============================================================
# EXPORTS
# ============================================================
@export var velocidad: float = 200.0

# ============================================================
# CONSTANTES
# ============================================================
const MAX_VALOR: int = 100

# ============================================================
# VARIABLES
# ============================================================
var valor_actual: int = 0

# ============================================================
# REFERENCIAS
# ============================================================
@onready var sprite: Sprite2D = $Sprite2D

# ============================================================
# LIFECYCLE
# ============================================================
func _ready() -> void:
    pass

func _process(delta: float) -> void:
    pass

# ============================================================
# PUBLIC METHODS
# ============================================================
func metodo_publico() -> void:
    pass

# ============================================================
# PRIVATE METHODS
# ============================================================
func _metodo_privado() -> void:
    pass

# ============================================================
# SIGNAL HANDLERS
# ============================================================
func _on_algo_paso() -> void:
    pass
```

---

### Comunicación entre Nodos

**✅ PREFERIR:**
```gdscript
# Uso de signals
signal player_died()

# En otro script:
func _ready():
    player.player_died.connect(_on_player_died)
```

**❌ EVITAR:**
```gdscript
# Referencias directas complejas
get_parent().get_parent().get_node("UI/HUD").update_score()
```

**✅ MEJOR:**
```gdscript
# Usar managers
ScoreManager.agregar_puntos(10)
```

---

### Autoloads

**Configurar en Project Settings:**

```
core/game_manager.gd → GameManager
core/difficulty_manager.gd → DifficultyManager
core/config_manager.gd → ConfigManager
core/scene_manager.gd → SceneManager
systems/score/score_manager.gd → ScoreManager
systems/lives/lives_manager.gd → LivesManager
systems/audio/audio_manager.gd → AudioManager
```

**Uso:**
```gdscript
ScoreManager.agregar_mates(1)
DifficultyManager.aumentar_dificultad()
```

---

## ✅ Criterios de Éxito

La migración será exitosa cuando:

- ✅ **Todos los scripts < 300 líneas**
- ✅ **Separación clara de responsabilidades**
- ✅ **Código organizado por funcionalidad**
- ✅ **Todas las funcionalidades existentes funcionan**
- ✅ **Sin regresiones ni bugs nuevos**
- ✅ **Código más fácil de mantener**
- ✅ **Preparado para escalar**

---

## 📝 Notas Finales

### Priorización de Fases

**Alta prioridad:**
- Fase 1: Core
- Fase 2: Sistemas
- Fase 7: Truco (crítico pero complejo)

**Media prioridad:**
- Fase 3: Player
- Fase 5: UI

**Baja prioridad:**
- Fase 4: Entities resto
- Fase 6: Scenes

### Consideraciones Especiales

1. **Truco Game:** La refactorización más compleja. Considerar hacerla en una rama separada y con tests.

2. **Testing:** Testear exhaustivamente después de cada fase. El juego debe seguir funcionando.

3. **Commits:** Hacer commits incrementales, uno por archivo/componente migrado.

4. **Documentación:** Actualizar CLAUDE.md después de cada fase completada.

---

**Última actualización:** 2026-01-05
**Estado:** Documento de referencia para refactorización
