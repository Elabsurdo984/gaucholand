extends Control

@export var contador: Label
@export var hearts_container: HBoxContainer
@export var heart_full: Texture2D = preload("res://assets/kenney_pixel-platformer/Tiles/tile_0044.png")
@export var heart_empty: Texture2D = preload("res://assets/kenney_pixel-platformer/Tiles/tile_0046.png")

func _ready() -> void:
	# Conectarse directamente a los managers especializados
	if ScoreManager:
		ScoreManager.mates_cambiados.connect(_on_mates_cambiados)
		_on_mates_cambiados(ScoreManager.obtener_mates())

	if LivesManager:
		LivesManager.vidas_cambiadas.connect(_on_vidas_cambiadas)

		# Inicializar contenedor si está vacío
		if hearts_container and hearts_container.get_child_count() == 0:
			configurar_corazones_iniciales()

		_on_vidas_cambiadas(LivesManager.obtener_vidas())

func configurar_corazones_iniciales():
	# Limpiar
	for child in hearts_container.get_children():
		child.queue_free()

	# Crear corazones basados en MAX_VIDAS del LivesManager (o 3 por defecto)
	var max_vidas = 3
	if LivesManager and "MAX_VIDAS" in LivesManager:
		max_vidas = LivesManager.MAX_VIDAS

	for i in range(max_vidas):
		var rect = TextureRect.new()
		rect.texture = heart_full
		# Escalar x3 para que se vean bien (pixel art)
		rect.custom_minimum_size = Vector2(48, 48)
		rect.stretch_mode = TextureRect.STRETCH_SCALE
		hearts_container.add_child(rect)

func _on_mates_cambiados(nuevos_mates: int):
	contador.text = "Mates: " + str(nuevos_mates)

func _on_vidas_cambiadas(nuevas_vidas: int):
	if not hearts_container:
		return
		
	var corazones = hearts_container.get_children()
	for i in range(corazones.size()):
		if corazones[i] is TextureRect:
			if i < nuevas_vidas:
				corazones[i].texture = heart_full
			else:
				corazones[i].texture = heart_empty
