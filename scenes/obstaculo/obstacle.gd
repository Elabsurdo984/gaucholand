extends Area2D

signal jugador_muerto

@export var speed := 200.0  # Misma velocidad que el suelo

enum TipoObstaculo { CACTUS_ALTO, PIEDRA_BAJA, ARBUSTO_MEDIO }

var tipo: TipoObstaculo = TipoObstaculo.CACTUS_ALTO

# Configuración de cada tipo de obstáculo
var config_obstaculos = {
	TipoObstaculo.CACTUS_ALTO: {
		"sprite": "res://assets/obstaculos/obstaculo_cactus.png",
		"escala": Vector2(3.22, 3.28),
		"colision_size": Vector2(16, 58),
		"offset_y": -9.5
	},
	TipoObstaculo.PIEDRA_BAJA: {
		"sprite": "res://assets/obstaculos/obstaculo_piedra.png",
		"escala": Vector2(1, 1),
		"colision_size": Vector2(14, 30),
		"offset_y": 2.0
	},
	TipoObstaculo.ARBUSTO_MEDIO: {
		"sprite": "res://assets/obstaculos/obstaculo_arbusto.png",
		"escala": Vector2(3.0, 3.0),
		"colision_size": Vector2(16, 45),
		"offset_y": -5.0
	}
}

func _ready():
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	configurar_tipo()

func set_tipo_aleatorio():
	# Seleccionar un tipo aleatorio
	var tipos = [TipoObstaculo.CACTUS_ALTO, TipoObstaculo.PIEDRA_BAJA, TipoObstaculo.ARBUSTO_MEDIO]
	tipo = tipos[randi() % tipos.size()]
	if is_node_ready():
		configurar_tipo()

func configurar_tipo():
	var config = config_obstaculos[tipo]

	# Configurar sprite
	var sprite = $Sprite2D
	sprite.texture = load(config["sprite"])
	sprite.scale = config["escala"]
	sprite.position.y = config["offset_y"]

	# Configurar colisión
	var collision = $CollisionShape2D
	collision.shape.size = config["colision_size"]
	collision.position.y = config["offset_y"]

func _process(delta):
	# Mover el obstáculo hacia la izquierda
	position.x -= speed * delta
	
	# Eliminar el obstáculo cuando salga de la pantalla
	if position.x < -580:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		jugador_muerto.emit()
		body.morir()
