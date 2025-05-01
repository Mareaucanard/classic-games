extends Node2D

@onready var board: Minesweeper_grid = $Mine_board

@onready var timer_label = $UI/VBoxContainer/MarginContainer/VBoxContainer/Game_UI/MarginContainer2/Timer
@onready var flags_counter_label = $UI/VBoxContainer/MarginContainer/VBoxContainer/Game_UI/MarginContainer/Flags
@onready var smiley_face = $UI/VBoxContainer/MarginContainer/VBoxContainer/Game_UI/TextureRect

@onready var timer = $Timer

var textures := {
	"WON": load("res://Games/MineSweeper/Ressources/button_cleared.png"),
	"LOST": load("res://Games/MineSweeper/Ressources/button_dead.png"),
	"NORMAL": load("res://Games/MineSweeper/Ressources/button_smile.png")
}

var seconds: int = 0

func _ready():
	_on_beginner_pressed()

func _on_beginner_pressed() -> void:
	board.update_board_size_and_mines(8, 8, 10)

func _on_intermediate_pressed() -> void:
	board.update_board_size_and_mines(16, 16, 40)
	

func _on_expert_pressed() -> void:
	board.update_board_size_and_mines(31, 16, 99)
	

func _on_reset_pressed() -> void:
	board.reset()


func _on_timer_timeout() -> void:
	seconds = min(seconds + 1, 999)
	timer_label.text = str(seconds).pad_zeros(3)


func _on_mine_board_flag_change(number_of_flags: Variant) -> void:
	flags_counter_label.text = str(board.number_of_mines - number_of_flags).pad_zeros(3)


func _on_mine_board_has_reset() -> void:
	seconds = 0
	timer_label.text = str(seconds).pad_zeros(3)
	flags_counter_label.text = str(board.number_of_mines).pad_zeros(3)
	timer.stop()
	smiley_face.texture = textures.NORMAL
	


func _on_mine_board_started() -> void:
	timer.start(1)


func _on_custom_pressed() -> void:
	var width_input = $UI/VBoxContainer/MarginContainer/VBoxContainer/MarginContainer/Buttons/MarginContainer/HBoxContainer/Width
	var height_input = $UI/VBoxContainer/MarginContainer/VBoxContainer/MarginContainer/Buttons/MarginContainer/HBoxContainer/Height
	var mines_input = $UI/VBoxContainer/MarginContainer/VBoxContainer/MarginContainer/Buttons/MarginContainer/HBoxContainer/Mines
	
	var width = int(width_input.text)
	var height = int(height_input.text)
	var mines = int(mines_input.text)
	
	var max_width = 70
	var max_height = 32
	
	if width <= 1 or width > max_width:
		return
	if height <= 1 or height > max_height:
		return
	if mines < 1 or mines > (width * height / 3) or mines > 999:
		return
	
	board.update_board_size_and_mines(width, height, mines)


func _on_mine_board_game_ended(won: bool) -> void:
	timer.stop()
	if won:
		smiley_face.texture = textures.WON
	else:
		smiley_face.texture = textures.LOST


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("go_to_main_menu"):
		get_tree().change_scene_to_file("res://Menu/Menu.tscn")
	
	if Input.is_action_just_pressed("minesweeper_reset"):
		_on_reset_pressed()

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Menu/Menu.tscn")
