# player.gd
# Script raíz del jugador - Orquestador de componentes
# NOTA: Este es un script mínimo. Los componentes hacen todo el trabajo.
extends CharacterBody2D

# ============================================================
# REFERENCIAS A COMPONENTES
# ============================================================
@export var controller: PlayerController
@export var visual: PlayerVisual
@export var death: PlayerDeath
@export var collision_mgr: PlayerCollision

# ============================================================
# EXPORTS (para compatibilidad con la escena existente)
# ============================================================
@export var animacion: AnimatedSprite2D:
	get:
		return $PlayerVisual/AnimatedSprite2D if has_node("AnimatedSprite2D") else null

# ============================================================
# MÉTODOS DE CONVENIENCIA
# ============================================================

## Recibe daño (delega a PlayerDeath)
func recibir_dano(causa: String = "") -> void:
	if death:
		death.recibir_dano(causa)
