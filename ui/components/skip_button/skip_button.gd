# skip_button.gd
# Botón reutilizable para saltear cinemáticas
extends Control

#region SIGNALS
signal skip_pressed
#endregion

#region REFERENCIAS
@onready var button: Button = $Button
#endregion

#region CONFIGURACIÓN
@export var target_scene: String = ""  # Escena destino al hacer skip
@export var fade_duration: float = 0.5
#endregion

#region VARIABLES
var skip_in_progress: bool = false
#endregion

#region INICIALIZACIÓN
func _ready():
	# Conectar botón
	if button:
		button.pressed.connect(_on_skip_pressed)

	# Efecto de aparición
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5).set_delay(1.0)
#endregion

#region CALLBACKS
func _on_skip_pressed():
	if skip_in_progress:
		return

	skip_in_progress = true
	print("⏭️ Salteando cinemática...")

	# Emitir señal para que la cinemática padre maneje el skip
	skip_pressed.emit()

	# Si hay escena destino configurada, hacer la transición
	if target_scene != "":
		await TransitionManager.quick_fade_to_scene(
			self,
			target_scene,
			fade_duration
		)
#endregion

#region PUBLIC METHODS
## Configura la escena destino para el skip
func set_target_scene(scene_path: String) -> void:
	target_scene = scene_path

## Oculta el botón (útil si la cinemática maneja el skip de otra forma)
func hide_button() -> void:
	visible = false
	set_process_input(false)
#endregion
