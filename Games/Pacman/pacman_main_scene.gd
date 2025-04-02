extends Node2D

@onready var ScoreLabel = $GameZone/ScoreUI/ScoreVbox/Score
@onready var HighscoreLabel = $GameZone/ScoreUI/HighscoreVbox/Score
@onready var LivesUI := $GameZone/BottomUI/HBoxContainer.get_children()
@onready var Maze = $Maze
var score = 0
var highscore = 0
var lives = 5

func reset_game():
	enable_all_pellets()
	lives = 1
	score = 0
	ScoreLabel.text = str(score)
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
	connect_pellets_signals()
	reset_game()
	HighscoreLabel.text = str(highscore)
	

func all_pellets_go_eaten() -> bool:
	var pellets = get_tree().get_nodes_in_group("PacmanPellet")
	return pellets.all(func (pellet: PacmanPellet): return not pellet.is_enabled())

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("fire"):
		_on_pacman_death($Pacman)
	if Input.is_action_just_pressed("hard_mode"):
		for pellet in get_tree().get_nodes_in_group("PacmanPellet"):
			var p1: PacmanPellet = pellet
			p1._on_body_entered($Pacman)

func apply_to_pellets(method_name: StringName):
	get_tree().call_group("PacmanPellet", method_name)

func enable_all_pellets():
	apply_to_pellets("enable")

func disable_all_pellets():
	apply_to_pellets("disable")

func connect_pellets_signals():
	for pellet in get_tree().get_nodes_in_group("PacmanPellet"):
		pellet.got_eaten.connect(on_pellet_got_eaten)

func _on_pacman_death(pacman: PacmanPlayer):
	pacman.alive = false
	pacman.freeze_anim()
	await get_tree().create_timer(1).timeout
	pacman.play_death_animation()
	await get_tree().create_timer(11.0 / 10.0).timeout
	lives -= 1
	update_lives()
	if lives < 0:
		game_over()
	else:	
		respawn_pacman()



func respawn_pacman():
	$Pacman.global_position = $PacmanSpawn.global_position
	$Pacman.alive = false
	$Pacman.respawn()
	$Ready.visible = true
	await get_tree().create_timer(1).timeout
	$Ready.visible = false
	$Pacman.alive = true
	
	

func game_over():
	$Pacman.freeze_anim()
	$Pacman.visible = false
	$GameOver.visible = true
	apply_to_pellets("pause_anim")
	await get_tree().create_timer(0.5).timeout
	highscore = score
	HighscoreLabel.text = str(highscore)
	await get_tree().create_timer(1.5).timeout
	reset_game()
	$Pacman.visible = true
	$GameOver.visible = false
	apply_to_pellets("resume_anim")

func victory():
	$Pacman.alive = false
	for i in range(10):
		if i % 2 == 1:
			Maze.modulate = Color(0, 0, 255)
		else:
			Maze.modulate = Color(255, 255, 255)
		await get_tree().create_timer(0.33).timeout
	respawn_pacman()
	enable_all_pellets()

func on_pellet_got_eaten(pellet: PacmanPellet):
	score += pellet.get_score()
	ScoreLabel.text = str(score)
	if all_pellets_go_eaten():
		victory()
