extends Node2D
class_name SpaceInvadersUFO

var min_x = 368
var speed = 100

signal exploded

func _process(delta: float) -> void:
	position += Vector2(-speed, 0) * delta
	if position.x <= min_x:
		queue_free()

func explode():
	visible = false
	exploded.emit(self)
	queue_free()
