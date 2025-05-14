extends Area2D
class_name PacmanPellet

@export var BigPellet: bool = false
signal got_eaten(PacmanPellet)

var enabled = true

func _ready() -> void:
	$AnimatedSprite2D.play("default")

func pause_anim():
	$AnimatedSprite2D.pause()
	$AnimatedSprite2D.frame = 0

func resume_anim():
	$AnimatedSprite2D.play("default")
	

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

func _on_body_entered(_body: Node2D) -> void:
	if not enabled:
		return
	disable()
	got_eaten.emit(self)
