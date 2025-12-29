extends TileMapLayer

@export var speed := 200.0

func _process(delta):
	position.x -= speed * delta
