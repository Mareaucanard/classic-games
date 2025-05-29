extends Area2D
class_name BombermanBlock

signal exploded(BombermanBlock)

var has_door = false
var item_scene = preload("res://Games/Bomberman/Actors/Item.tscn")

func spawn_item():
	var r = randi_range(0, 2)
	var item = item_scene.instantiate() as BombermanItem
	
	if r == 0:
		item.type = item.POWER_TYPE.SPEED
	elif r == 1:
		item.type = item.POWER_TYPE.BOMBS		
	elif r == 2:
		item.type = item.POWER_TYPE.EXPLOSION_RADIUS
	item.position = position
	get_parent().call_deferred("add_child", item)

func destroyed():
	if randf() < 0.1:
		spawn_item()
	exploded.emit(self)
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is BombermanExplosion:
		destroyed()
