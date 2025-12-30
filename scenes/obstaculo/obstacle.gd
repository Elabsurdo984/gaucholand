# obstaculo.gd
extends Area2D

# Señal para cuando el jugador muere
signal jugador_muerto

func _ready():
	# Conectar la señal solo si no está conectada
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Verificar si es el jugador
	if body.is_in_group("jugador"):
		jugador_muerto.emit()
		body.morir()
