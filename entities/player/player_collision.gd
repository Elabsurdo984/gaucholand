# player_collision.gd
# Gestión dinámica de colisiones del jugador
class_name PlayerCollision
extends Node

# ============================================================
# VARIABLES
# ============================================================
var tamano_original: Vector2
var posicion_original: Vector2

# ============================================================
# REFERENCIAS
# ============================================================
@export var collision: CollisionShape2D

# ============================================================
# LIFECYCLE
# ============================================================
func _ready() -> void:
	# Guardar tamaños originales
	if collision and collision.shape:
		tamano_original = collision.shape.size
		posicion_original = collision.position

# ============================================================
# PUBLIC METHODS
# ============================================================

## Reduce la colisión (para agacharse)
func reducir_colision(factor: float = 0.5) -> void:
	if not collision or not collision.shape:
		return

	# Reducir altura
	collision.shape.size.y = tamano_original.y * factor

	# Ajustar posición Y para mantener al jugador en el suelo
	var offset_y: float = tamano_original.y * (1 - factor) / 2
	collision.position.y = posicion_original.y + offset_y

## Restaura la colisión a su tamaño original
func restaurar_colision() -> void:
	if not collision or not collision.shape:
		return

	collision.shape.size = tamano_original
	collision.position = posicion_original
