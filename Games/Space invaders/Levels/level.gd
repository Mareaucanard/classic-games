extends Node2D

@export var x_offset: int = 40
@export var y_offset: int = 40

@export var crab: PackedScene
@export var squid: PackedScene
@export var enemy3: PackedScene

var enemy_per_row = 11
@onready var row_enemy_types: Array[PackedScene] = [squid, crab, crab, enemy3, enemy3]
var alien_grid: Array[SpaceInvadersAlien] = []
var UFO_scene = preload("res://Games/Space invaders/Actors/Characters/UFO.tscn")
var UFO_text = preload("res://Games/Space invaders/Actors/Characters/UFO_text.tscn")

var current_swing_direction = true #true means RIGHT, false means LEFT
var max_left = 365
var max_right = 790
var player_dying = false

var score = 0
var highscore = 0
var lives = 3

@onready var move_sounds: Array[AudioStreamPlayer] = [
	$Audio/InvadersMove/Invader1,
	$Audio/InvadersMove/Invader2,
	$Audio/InvadersMove/Invader3,
	$Audio/InvadersMove/Invader4
]
var move_sounds_pointer = 0

@onready var player: SpaceInvadersPlayer = $Path2D/PathFollow2D/Player

func _ready() -> void:
	$UI/Background/Pause.visible = false
	spawn_aliens()
	process_mode = Node.PROCESS_MODE_ALWAYS
	var data = SaveUtils.read_data()
	if "SpaceInvadersHighscore" in data:
		highscore = data["SpaceInvadersHighscore"]
		$UI/Background/HBoxContainer/Highscore/ScoreLabel.text = "%04d" % highscore
		

func clear_alien_grid():
	for alien in alien_grid:
		alien.queue_free()

func spawn_aliens():
	current_swing_direction = true
	next_ufo_spawn()
	clear_alien_grid()
	var y_pos = $AlienSpawn.global_position.y
	var x_pos = $AlienSpawn.global_position.x
	var row_index = 0
	for enemy_type in row_enemy_types:
		for i in range(enemy_per_row):
			var alien: SpaceInvadersAlien = enemy_type.instantiate()
			alien.position = Vector2(x_pos + x_offset * i, y_pos)
			alien.row_index = (4 - row_index)
			alien.column_index = i
			alien.waiting_for_move = true
			alien.ordered_index = (4 - row_index) * enemy_per_row + i
			alien.connect("exploded", on_alien_exploded)
			add_child(alien)
			alien_grid.push_front(alien)
		row_index += 1
		y_pos += y_offset
	alien_grid.sort_custom(func(a, b): return a.ordered_index < b.ordered_index)
	update_delay()
	for i in range(enemy_per_row):
		update_fire_row(i)

func update_fire_row(column_index: int):
	var column = alien_grid.filter(func(alien: SpaceInvadersAlien): return alien.column_index == column_index)
	if len(column) == 0:
		return
	var lowest: SpaceInvadersAlien = column[0]
	for alien: SpaceInvadersAlien in column:
		if alien.row_index < lowest.row_index:
			lowest = alien
	lowest.should_fire = true

func update_delay():
	var i = 0
	for alien in alien_grid:
		i = i + 1
		alien.time_to_wait = compute_delay(len(alien_grid)) / (len(alien_grid) + 1) * i
	

func on_ufo_exploded(alien):
	score += player.UFO_values[player.UFO_pointer]
	var text = UFO_text.instantiate()
	text.global_position = alien.global_position
	add_child(text)
	$UI/Background/HBoxContainer/Score/ScoreLabel.text = "%04d" % score


func on_alien_exploded(alien: SpaceInvadersAlien):
	alien_grid.erase(alien)
	score += alien.points
	$UI/Background/HBoxContainer/Score/ScoreLabel.text = "%04d" % score
	if len(alien_grid) == 0:
		spawn_aliens()
	update_delay()
	update_fire_row(alien.column_index)

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
	move_sounds[move_sounds_pointer].play()
	move_sounds_pointer = (move_sounds_pointer + 1) % 4

func move_player(delta: float):
	var dir = 0
	if Input.is_action_pressed("left"):
		dir -= 1
	if Input.is_action_pressed("right"):
		dir += 1
	
	var change =  delta * dir * 0.3
	$Path2D/PathFollow2D.progress_ratio = clamp($Path2D/PathFollow2D.progress_ratio + change, 0.0, 1.0)
	
	if Input.is_action_just_pressed("fire"):
		player.fire()

var move_delta_sum: float = 0
var fire_delta_sum: float = 0
var enemy_firing_speed: float = 1
var UFO_delta: float = 0
var hard_mode = 0

func next_ufo_spawn():
	UFO_delta = randf_range(10.0, 40.0)

func switch_pause():
	var new_pause = !get_tree().paused
	get_tree().paused = new_pause

func _process(delta: float) -> void:
	if not player_dying and Input.is_action_just_pressed("pause"):
		switch_pause()
		$UI/Background/Pause.visible = !$UI/Background/Pause.visible
	if Input.is_action_just_pressed("hard_mode"):
		hard_mode = min(hard_mode + 1, 5)
	if get_tree().paused == true:
		return
	
	move_delta_sum += delta
	fire_delta_sum += delta
	UFO_delta -= delta
	if UFO_delta <= 0:
		next_ufo_spawn()
		var ufo: SpaceInvadersUFO = UFO_scene.instantiate()
		ufo.position = $UFOSpawn.position
		ufo.connect("exploded", on_ufo_exploded)
		add_child(ufo)
		
	var cur_delay = compute_delay(len(alien_grid))
	while move_delta_sum >= cur_delay:
		move_delta_sum -= cur_delay
		move_aliens()
	while fire_delta_sum >= enemy_firing_speed:
		if randi_range(0, 1) == 0:
			alien_grid.filter(func(alien: SpaceInvadersAlien): return alien.should_fire).pick_random().fire()
		if hard_mode == 0:
			fire_delta_sum -= enemy_firing_speed
		else:
			fire_delta_sum -= 0.1 / (2 ** hard_mode)
	move_player(delta)


func _on_player_player_got_hit() -> void:
	switch_pause()
	player_dying = true
	get_tree().call_group("projectile", "queue_free")
	get_tree().call_group("explosion", "queue_free")
	
func _on_player_revived() -> void:
	switch_pause()
	player_dying = false
	$Path2D/PathFollow2D.progress_ratio = 0.5


@onready var lives_counter = $UI/Background/VBoxContainer/HBoxContainer/MarginContainer/HBoxContainer/LivesCounter
@onready var lives_ship1 = $"UI/Background/VBoxContainer/HBoxContainer/MarginContainer/HBoxContainer/Ship 1"
@onready var lives_ship2 = $"UI/Background/VBoxContainer/HBoxContainer/MarginContainer/HBoxContainer/Ship 2"
@onready var GameOver = $UI/Background/GameOver

func update_lives():
	lives_counter.text = "%d" % lives
	lives_ship1.visible = false
	lives_ship2.visible = false
	
	if lives >= 2:
		lives_ship1.visible = true
	if lives >= 3:
		lives_ship2.visible = true
		
	
func game_over():
	for alien in alien_grid:
		alien.queue_free()
	alien_grid = []
	GameOver.playback_speed = 0.75

func _on_player_finish_hit_animation() -> void:
	lives -= 1
	update_lives()
	if lives == 0:
		game_over()
	else:
		player.revive()

func _on_game_over_done() -> void:
	var routine = get_tree().create_timer(1.0).timeout
	lives = 3
	hard_mode = 0
	if score > highscore:
		highscore = score
		SaveUtils.save_data({"SpaceInvadersHighscore": highscore})
	score = 0
	await routine
	GameOver.visible_ratio = 0
	player.revive_effects()
	update_lives()
	spawn_aliens()
	$UI/Background/HBoxContainer/Score/ScoreLabel.text = "%04d" % score
	$UI/Background/HBoxContainer/Highscore/ScoreLabel.text = "%04d" % highscore
	
