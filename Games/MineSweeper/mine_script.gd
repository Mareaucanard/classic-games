extends TileMapLayer

class_name Minesweeper_grid

signal flag_change(number_of_flags)
signal lost
signal won
signal has_reset
signal started

const CELLS := {
	"1": Vector2i(0,0),
	"2": Vector2i(1,0),
	"3": Vector2i(2,0),
	"4": Vector2i(3,0),
	"5": Vector2i(4,0),
	"6": Vector2i(0,1),
	"7": Vector2i(1,1),
	"8": Vector2i(2,1),
	"empty": Vector2i(3,1),
	"exploded_mine": Vector2i(4,1),
	"flag": Vector2i(0,2),
	"unexploded_mine": Vector2i(1,2),
	"hidden": Vector2i(2,2)
	
}

@export var columns: int = 8
@export var rows: int = 8
@export var number_of_mines: int = 2

var generated_mines = false
var game_finished = false
var flag_counter = 0

var min_x: int = 0
var max_x: int = 0
var min_y: int = 0
var max_y: int = 0

var mines_coordinates: Array[Vector2i] = []
var flaged_cells: Array[Vector2i] = []
var revealed_cells: Array[Vector2i] = []


const TILE_SET_ID = 0

func reset():
	game_finished = false
	clear()
	for y in rows:
		for x in columns:
			var cell_coordinates = Vector2(x - columns / 2, y - rows / 2)
			set_tile(cell_coordinates, "hidden")
	mines_coordinates = []
	revealed_cells = []
	flaged_cells = []
	flag_counter = 0
	generated_mines = false

func resize(width: int, height: int):
	columns = width
	rows = height
	min_x = -columns/2
	max_x = (columns+1)/2 - 1
	min_y = -rows/2
	max_y = (rows+1)/2 - 1

func _ready():
	resize(columns, rows)
	reset()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_R:
			reset()
			has_reset.emit()
	elif event is InputEventMouseButton:
		if event.pressed == true or game_finished:
			return
		var cell = local_to_map(get_local_mouse_position())
		if event.button_index == 1: # Left click
			on_cell_clicked(cell)
		elif event.button_index == 2: # Right click
			on_place_flag(cell)

func is_inside_board(cell: Vector2i) -> bool:
	return min_x <= cell.x and cell.x <= max_x and min_y <= cell.y and cell.y <= max_y

func count_neighbours(cell: Vector2i) -> int:
	var counter = 0
	for x in range(-1,2):
		for y in range(-1, 2):
			if x == 0 and y == 0:
				continue
			var new_cell = cell + Vector2i(x, y)
			if new_cell in mines_coordinates:
				counter += 1
	return counter

func on_cell_clicked(cell: Vector2i):
	if not is_inside_board(cell) or cell in revealed_cells or cell in flaged_cells:
		return
	if cell in mines_coordinates:
		hit_mine(cell)
		return
	
	if not generated_mines:
		generate_mines(cell)
	revealed_cells.append(cell)
	check_for_victory()
	var num = count_neighbours(cell)
	if num > 0:
		set_tile(cell, str(num))
	else:
		set_tile(cell, "empty")
		for x in range(-1,2):
			for y in range(-1, 2):
				if x == 0 and y == 0:
					continue
				var new_cell = cell + Vector2i(x, y)
				on_cell_clicked(new_cell)

func on_place_flag(cell: Vector2i):
	if not is_inside_board(cell) or cell in revealed_cells:
		return
	var tile_data = get_cell_tile_data(cell)
	var atlas_coord = get_cell_atlas_coords(cell)
	
	if atlas_coord == CELLS.hidden:
		if flag_counter >= number_of_mines:
			return
		flag_counter += 1
		flaged_cells.append(cell)
		set_tile(cell, "flag")
		check_for_victory()
	elif atlas_coord == CELLS.flag:
		flag_counter -= 1
		var index = flaged_cells.find(cell)
		flaged_cells.remove_at(index)
		set_tile(cell, "hidden")
	flag_change.emit(flag_counter)

func hit_mine(cell: Vector2i):
	lost.emit()
	for mine in mines_coordinates:
		set_tile(mine, "unexploded_mine")
	set_tile(cell, "exploded_mine")
	game_finished = true

func check_for_victory():
	if flag_counter == number_of_mines and flag_counter + len(revealed_cells) == columns * rows:
		pass
		won.emit()
		game_finished = true

func set_tile(coordiantes: Vector2i, cell_type: String):
	set_cell(coordiantes, TILE_SET_ID, CELLS[cell_type])

func generate_mines(players_pick: Vector2i):
	var banned_cells: Array[Vector2i] = []
	for y in range(-1, 2):
		for x in range(-1, 2):
			banned_cells.append(players_pick + Vector2i(x, y))
	generated_mines = true
	for i in range(number_of_mines):
		var done = false
		while !done:
			var random_cell = Vector2i(randi_range(min_x, max_x),randi_range(min_y, max_y))
			if  random_cell not in banned_cells and random_cell not in mines_coordinates:
				done = true
				mines_coordinates.append(random_cell)
	for cell_coordinate in mines_coordinates:
		erase_cell(cell_coordinate)
		set_cell(cell_coordinate, TILE_SET_ID, CELLS.hidden, 1)
