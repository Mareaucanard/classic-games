extends Area2D
class_name BombermanPlayer

signal died()
signal finished_dying()

var bomb_scene = preload("res://Games/Bomberman/Actors/Bomb.tscn")

var explosion_level = 1
var max_bombs = 2
var alive = true

var moving := false
var coordinates = Vector2i(1,1)
var moving_dir := Vector2.DOWN
var distance_left := 16.0
var speed := 500.0

var bombs: Array[BombermanBomb]

func _physics_process(delta: float) -> void:
	
	if not alive:
		return
	
	if !moving:
		handle_moving_input()
	else:
		move_player(delta)
	
	if Input.is_action_just_pressed("fire"):
		if len(bombs) < max_bombs:
			var bomb = bomb_scene.instantiate() as BombermanBomb
			bomb.position = position
			bomb.explosion_level = explosion_level
			bombs.append(bomb)
			bomb.connect("on_exploded", on_bomb_exploded)
			$"..".add_child(bomb)

func on_bomb_exploded(bomb: BombermanBomb):
	bombs.erase(bomb)

func die():
	alive = false
	moving = false
	coordinates = Vector2i(1, 1)
	died.emit()
	$AnimatedSprite2D.play("death")
	await get_tree().create_timer(1.0).timeout
	$AnimatedSprite2D.stop()
	finished_dying.emit()

func move_player(delta: float):
	var target_position := moving_dir *  speed * delta
	if target_position.length() > distance_left:
		target_position *= distance_left / target_position.length() 
		moving = false
		$AnimatedSprite2D.stop()
	
	position += target_position
	distance_left -= target_position.length()

func handle_moving_input() -> void:
	if Input.is_action_pressed("up"):
		$AnimatedSprite2D.play("up")
		moving = true
		moving_dir = Vector2.UP
		distance_left = 16.0
	elif Input.is_action_pressed("right"):
		$AnimatedSprite2D.play("right")
		moving = true
		moving_dir = Vector2.RIGHT
		distance_left = 16.0
	elif Input.is_action_pressed("down"):
		$AnimatedSprite2D.play("down")
		moving = true
		moving_dir = Vector2.DOWN
		distance_left = 16.0
	elif Input.is_action_pressed("left"):
		$AnimatedSprite2D.play("left")
		moving = true
		moving_dir = Vector2.LEFT
		distance_left = 16.0

	if moving:
		var t_cord := Vector2i(coordinates.x + moving_dir.x, coordinates.y + moving_dir.y)
		# Borders
		if t_cord.y == 0 or t_cord.y == 12 or t_cord.x == 0 or t_cord.x == 30:
			moving = false
		
		# Inner blocks
		if t_cord.x % 2 == 0 and t_cord.y % 2 == 0:
			moving = false
		
		for block in $"..".blocks:
			if block.position.distance_to(position + moving_dir * 16) < 15:
				moving = false
				break
				
		
		for bomb in bombs:
			if bomb.position.distance_to(position + moving_dir * 16) < 15:
				moving = false
				break
		
		if moving:
			coordinates = t_cord
		else:
			$AnimatedSprite2D.stop()
			


func _on_area_entered(area: Area2D) -> void:
	if area is BombermanExplosion:
		die()
