# dialogue_manager.gd
# Sistema profesional de gestión de diálogos
# Maneja typewriter effect, input, y flow de conversaciones

extends Node

#func _ready() -> void:
	#set_process(true)
	#print("Dialogue Manager Cargado")

#region SIGNALS
signal dialogue_started()
signal dialogue_line_started(character_name: String, text: String)
signal dialogue_line_finished()
signal dialogue_ended()
signal typing_started()
signal typing_finished()
#endregion

#region ENUMS
enum State {
	IDLE,           # Sin diálogo activo
	TYPING,         # Escribiendo texto
	WAITING_INPUT,  # Esperando que el jugador continúe
	FINISHED        # Conversación terminada
}
#endregion

#region CONFIGURACIÓN
@export_group("Typewriter Settings")
@export var typing_speed: float = 30.0  # Caracteres por segundo
@export var can_skip_typing: bool = true  # Permitir saltar el typing
@export var punctuation_delay: float = 0.5  # Pausa extra en puntuación

@export_group("Input Settings")
@export var advance_actions: String = "skipear"  # Teclas para avanzar

@export_group("UI References")
@export var name_label: Label
@export var text_label: Label 
@export var continue_indicator: Label
#endregion

#region VARIABLES PRIVADAS
var _dialogues: Array = []  
var _current_index: int = -1
var _current_state: State = State.IDLE
var _current_text: String = ""  # Texto completo de la línea actual
var _current_text_clean: String = ""  # Texto sin etiquetas para mostrar
var _displayed_text: String = ""  # Texto mostrado actualmente
var _typing_timer: float = 0.0
var _char_index: int = 0
var _pause_timer: float = 0.0  # Timer para pausas de etiquetas
var _is_paused: bool = false  # Si está en pausa por etiqueta
var _stop_positions: Array = []  # Posiciones donde hay [stop] en el texto limpio
#endregion



#region MÉTODOS PÚBLICOS

## Configura el sistema con un array de diálogos
## dialogues: Array de Dictionaries con {character: String, text: String}
func setup(dialogues: Array) -> void:
	_dialogues = dialogues
	_current_index = -1
	_current_state = State.IDLE
	print("📖 DialogueManager: ", dialogues.size(), " líneas cargadas")

## Inicia la conversación
func start() -> void:
	if _dialogues.is_empty():
		push_error("❌ DialogueManager: No hay diálogos configurados!")
		return

	_current_state = State.IDLE
	_current_index = -1
	dialogue_started.emit()

	# Ocultar indicador al inicio
	if continue_indicator:
		continue_indicator.visible = false

	# Mostrar primer diálogo
	next_line()

## Avanza a la siguiente línea de diálogo
func next_line() -> void:
	# Si está escribiendo, completar texto
	if _current_state == State.TYPING:
		_complete_typing()
		return

	# Avanzar al siguiente diálogo
	_current_index += 1

	# Verificar si terminó la conversación
	if _current_index >= _dialogues.size():
		_end_dialogue()
		return

	# Mostrar nueva línea
	_show_line(_current_index)

## Fuerza el fin del diálogo
func end() -> void:
	_end_dialogue()

## Retorna si está esperando input
func is_waiting_for_input() -> bool:
	return _current_state == State.WAITING_INPUT

## Retorna si está escribiendo
func is_typing() -> bool:
	return _current_state == State.TYPING
#endregion

#region MÉTODOS PRIVADOS

func _show_line(index: int) -> void:
	var dialogue = _dialogues[index]

	# Actualizar nombre del personaje
	if name_label:
		name_label.text = dialogue.get("character", "???")

	# Preparar texto y procesar etiquetas
	_current_text = dialogue.get("text", "")
	_process_tags(_current_text)
	_displayed_text = ""
	_char_index = 0
	_typing_timer = 0.0
	_pause_timer = 0.0
	_is_paused = false

	# Ocultar indicador mientras escribe
	if continue_indicator:
		continue_indicator.visible = false

	# Cambiar estado
	_current_state = State.TYPING

	# Emitir señal
	dialogue_line_started.emit(dialogue.get("character", ""), _current_text_clean)
	typing_started.emit()

## Procesa las etiquetas en el texto
## Extrae [stop] y guarda sus posiciones, retorna texto limpio
func _process_tags(text: String) -> void:
	_stop_positions.clear()
	_current_text_clean = ""

	var position = 0
	var i = 0

	while i < text.length():
		# Buscar etiqueta [stop]
		if text.substr(i, 6) == "[stop]":
			# Guardar la posición en el texto limpio donde debería pausar
			_stop_positions.append(position)
			i += 6  # Saltar la etiqueta
		else:
			# Agregar el carácter al texto limpio
			_current_text_clean += text[i]
			position += 1
			i += 1

	print("🏷️ Etiquetas procesadas: ", _stop_positions.size(), " pausas en: ", _stop_positions)

func _process(delta: float) -> void:
	match _current_state:
		State.TYPING:
			_process_typing(delta)
		State.WAITING_INPUT:
			_process_input()

func _process_typing(delta: float) -> void:
	# Debug Temporal
	if _char_index == 0:
		print("Punctuation delay: ", punctuation_delay)
	
	# Si está en pausa por [stop], esperar
	if _is_paused:
		_pause_timer += delta
		print("⏸️ Pausado - timer: ", _pause_timer, " / delay: ", punctuation_delay)
		if _pause_timer >= punctuation_delay:
			_is_paused = false
			_pause_timer = 0.0
		return

	_typing_timer += delta

	# Calcular cuántos caracteres mostrar
	var chars_to_show = int(_typing_timer * typing_speed)

	# Limitar al tamaño del texto limpio
	chars_to_show = min(chars_to_show, _current_text_clean.length())

	# Actualizar texto mostrado
	if chars_to_show > _char_index:
		_char_index = chars_to_show
		_displayed_text = _current_text_clean.substr(0, _char_index)

		if text_label:
			text_label.text = _displayed_text

		# Verificar si llegamos a una posición de [stop]
		if _char_index in _stop_positions:
			_is_paused = true
			_pause_timer = 0.0

		# Verificar si terminó de escribir
		if _char_index >= _current_text_clean.length():
			_finish_typing()

func _finish_typing() -> void:
	_current_state = State.WAITING_INPUT

	# Mostrar indicador de continuar
	if continue_indicator:
		continue_indicator.visible = true

	typing_finished.emit()
	dialogue_line_finished.emit()

func _complete_typing() -> void:
	# Mostrar todo el texto inmediatamente (texto limpio sin etiquetas)
	_char_index = _current_text_clean.length()
	_displayed_text = _current_text_clean
	_is_paused = false

	if text_label:
		text_label.text = _displayed_text

	_finish_typing()

func _process_input() -> void:
	# Detectar si presiona la tecla de avanzar
	if Input.is_action_just_pressed(advance_actions):
		next_line()

func _end_dialogue() -> void:
	_current_state = State.FINISHED

	# Ocultar UI
	if continue_indicator:
		continue_indicator.visible = false

	dialogue_ended.emit()
	print("✅ DialogueManager: Conversación terminada")
#endregion
