# mate_spawner.gd
extends Node2D

@export var mate_scene: PackedScene  # Arrastra la escena del mate
@export var spawn_min_distance := 150.0  # Distancia mínima entre mates
@export var spawn_max_distance := 400.0  # Distancia máxima entre mates
@export var ground_y := 200.0  # Altura Y donde aparecen los mates (más arriba que el suelo)
@export var speed := 200.0  # Misma velocidad que el suelo
@export var spawn_offset := 200.0

var distance_since_last_spawn := 0.0
var next_spawn_distance := 0.0

func _ready():
	if mate_scene == null:
		push_error("⚠️ Asigna la escena del mate en el inspector!")
		return
	
	# Calcular primera distancia aleatoria
	next_spawn_distance = randf_range(spawn_min_distance, spawn_max_distance)

func _process(delta):
	if mate_scene == null:
		return
	
	# Acumular distancia recorrida
	distance_since_last_spawn += speed * delta
	
	# Verificar si es momento de spawnear
	if distance_since_last_spawn >= next_spawn_distance:
		spawn_mate()
		distance_since_last_spawn = 0.0
		# Nueva distancia aleatoria
		next_spawn_distance = randf_range(spawn_min_distance, spawn_max_distance)

func spawn_mate():
	# Crear el mate
	var mate = mate_scene.instantiate()
	
	# Obtener la cámara
	var camera = get_viewport().get_camera_2d()
	var spawn_x = 0.0
	
	if camera:
		# Spawnear justo afuera del borde derecho de la cámara
		var camera_pos = camera.get_screen_center_position()
		var viewport_width = get_viewport_rect().size.x
		spawn_x = camera_pos.x + (viewport_width / 2.0) + spawn_offset
	else:
		# Fallback si no hay cámara
		spawn_x = get_viewport_rect().size.x + spawn_offset
	
	# Posicionarlo
	mate.position.x = spawn_x
	mate.position.y = ground_y
	
	# Agregarlo a la escena
	get_parent().add_child(mate)
	
	print("🧉 Mate spawneado en X: ", spawn_x, " Y: ", ground_y)
