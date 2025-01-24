extends Node2D

@export var x_offset: int = 40
@export var y_offset: int = 40

@export var crab: PackedScene
@export var squid: PackedScene
@export var enemy3: PackedScene

var enemy_per_row = 11
@onready var row_enemy_types: Array[PackedScene] = [squid, crab, crab, enemy3, enemy3]
var alien_grid: Array[Alien] = []

var current_swing_direction = true #true means RIGHT, false means LEFT
var max_left = 365
var max_right = 790

@onready var player = $Path2D/PathFollow2D/Player

func _ready() -> void:
	spawn_aliens()

func clear_alien_grid():
	for alien in alien_grid:
		alien.queue_free()

func spawn_aliens():
	clear_alien_grid()
	var y_pos = $TopRightSpawn.global_position.y
	var x_pos = $TopRightSpawn.global_position.x
	var enemy_index: int = 0
	var row_index = 0
	for enemy_type in row_enemy_types:
		for i in range(enemy_per_row):
			var alien: Alien = enemy_type.instantiate()
			alien.position = Vector2(x_pos + x_offset * i, y_pos)
			alien.ordered_index = (4 - row_index) * enemy_per_row + i
			alien.connect("exploded", on_alien_exploded)
			add_child(alien)
			alien_grid.push_front(alien)
			enemy_index += 1
		row_index += 1
		y_pos += y_offset
	alien_grid.sort_custom(func(a, b): return a.ordered_index < b.ordered_index)
	update_delay()

func update_delay():
	var i = 0
	for alien in alien_grid:
		i = i + 1
		alien.time_to_wait = compute_delay(len(alien_grid)) / (len(alien_grid) + 1) * i
	

func on_alien_exploded(alien):
	alien_grid.erase(alien)
	update_delay()
	

func compute_delay(aliens_alive: int):
	#var base_result = 2 ** ((55 - 10 * aliens_alive) / 10.0)
	var base_result = 55.0 / (aliens_alive + 1)
	return 1.0 / clamp(base_result, 1, 60)

func get_outliers_position() -> Vector2:
	var min_x = INF
	var max_x = -INF
	for alien in alien_grid:
		if alien.position.x < min_x:
			min_x = alien.position.x
		if alien.position.x > max_x:
			max_x = alien.position.x
	return Vector2(min_x, max_x)
	

func move_aliens():
	var swing_distance = 63.0/8
	var move_down = false
	if current_swing_direction == false:
		swing_distance *= -1
		if get_outliers_position().x <= max_left:
			move_down = true
			current_swing_direction = !current_swing_direction
	else:
		if get_outliers_position().y >= max_right:
			move_down = true
			current_swing_direction = !current_swing_direction
	
	
		
	for alien in alien_grid:
		if move_down:
			alien.set_next_move(Vector2(0, y_offset / 2.0))
		else:
			alien.set_next_move(Vector2(swing_distance, 0))


var delta_sum: float = 0

func move_player(delta: float):
	var dir = 0
	if Input.is_action_pressed("ui_left"):
		dir -= 1
	if Input.is_action_pressed("ui_right"):
		dir += 1
	
	var change =  delta * dir * 0.3
	$Path2D/PathFollow2D.progress_ratio = clamp($Path2D/PathFollow2D.progress_ratio + change, 0.0, 1.0)
	
	if Input.is_action_just_pressed("ui_accept"):
		player.fire()
		

func _process(delta: float) -> void:
	delta_sum += delta
	var cur_delay = compute_delay(len(alien_grid))
	while delta_sum >= cur_delay:
		delta_sum -= cur_delay
		move_aliens()
	move_player(delta)		
