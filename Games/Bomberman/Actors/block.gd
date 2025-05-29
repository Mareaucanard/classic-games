extends Area2D
class_name BombermanBlock

signal exploded(BombermanBlock)

var has_door = false

func destroyed():
	exploded.emit(self)
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is BombermanExplosion:
		destroyed()
