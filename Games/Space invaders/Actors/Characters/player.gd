extends Node2D
class_name player


@export var playerProjectile: PackedScene

var projectile = null

func fire():
	if is_instance_valid(projectile):
		return
	projectile = playerProjectile.instantiate()
	projectile.position = global_position + Vector2(1, -8)
	get_tree().get_root().add_child(projectile)
