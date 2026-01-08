# player_controller.gd
# Controlador principal del jugador - Física e Input
class_name PlayerController
extends Node

# ============================================================
# EXPORTS
# ============================================================
@export var gravity: float = 1000.0
@export var jump_force: float = -420.0
@export var crouch_collision_reduction: float = 0.5

# ============================================================
# VARIABLES
# ============================================================
var esta_vivo: bool = true
var esta_agachado: bool = false

# ============================================================
# REFERENCIAS
# ============================================================
@onready var body: CharacterBody2D = get_parent()
@export var visual: PlayerVisual
@export var collision_mgr: PlayerCollision
@export var death: PlayerDeath
@export var sonido_salto: AudioStreamPlayer2D

# ============================================================
# LIFECYCLE
# ============================================================
func _ready() -> void:
	# Agregar al grupo player para detección
	body.add_to_group("player")

func _physics_process(delta: float) -> void:
	if not esta_vivo:
		return

	# Aplicar gravedad
	body.velocity.y += gravity * delta

	# Manejar input de agacharse
	manejar_agachado()

	# Salto
	if body.is_on_floor() and Input.is_action_just_pressed("salto") and not esta_agachado:
		saltar()

	# Animaciones basadas en estado
	actualizar_animaciones()

	# Mover el personaje
	body.move_and_slide()

# ============================================================
# PUBLIC METHODS
# ============================================================

## Detiene el controlador (usado en muerte)
func detener() -> void:
	esta_vivo = false
	set_physics_process(false)

## Activa el controlador
func activar() -> void:
	esta_vivo = true
	set_physics_process(true)

# ============================================================
# PRIVATE METHODS
# ============================================================

## Ejecuta el salto
func saltar() -> void:
	body.velocity.y = jump_force
	sonido_salto.play()
	visual.reproducir_animacion("salto")

## Maneja el input de agacharse
func manejar_agachado() -> void:
	if Input.is_action_pressed("agacharse") and body.is_on_floor():
		if not esta_agachado:
			agacharse()
		elif not visual.esta_reproduciendo() and visual.animacion_actual() == "agacharse":
			# Mantener en último frame si terminó la animación
			visual.fijar_ultimo_frame("agacharse")
	else:
		if esta_agachado:
			levantarse()

## Agacha al jugador
func agacharse() -> void:
	esta_agachado = true
	visual.reproducir_animacion("agacharse")
	collision_mgr.reducir_colision(crouch_collision_reduction)

## Levanta al jugador
func levantarse() -> void:
	esta_agachado = false
	visual.reproducir_animacion("correr")
	collision_mgr.restaurar_colision()

## Actualiza las animaciones según el estado
func actualizar_animaciones() -> void:
	if esta_agachado:
		return  # No cambiar animación mientras está agachado

	if not body.is_on_floor():
		if visual.animacion_actual() != "salto":
			visual.reproducir_animacion("salto")
	else:
		if visual.animacion_actual() != "correr":
			visual.reproducir_animacion("correr")
