# cinematica_inicio.gd
extends Control

# Referencias a nodos (se asignarán en el editor)
@onready var muerte_sprite = $Personajes/Muerte
@onready var gaucho_sprite = $Personajes/Gaucho

func _ready():
	# Inicialmente la muerte está invisible
	if muerte_sprite:
		muerte_sprite.modulate.a = 0.0

	# Empezar la secuencia
	iniciar_cinematica()

func iniciar_cinematica():
	# Esperar un momento antes de empezar
	await get_tree().create_timer(1.0).timeout

	# Hacer aparecer a la Muerte con efecto fade
	aparecer_muerte()

	# Aquí irá el sistema de diálogo (próximo paso)
	await get_tree().create_timer(2.0).timeout
	print("Cinemática lista - Aquí irá el diálogo")

func aparecer_muerte():
	# Fade in de la Muerte
	if muerte_sprite:
		var tween = create_tween()
		tween.tween_property(muerte_sprite, "modulate:a", 1.0, 1.5)
