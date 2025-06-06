extends Area2D
class_name PacmanGhost

var speed = 100
@onready var nav: NavigationAgent2D = $NavigationAgent2D
var game_area_origin: Vector2
var game_area_size: Vector2

enum ghost_enum {CLYDE, PINKY, INKY, BLINKY}
enum state_enum {EATEN, SCATTER, CHASING, VULNERABLE}

@export var ghost: ghost_enum
var state: state_enum = state_enum.CHASING

var running = false
var spawn_animation: String
var spawn_point: Vector2
var respawn_point: Vector2
var pacman: PacmanPlayer
var blinky: PacmanGhost


signal killed_player()
signal eaten(PacmanGhost)

func _ready() -> void:
	spawn_animation = $AnimatedSprite2D.animation

func reset_anim():
	$AnimatedSprite2D.play(spawn_animation)
	nav.target_position = spawn_point

func handle_chase():
	if ghost == ghost_enum.CLYDE:
		if pacman.position.distance_to(position) < 100:
			nav.target_position = pacman.position
		elif nav.is_navigation_finished():
			var x_pos = randf_range(0, game_area_size.x)
			var y_pos = randf_range(0, game_area_size.y)
			nav.target_position = game_area_origin + Vector2(x_pos, y_pos)
	elif ghost == ghost_enum.BLINKY:
		nav.target_position = pacman.position
	elif ghost == ghost_enum.PINKY:
		nav.target_position = pacman.position + pacman.facing_dir * 16 * 4
	elif ghost == ghost_enum.INKY:
		var blinky_diff = pacman.position - blinky.position
		nav.target_position = blinky.position + blinky_diff * 2

func handle_target_position():
	if state == state_enum.CHASING:
		handle_chase()
	elif state == state_enum.SCATTER:
		nav.target_position = game_area_origin
	elif state == state_enum.VULNERABLE:
		nav.target_position = position + position - pacman.position
	elif state == state_enum.EATEN:
		nav.target_position = respawn_point

func get_vector_dir(vec: Vector2) -> String:
	var directions_vectors := [
		["up", Vector2.UP],
		["down", Vector2.DOWN],
		["right", Vector2.RIGHT],
		["left", Vector2.LEFT]
	]
	var dir = "up"
	var smallest_distance = INF
	for pair in directions_vectors:
		var dir_string: String = pair[0]
		var dir_vec: Vector2 = pair[1]
		var cur_dist = dir_vec.distance_to(vec)
		if cur_dist < smallest_distance:
			smallest_distance = cur_dist
			dir = dir_string
	return dir

func handle_animation(dir: Vector2):
	if state == state_enum.EATEN:
		$AnimatedSprite2D.play("eyes_" + get_vector_dir(dir))
	elif state == state_enum.VULNERABLE:
		$AnimatedSprite2D.play("scatter")
	else:
		$AnimatedSprite2D.play(get_vector_dir(dir))

func _physics_process(delta: float) -> void:
	if not running:
		return
	var direction = Vector2()
	
	handle_target_position()
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	handle_animation(direction)
	
	if not nav.is_navigation_finished():
		var mov = direction * speed * delta
		position += mov
	elif state == state_enum.EATEN:
		state = state_enum.CHASING
		

func _on_body_entered(_body: Node2D) -> void:
	if state == state_enum.CHASING or state == state_enum.SCATTER:
		killed_player.emit()
	elif state == state_enum.VULNERABLE:
		eaten.emit(self)
