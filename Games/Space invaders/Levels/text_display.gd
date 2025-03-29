extends Label

signal done

var playback_speed = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible_ratio = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if playback_speed == 0:
		return
	
	visible_ratio += playback_speed * delta
	if visible_ratio >= 1:
		playback_speed = 0
		done.emit()
