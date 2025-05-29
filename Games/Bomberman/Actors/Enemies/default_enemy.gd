extends Area2D
class_name BombermanEnemy

signal died(BombermanEnemy)

var moving := false
var coordinates = Vector2i(1,1)
var moving_dir := Vector2.DOWN
var distance_left := 16.0
var speed := 25.0
var alive = true


func move_entity(delta: float):
	var target_position := moving_dir *  speed * delta
	if target_position.length() > distance_left:
		target_position *= distance_left / target_position.length() 
		moving = false
		$AnimatedSprite2D.stop()
	
	position += target_position
	distance_left -= target_position.length()


func handle_moving_input() -> void:
	var rng = randi_range(0, 4) # Intentional 4 = do nothing
	
	if rng == 0:
		$AnimatedSprite2D.play("up")
		moving = true
		moving_dir = Vector2.UP
		distance_left = 16.0
	elif rng == 1:
		$AnimatedSprite2D.play("right")
		moving = true
		moving_dir = Vector2.RIGHT
		distance_left = 16.0
	elif rng == 2:
		$AnimatedSprite2D.play("down")
		moving = true
		moving_dir = Vector2.DOWN
		distance_left = 16.0
	elif rng == 3:
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
		
		var b = get_tree().get_nodes_in_group("bombermainscene")
		if len(b) != 0:
			for block in b[0].blocks:
				if block.position.distance_to(position + moving_dir * 16) < 15:
					moving = false
					break
				
		
		if moving:
			coordinates = t_cord
		else:
			$AnimatedSprite2D.stop()

func _process(delta: float) -> void:
	if !alive:
		return
	
	if !moving:
		handle_moving_input()
	else:
		move_entity(delta)

func _on_area_entered(_area: Area2D) -> void: # Always explosion
	died.emit(self)
	$CollisionShape2D.set_deferred("disabled", true)
	alive = false
	$AnimatedSprite2D.play("death")
	await get_tree().create_timer(2).timeout
	queue_free()
