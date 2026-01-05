# player.gd
# Script raíz del jugador - Orquestador de componentes
# NOTA: Este es un script mínimo. Los componentes hacen todo el trabajo.
extends CharacterBody2D

# ============================================================
# REFERENCIAS A COMPONENTES
# ============================================================
@onready var controller: PlayerController = $PlayerController
@onready var visual: PlayerVisual = $PlayerVisual
@onready var death: PlayerDeath = $PlayerDeath
@onready var collision_mgr: PlayerCollision = $PlayerCollision

# ============================================================
# EXPORTS (para compatibilidad con la escena existente)
# ============================================================
@export var animacion: AnimatedSprite2D:
	get:
		return $AnimatedSprite2D if has_node("AnimatedSprite2D") else null

# ============================================================
# MÉTODOS DE CONVENIENCIA
# ============================================================

## Recibe daño (delega a PlayerDeath)
func recibir_dano(causa: String = "") -> void:
	if death:
		death.recibir_dano(causa)
