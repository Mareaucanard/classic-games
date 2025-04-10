extends CharacterBody2D
class_name PacmanPlayer

var speed = 200
var alive = true
var facing_dir = Vector2.ZERO
@onready var sprite = $AnimatedSprite2D
@onready var nav = $NavigationAgent2D

func _ready() -> void:
	pass

# Pacman can only can in 4 directions, so no diagonals
func handle_direction_input(delta: float):
	var direction_string = [
		["up", Vector2.UP],
		["right", Vector2.RIGHT],
		["down", Vector2.DOWN],
		["left", Vector2.LEFT],
	]
	for item in direction_string:
		var dir_name = item[0]
		var dir_vec = item[1]
		if Input.is_action_pressed(dir_name):
			nav.target_position = position + dir_vec * 20
			if not nav.is_navigation_finished():
				$AnimatedSprite2D.play(dir_name)
				var direction = nav.get_next_path_position() - global_position
				direction = direction.normalized()
				var mov = direction * speed * delta
				position += mov
				return
	velocity = Vector2.ZERO
	facing_dir = Vector2.ZERO
	sprite.play("spawning")

func handle_wrapping():
	position.x = round(position.x)
	position.y = round(position.y)
	if position.x < 310:
		position.x += 520
	if position.x > 840:
		position.x -= 520

func freeze_anim():
	$AnimatedSprite2D.pause()

func respawn():
	$AnimatedSprite2D.play("spawning")

func play_death_animation():
	$AnimatedSprite2D.play("death")

func _physics_process(delta: float) -> void:
	if alive:
		handle_direction_input(delta)
		handle_wrapping()
