extends Label
class_name TetrisTimeToVisible

var timer = 0.0

func _ready():
	visible = false


func _process(delta: float) -> void:
	timer -= delta
	if timer < 0:
		visible = false

func show_item():
	visible = true
	timer = 1.0
