extends Node

@export var time_to_live: float = 0.5

func set_text(t: String):
	$Label.text = t

func _process(delta: float) -> void:
	time_to_live -= delta
	if time_to_live <= 0:
		queue_free()
