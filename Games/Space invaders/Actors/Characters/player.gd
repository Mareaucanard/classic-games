extends Node2D
class_name SpaceInvadersPlayer

var UFO_values = [100, 50, 50, 100, 150, 100, 100, 50, 300, 100, 100, 100, 50, 150, 100]
var UFO_pointer = 0

var dying = false
var reviving = false
var finished_exploding = false
var time_to_live: float = 0

@export var playerProjectile: PackedScene
signal player_got_hit
signal finish_hit_animation
signal revived

var projectile: SpaceInvadersPlayerProjectile

func _ready() -> void:
	$Area2D/AnimatedSprite2D.play("default")

func _process(delta: float) -> void:
	time_to_live -= delta
	if dying == false:
		return

	if not finished_exploding and time_to_live <= 0:
		finished_exploding = true
		$Area2D/AnimatedSprite2D.play("default")
		visible = false
		finish_hit_animation.emit()
	if reviving and time_to_live <= 0:
		revive_effects()

func revive_effects():
	visible = true
	revived.emit()
	dying = false
	reviving = false

func revive():
	reviving = true
	time_to_live = 1.0

func fire():
	if is_instance_valid(projectile):
		return
	$Shoot.play()
	projectile = playerProjectile.instantiate()
	projectile.position = global_position + Vector2(1, -8)
	get_tree().get_root().add_child(projectile)
	UFO_pointer = (UFO_pointer + 1) % 15

func got_hit():
	$Area2D/AnimatedSprite2D.play("explosion")
	$Explosion.play()
	time_to_live = 0.8
	dying = true
	finished_exploding = false
	if is_instance_valid(projectile):
		projectile.queue_free()
	player_got_hit.emit()
