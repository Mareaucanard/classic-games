extends Node2D

@onready var ScoreLabel = $GameZone/ScoreUI/ScoreVbox/Score
@onready var HighscoreLabel = $GameZone/ScoreUI/HighscoreVbox/Score
var score = 0

func _ready() -> void:
	enable_all_pellets()
	connect_pellets_signals()

func all_pellets_go_eaten() -> bool:
	var pellets = get_tree().get_nodes_in_group("PacmanPellet")
	return pellets.all(func (pellet: PacmanPellet): return not pellet.is_enabled())
	

func _process(delta: float) -> void:
	if all_pellets_go_eaten():
		print("All pellets go eaten")
		enable_all_pellets()

func apply_to_pellets(method_name: StringName):
	get_tree().call_group("PacmanPellet", method_name)

func enable_all_pellets():
	apply_to_pellets("enable")

func disable_all_pellets():
	apply_to_pellets("disable")

func connect_pellets_signals():
	for pellet in get_tree().get_nodes_in_group("PacmanPellet"):
		var p1: PacmanPellet = pellet
		p1.got_eaten.connect(on_pellet_got_eaten)

func on_pellet_got_eaten(pellet: PacmanPellet):
	score += pellet.get_score()
	ScoreLabel.text = str(score)
	print(score)
