extends Node2D
class_name SpaceInvadersAlien

@export var points = 0
var projectile: PackedScene = preload("res://Games/Space invaders/Actors/Projectiles/enemyProjectile.tscn")

var waiting_for_move = false
var delta_time_waited = 0
var time_to_wait = 0.0
var new_offset = Vector2(0,0)
var ordered_index = -1
var cooldown = 0.1

var row_index = 0
var column_index = 0
var should_fire = false

signal exploded(Alien)

func _ready() -> void:
	visible = false


func _process(delta: float) -> void:
	cooldown -= delta
	if waiting_for_move:
		delta_time_waited += delta
		if delta_time_waited >= time_to_wait:
			do_move()

func fire():
	
	if visible == false or cooldown >= 0:
		return
	var p = projectile.instantiate()
	p.position = global_position + Vector2(1, 8)
	get_tree().get_root().add_child(p)
	cooldown = 0.1

func do_move():
	delta_time_waited = 0
	waiting_for_move = false
	if visible == true:
		change_anim_frame()
		position += new_offset
	else:
		visible = true

func set_next_move(offset: Vector2):
	if waiting_for_move == true:
		do_move()
	waiting_for_move = true
	delta_time_waited = 0
	new_offset = offset
	
	
func explode():
	exploded.emit(self)
	queue_free()

func change_anim_frame():
	if $Area2D/AnimatedSprite2D.frame == 0:
		$Area2D/AnimatedSprite2D.frame = 1
	else:
		$Area2D/AnimatedSprite2D.frame = 0
