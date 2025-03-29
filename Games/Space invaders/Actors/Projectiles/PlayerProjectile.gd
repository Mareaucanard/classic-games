extends Node2D
class_name SpaceInvadersPlayerProjectile

var explosion_alien: PackedScene = preload("res://Games/Space invaders/Actors/Projectiles/projectile_hit.tscn")
var explosion_miss: PackedScene = preload("res://Games/Space invaders/Actors/Projectiles/projectileExplosion.tscn")
var min_y = 50
var speed = 500

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area2D/AnimatedSprite2D.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += Vector2(0, -speed) * delta
	
	if global_position.y < min_y:
		var e = explosion_miss.instantiate()
		e.global_position = global_position
		get_tree().get_root().add_child(e)
		queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	var e
	if area.get_parent() is SpaceInvadersAlien or area.get_parent() is SpaceInvadersUFO:
		area.get_parent().explode()
		e = explosion_alien.instantiate()
	else:
		e = explosion_miss.instantiate()
	e.global_position = area.global_position
	get_tree().get_root().add_child(e)
	queue_free()
