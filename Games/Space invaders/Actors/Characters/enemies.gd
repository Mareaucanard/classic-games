extends Node2D
class_name Alien


var waiting_for_move = false
var delta_time_waited = 0
var time_to_wait = 0.0
var new_offset = Vector2(0,0)
var ordered_index = -1

signal exploded(Alien)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if waiting_for_move:
		delta_time_waited += delta
		if delta_time_waited >= time_to_wait:
			do_move()
	
	
func do_move():
	position += new_offset
	delta_time_waited = 0
	waiting_for_move = false
	change_anim_frame()

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
