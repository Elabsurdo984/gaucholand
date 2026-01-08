# player_visual.gd
# Gestión de animaciones y efectos visuales del jugador
class_name PlayerVisual
extends Node

# ============================================================
# REFERENCIAS
# ============================================================
@export var sprite: AnimatedSprite2D

# ============================================================
# PUBLIC METHODS
# ============================================================

## Reproduce una animación
func reproducir_animacion(nombre: String) -> void:
	if sprite.animation != nombre:
		sprite.animation = nombre
		sprite.play()

## Detiene la animación actual
func detener_animacion() -> void:
	sprite.stop()

## Obtiene el nombre de la animación actual
func animacion_actual() -> String:
	return sprite.animation

## Verifica si hay una animación reproduciéndose
func esta_reproduciendo() -> bool:
	return sprite.is_playing()

## Fija el último frame de una animación
func fijar_ultimo_frame(nombre: String) -> void:
	var frame_count: int = sprite.sprite_frames.get_frame_count(nombre)
	sprite.frame = frame_count - 1

## Aplica un tinte de color al sprite
func aplicar_tinte(color: Color) -> void:
	sprite.modulate = color

## Efecto de parpadeo para invencibilidad
func iniciar_invencibilidad(duracion: float = 1.2) -> void:
	var tween: Tween = create_tween()
	tween.set_loops(6)
	tween.tween_property(sprite, "modulate:a", 0.5, 0.1)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.1)

	await tween.finished

## Rota el sprite (usado en muerte)
func rotar(angulo: float, duracion: float = 0.3) -> Tween:
	var tween: Tween = create_tween()
	tween.tween_property(sprite, "rotation", angulo, duracion)
	return tween
