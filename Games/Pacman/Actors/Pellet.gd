extends Area2D
class_name PacmanPellet

@export var BigPellet: bool = false
signal got_eaten(PacmanPellet)

var enabled = true

func is_big_pellet() -> bool:
	return BigPellet

func get_score() -> int:
	return 50 if BigPellet else 10

func is_enabled() -> bool:
	return enabled

func enable():
	visible = true
	enabled = true

func disable():
	visible = false
	enabled = false

func _on_body_entered(body: Node2D) -> void:
	if not enabled:
		return
	disable()
	got_eaten.emit(self)
