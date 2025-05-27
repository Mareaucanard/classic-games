extends Node2D

class_name ConnectFourMain

@export var hole: PackedScene = preload("res://Games/ConnectFour/Hole.tscn")
@onready var origin = $Marker2D

var showed_hole: ConnectFourHole

const width = 6
const height = 7
const offset = ConnectFourHole.RADIUS * 2 * 1.1

var playing = true
var board = []

var is_turn_red = true

func _ready() -> void:
	for row in range(height):
		var board_row = []
		for column in range(width):
			var pos = origin.position + Vector2(offset * (row  - 3), offset * -column)
			var cur_hole = hole.instantiate() as ConnectFourHole
			cur_hole.position = pos
			board_row.append(cur_hole)
			add_child(cur_hole)
		board.append(board_row)
		
	showed_hole = hole.instantiate()
	showed_hole.z_index = 1
	showed_hole.position = Vector2(get_global_mouse_position().x, 100)
	add_child(showed_hole)
	showed_hole.change_color(showed_hole.HOLE_STATE.RED)

func _process(delta: float) -> void:
	
	showed_hole.position = Vector2(get_global_mouse_position().x, 100)
	
func find_column(pos: Vector2) -> int:
	var r = ((pos.x + 3*offset/2 - origin.position.x) / offset) + 3
	if r < 1 or r > 8:
		return -1
	return r - 1

func on_victory(c: ConnectFourHole.HOLE_STATE):
	playing = false
	showed_hole .visible = false
	if c == ConnectFourHole.HOLE_STATE.RED:
		$ColorRect2/Label.text = "Red won!"
		$ColorRect2/Label.modulate = Color(255, 0, 0)
	else:
		$ColorRect2/Label.text = "Yellow won!"
		$ColorRect2/Label.modulate = Color(255, 255, 0)
		

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("go_to_main_menu"):
		get_tree().change_scene_to_file("res://Menu/Menu.tscn")
	
	if Input.is_action_just_pressed("minesweeper_reset"):
		get_tree().reload_current_scene()
	
	
	if playing == false:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed == true:
			var column = find_column(event.position)
			if column == -1:
				return
			if drop_on_column(column):
				var c = ConnectFourHole.HOLE_STATE.YELLOW if is_turn_red else ConnectFourHole.HOLE_STATE.RED
				if check_for_victory(c):
					on_victory(c)

func check_for_victory(c: ConnectFourHole.HOLE_STATE) -> bool:
	# Check for rows
	for i in range(width - 3):
		for j in range(height):
			if board[j][i].state == c and board[j][i+1].state == c and board[j][i+2].state == c and board[j][i+3].state == c: 
				return true
	
	# Check for columns
	for j in range(height - 3):
		for i in range(width):
			if board[j][i].state == c and board[j+1][i].state == c and board[j+2][i].state == c and board[j+3][i].state == c: 
				return true
				
	# Check upwards diagonals
	for i in range(width - 3):
		for j in range(3, height):
			if board[j][i].state == c and board[j-1][i+1].state == c and board[j-2][i+2].state == c and board[j-3][i+3].state == c: 
				return true
	
	
	
	# Check downwards diagonals
	for i in range(width - 3):
		for j in range(height - 3):
			if board[j][i].state == c and board[j+1][i+1].state == c and board[j+2][i+2].state == c and board[j+3][i+3].state == c: 
				return true
	
	return false

func drop_on_column(column: int) -> bool:
	for item in board[column] as Array[ConnectFourHole]:
		if item.state == item.HOLE_STATE.EMPTY:
			if is_turn_red:
				item.change_color(item.HOLE_STATE.RED)
				showed_hole.change_color(item.HOLE_STATE.YELLOW)
			else:
				item.change_color(item.HOLE_STATE.YELLOW)
				showed_hole.change_color(item.HOLE_STATE.RED)
			is_turn_red = !is_turn_red
			return true
	return false
	
