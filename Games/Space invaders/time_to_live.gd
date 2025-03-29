extends Node

@export var time_to_live: float = 0.25

func _process(delta: float) -> void:
	time_to_live -= delta
	if time_to_live <= 0:
		queue_free()
