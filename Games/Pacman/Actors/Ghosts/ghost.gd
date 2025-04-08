extends Area2D
class_name Ghost

var speed = 100
@onready var nav: NavigationAgent2D = $NavigationAgent2D

enum ghost_type {CLYDE, PINKY, INKY, BLINKY}

@export var ghost: ghost_type

signal colided_with_player(Ghost)

func straighten_vector(vec: Vector2):
	var smallest_distance = INF
	var smallest_distance_dir = Vector2.ZERO
	var potential_directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	for direction in potential_directions:
		var cur_distance = vec.distance_to(direction)
		if cur_distance < smallest_distance:
			smallest_distance = cur_distance
			smallest_distance_dir = direction
	return smallest_distance_dir

func _physics_process(delta: float) -> void:
	var direction = Vector2()
	
	nav.target_position = get_global_mouse_position()
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	#direction = straighten_vector(direction)
			
	var mov = direction * speed * delta
	position += mov

func _on_body_entered(body: Node2D) -> void:
	colided_with_player.emit(self)
