extends CharacterBody2D

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
		var name = item[0]
		var dir = item[1]
		if Input.is_action_pressed(name):
			var pos_before: Vector2 = position
			velocity = dir * speed
			move_and_slide()
			var distance_moved = position.distance_to(pos_before)
			if distance_moved >= 1:
				sprite.play(name)
				return
	velocity = Vector2.ZERO
	sprite.play("spawning")

func _physics_process(delta: float) -> void:
	handle_direction_input()
