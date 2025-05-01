extends Node2D

@export var GhostEatenText: PackedScene
@onready var ScoreLabel = $GameZone/ScoreUI/ScoreVbox/Score
@onready var HighscoreLabel = $GameZone/ScoreUI/HighscoreVbox/Score
@onready var LivesUI := $GameZone/BottomUI/HBoxContainer.get_children()
@onready var Maze = $Maze
@onready var ghosts: Array[PacmanGhost] = [$Ghosts/Clyde, $Ghosts/Blinky, $Ghosts/Pinky, $Ghosts/Inky]
var score: int = 0
var highscore: int = 0
var lives = 5

var munch_metronome = false

var ghosts_vulnerable = false
var ghost_eaten_counter = 0


func reset_game():
	enable_all_pellets()
	lives = 5
	score = 0
	ScoreLabel.text = str(score)
	for ghost in ghosts:
		ghost.global_position = ghost.spawn_point
	update_lives()
	respawn_pacman()
	
	
func update_lives():
	var index = 0
	for life in LivesUI:
		index += 1
		if lives >= index:
			life.visible = true
		else:
			life.visible = false

func _ready() -> void:
	var data = SaveUtils.read_data()
	if "PacmanHighscore" in data:
		highscore = data["PacmanHighscore"]
		HighscoreLabel.text = str(highscore)
	for ghost in ghosts:
		ghost.game_area_origin = $Navigation/TopLeft.global_position
		ghost.respawn_point = $Navigation/Respawn.global_position
		var width = $Navigation/TopRight.global_position.x - $Navigation/TopLeft.global_position.x
		var height = $Navigation/BottomLeft.global_position.y - $Navigation/TopLeft.global_position.y
		ghost.game_area_size = Vector2(width, height)
		ghost.pacman = $Pacman
		ghost.blinky = $Ghosts/Blinky
		ghost.running = true
		ghost.spawn_point = ghost.global_position
		ghost.killed_player.connect(_on_pacman_death)
		ghost.eaten.connect(_on_ghost_eaten)
	connect_pellets_signals()
	reset_game()
	HighscoreLabel.text = str(highscore)
	

func all_pellets_go_eaten() -> bool:
	var pellets = get_tree().get_nodes_in_group("PacmanPellet")
	return pellets.all(func (pellet: PacmanPellet): return not pellet.is_enabled())

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("go_to_main_menu"):
		if score > highscore:
			highscore = score
			HighscoreLabel.text = str(highscore)
			SaveUtils.save_data({"PacmanHighscore": highscore})
		get_tree().change_scene_to_file("res://Menu/Menu.tscn")


func apply_to_pellets(method_name: StringName):
	get_tree().call_group("PacmanPellet", method_name)

func enable_all_pellets():
	apply_to_pellets("enable")

func disable_all_pellets():
	apply_to_pellets("disable")

func connect_pellets_signals():
	for pellet in get_tree().get_nodes_in_group("PacmanPellet"):
		pellet.got_eaten.connect(on_pellet_got_eaten)

func _on_ghost_eaten(ghost: PacmanGhost):
	$Sounds/PacmanEatghost.play()
	ghost.state = ghost.state_enum.EATEN
	ghost_eaten_counter += 1
	var points = 200 * 2 ** ghost_eaten_counter
	score += points
	ScoreLabel.text = str(score)
	var text = GhostEatenText.instantiate()
	text.position = ghost.position + Vector2(0, -5)
	text.set_text(str(points))
	add_child(text)
	
	

func _on_pacman_death():
	for ghost in ghosts:
		ghost.running = false
	$Pacman.alive = false
	$Pacman.freeze_anim()
	await get_tree().create_timer(1).timeout
	$Pacman.play_death_animation()
	await get_tree().create_timer(11.0 / 10.0).timeout
	$Pacman.freeze_anim()
	await get_tree().create_timer(1).timeout
	lives -= 1
	update_lives()
	if lives < 0:
		game_over()
	else:	
		respawn_pacman()



func respawn_pacman():
	ghosts_vulnerable = false
	$Timers/GhostsVulnerability.stop()
	$Pacman.global_position = $PacmanSpawn.global_position
	$Pacman.alive = false
	for ghost in ghosts:
		ghost.global_position = ghost.spawn_point
		ghost.visible = true
		ghost.running = false
		ghost.state = ghost.state_enum.CHASING
	$Pacman.respawn()
	$Ready.visible = true
	$Sounds/PacmanBeginning.play()
	await get_tree().create_timer(4.22).timeout
	$Ready.visible = false
	$Pacman.alive = true
	for ghost in ghosts:
		ghost.running = true
	
	

func game_over():
	$Pacman.freeze_anim()
	$Pacman.visible = false
	$GameOver.visible = true
	apply_to_pellets("pause_anim")
	await get_tree().create_timer(0.5).timeout
	if score > highscore:
		highscore = score
		HighscoreLabel.text = str(highscore)
		SaveUtils.save_data({"PacmanHighscore": highscore})
	await get_tree().create_timer(1.5).timeout
	reset_game()
	$Pacman.visible = true
	$GameOver.visible = false
	apply_to_pellets("resume_anim")

func victory():
	$Pacman.alive = false
	$Pacman.freeze_anim()
	for ghost in ghosts:
		ghost.running = false
	await get_tree().create_timer(1.5).timeout
	for ghost in ghosts:
		ghost.visible = false
	for i in range(10):
		if i % 2 == 1:
			Maze.modulate = Color(0, 0, 255)
		else:
			Maze.modulate = Color(255, 255, 255)
		await get_tree().create_timer(0.33).timeout
	respawn_pacman()
	enable_all_pellets()

func on_pellet_got_eaten(pellet: PacmanPellet):
	if munch_metronome:
		$Sounds/Munch1.play()
	else:
		$Sounds/Munch2.play()
	munch_metronome = !munch_metronome
	if pellet.is_big_pellet():
		$Timers/GhostsVulnerability.start()
		ghosts_vulnerable = true
		for ghost in ghosts:
			if ghost.state == ghost.state_enum.CHASING:
				ghost.state = ghost.state_enum.VULNERABLE
	score += pellet.get_score()
	ScoreLabel.text = str(score)
	if all_pellets_go_eaten():
		victory()


func _on_ghosts_vulnerability_timeout() -> void:
	ghost_eaten_counter = 0
	
	for ghost in ghosts:
		if ghost.state == ghost.state_enum.VULNERABLE:
			ghost.state = ghost.state_enum.CHASING
