extends CharacterBody2D
class_name PacmanPlayer

var speed = 200
@onready var sprite = $AnimatedSprite2D


func _ready() -> void:
	pass


# Pacman can only can in 4 directions, so no diagonals
func handle_direction_input():
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
			var pos_before: Vector2 = position
			velocity = dir_vec * speed
			move_and_slide()
			var distance_moved = position.distance_to(pos_before)
			if distance_moved >= 1:
				sprite.play(dir_name)
				return
	velocity = Vector2.ZERO
	sprite.play("spawning")

func handle_wrapping():
	if position.x < 310:
		position.x += 520
	if position.x > 840:
		position.x -= 520

func _physics_process(delta: float) -> void:
	handle_direction_input()
	handle_wrapping()
