extends Node2D
class_name SpaceInvadersEnemyProjectile

var max_y = 607
var speed = 250

var explosion_miss: PackedScene = preload("res://Games/Space invaders/Actors/Projectiles/projectileExplosion.tscn")

func _ready() -> void:
	add_to_group("projectile")
	$Area2D/AnimatedSprite2D.play("type%d" % randi_range(1, 2))

func _process(delta: float) -> void:
	position += Vector2(0,speed) * delta
	
	if global_position.y > max_y:
		var e = explosion_miss.instantiate()
		e.global_position = global_position
		get_tree().get_root().add_child(e)
		queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is SpaceInvadersPlayer:
		area.get_parent().got_hit()
	else:
		var e = explosion_miss.instantiate()
		e.global_position = global_position
		get_tree().get_root().add_child(e)
	queue_free()
