extends Control

var time_before_apparition: float = 0.25
var time_to_live: float = 1
var appeared = false

func _ready():
	$Label.visible = false

func _process(delta: float) -> void:
	if not appeared:
		time_before_apparition -= delta
		if time_before_apparition <= 0:
			appeared = true
			$Label.visible = true
	else:
		time_to_live -= delta
		if time_to_live <= 0:
			queue_free()
