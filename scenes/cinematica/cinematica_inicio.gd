# cinematica_inicio.gd
extends Control

# ==================== REFERENCIAS ====================
@export var muerte_sprite: Sprite2D
@export var gaucho_sprite: Sprite2D
@export var dialogue_ui: Panel
@export var dialogue_manager: Node

# ==================== CONFIGURACIÓN ====================
@export_file("*.csv") var dialogue_file: String = "res://data/dialogues/cinematica_inicio.csv"

# ==================== DIÁLOGOS ====================
var dialogos: Array = []

# ==================== INICIALIZACIÓN ====================
func _ready():
	# Cargar diálogos desde CSV
	dialogos = DialogueLoader.load_from_csv(dialogue_file)

	# Validar que se cargaron correctamente
	if dialogos.is_empty():
		push_error("❌ Cinemática: No se pudieron cargar los diálogos")
		return

	# Ocultar UI de diálogo al inicio
	if dialogue_ui:
		dialogue_ui.visible = false

	# Inicialmente la muerte está invisible
	if muerte_sprite:
		muerte_sprite.modulate.a = 0.0

	# Conectar señales del DialogueManager
	if dialogue_manager:
		dialogue_manager.dialogue_line_started.connect(_on_dialogue_line_started)
		dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)

	# Empezar la secuencia
	iniciar_cinematica()

# ==================== SECUENCIA DE CINEMÁTICA ====================
func iniciar_cinematica():
	# Esperar un momento antes de empezar
	await get_tree().create_timer(1.0).timeout

	# Hacer aparecer a la Muerte con efecto fade
	await aparecer_muerte()

	# Esperar un momento
	await get_tree().create_timer(0.5).timeout

	# Mostrar UI de diálogo
	if dialogue_ui:
		dialogue_ui.visible = true

	# Iniciar sistema de diálogo
	if dialogue_manager:
		dialogue_manager.setup(dialogos)
		dialogue_manager.start()

func aparecer_muerte():
	# Fade in de la Muerte
	if muerte_sprite:
		var tween = create_tween()
		tween.tween_property(muerte_sprite, "modulate:a", 1.0, 1.5)
		await tween.finished

# ==================== CALLBACKS DEL DIALOGUE MANAGER ====================
func _on_dialogue_line_started(character_name: String, text: String):
	print("💬 ", character_name, ": ", text)

func _on_dialogue_ended():
	print("🎬 Cinemática terminada - Iniciando gameplay...")

	# Fade out de la UI
	if dialogue_ui:
		var tween = create_tween()
		tween.tween_property(dialogue_ui, "modulate:a", 0.0, 0.5)
		await tween.finished

	# Transición al gameplay
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/nivel_pampa/nivel_pampa.tscn")
