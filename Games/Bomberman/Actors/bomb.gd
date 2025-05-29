extends Area2D
class_name BombermanBomb

var explosion_level = 1
var explosion_class := preload("res://Games/Bomberman/Actors/Explosion.tscn")

signal on_exploded(BombermanBomb)

func explode():
	var explosion = explosion_class.instantiate() as BombermanExplosion
	explosion.position = position
	explosion.change_explosion_size(explosion_level)
	get_parent().call_deferred("add_child", explosion)
	on_exploded.emit(self)
	queue_free()

func _on_timer_timeout() -> void:
	explode()

func _on_area_entered(area: Area2D) -> void:
	if area is BombermanExplosion:
		explode()
