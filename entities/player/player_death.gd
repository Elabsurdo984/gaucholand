# player_death.gd
# Gestión de muerte del jugador y secuencia cinemática
class_name PlayerDeath
extends Node

# ============================================================
# SIGNALS
# ============================================================
signal muerte_completada()

# ============================================================
# VARIABLES
# ============================================================
var invencible: bool = false

# ============================================================
# REFERENCIAS
# ============================================================
@export var controller: PlayerController
@export var visual: PlayerVisual
@export var sonido_morir: AudioStreamPlayer2D

# ============================================================
# PUBLIC METHODS
# ============================================================

## Recibe daño y gestiona vidas o muerte
func recibir_dano(causa: String = "") -> void:
	if not controller.esta_vivo or invencible:
		return

	if LivesManager:
		if LivesManager.descontar_vida():
			iniciar_invencibilidad()
		else:
			morir(causa)
	else:
		morir(causa)

## Inicia el efecto de invencibilidad
func iniciar_invencibilidad() -> void:
	invencible = true
	await visual.iniciar_invencibilidad()
	invencible = false

## Ejecuta la muerte del jugador
func morir(causa: String = "") -> void:
	# Verificar si no está ya muerto
	if not controller.esta_vivo:
		return

	# No morir durante transición
	if SceneManager and SceneManager.esta_en_transicion():
		print("⚠️ Muerte durante transición - ignorando")
		return

	# Guardar causa de muerte
	if LivesManager:
		LivesManager.establecer_causa_muerte(causa)
		print("💀 Muerte causada por: ", causa)

	# Detener controlador
	controller.detener()

	# Ejecutar secuencia cinemática
	await secuencia_muerte_cinematica()

	muerte_completada.emit()

# ============================================================
# PRIVATE METHODS
# ============================================================

## Secuencia cinemática de muerte
func secuencia_muerte_cinematica() -> void:
	# 1. Slow motion inicial
	Engine.time_scale = 0.3

	# 2. Animación de impacto del gaucho
	visual.detener_animacion()
	visual.rotar(-PI/4, 0.3)
	visual.aplicar_tinte(Color(1, 0.3, 0.3))

	# 3. Reproducir sonido de muerte
	sonido_morir.play()

	await get_tree().create_timer(0.4).timeout  # En tiempo real: 1.2s

	# 4. Pausar todo excepto el proceso de muerte
	get_tree().paused = true
	get_parent().process_mode = Node.PROCESS_MODE_ALWAYS

	# 5. Crear efecto de desvanecimiento a negro
	await crear_fade_negro()

	# 6. Restaurar velocidad normal
	Engine.time_scale = 1.0
	get_tree().paused = false

	# 7. Pequeña pausa en negro
	await get_tree().create_timer(0.7).timeout

	# 8. Ir a pantalla de Game Over
	get_tree().change_scene_to_file("res://ui/screens/game_over/game_over.tscn")

## Crea el efecto de fade a negro
func crear_fade_negro() -> void:
	# Usar CanvasLayer para que cubra toda la pantalla
	var canvas_layer: CanvasLayer = CanvasLayer.new()
	canvas_layer.layer = 100  # Por encima de todo
	canvas_layer.process_mode = Node.PROCESS_MODE_ALWAYS  # Funcionar incluso pausado
	get_tree().root.add_child(canvas_layer)

	var fade_overlay: ColorRect = ColorRect.new()
	fade_overlay.color = Color.BLACK
	fade_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_overlay.modulate.a = 0.0
	canvas_layer.add_child(fade_overlay)

	var tween_fade: Tween = create_tween()
	tween_fade.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween_fade.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween_fade.tween_property(fade_overlay, "modulate:a", 1.0, 1.0)
	await tween_fade.finished

	# Borrar el CanvasLayer después del fade
	canvas_layer.queue_free()
