extends CharacterBody2D

@export var gravity := 1000
@export var jump_force := -420

func _physics_process(delta):
	# Gravedad
	velocity.y += gravity * delta

	# Salto
	if is_on_floor() and Input.is_action_just_pressed("salto"):
		velocity.y = jump_force

	move_and_slide()
