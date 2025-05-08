extends TileMapLayer
class_name TetrisBoard

const width = 10
const height = 24

const FULL_OPACITY_LAYER = 0 
const TRANSPARENT_LAYER = 1

@onready var score_label = $"../../UI/TopLeft/VBoxContainer/Score"

enum COLORS {BLUE, CYAN, GREEN, ORANGE, PURPLE, RED, YELLOW, NONE}
const BLOCK_ATLAS := {
	COLORS.BLUE: Vector2i(0,0),
	COLORS.CYAN: Vector2i(1,0),
	COLORS.GREEN: Vector2i(2,0),
	COLORS.ORANGE: Vector2i(0,1),
	COLORS.PURPLE: Vector2i(1,1),
	COLORS.RED: Vector2i(2,1),
	COLORS.YELLOW: Vector2i(0,2),
	COLORS.NONE: Vector2i(1,2)
}
var board: Array[Array] = []

var active_piece: TetrisPiece
var total_lines_cleared = 0
var back_to_back = false
var score: int = 0
var highscore: int = 0
var combo = 0
var level: int = 1
var piece_held
var just_swapped_piece = false
var t_spin = false
var game_over = false

const max_grace = 0.5
const max_total_grace = 2.0
var grace = 0
var total_grace = 0

var piece_queue: Array[TetrisPiece.PIECES] = []
var piece_falling_delta_sum = 0.0

func _ready():
	var data = SaveUtils.read_data()
	if "TetrisHighscore" in data:
		highscore = data["TetrisHighscore"]
		$"../../UI/TopLeft/VBoxContainer/Highscore".text = str(highscore).pad_zeros(10)
	reset()

func reset():
	score = 0
	combo = 0
	level = 1
	$"../../UI/TopRight/Level".text = "Level %d" % level
	just_swapped_piece = false
	back_to_back = false
	total_lines_cleared = 0
	piece_held = null
	piece_falling_delta_sum = 0.0
	piece_queue = []
	$"../../UI/Gameover".visible = false
	game_over = false
	

	active_piece = TetrisPiece.new()
	init_board()
	generate_queue()
	generate_piece()

func move_piece_down():
	active_piece.pos += Vector2i.DOWN
	
	if not is_piece_valid(active_piece):
		active_piece.pos += Vector2i.UP
		if !Input.is_action_pressed("down") and !Input.is_action_pressed("fire") and grace < max_grace and total_grace < max_total_grace:
			grace += get_process_delta_time()
			total_grace += get_process_delta_time()
		else:
			add_piece_to_board(active_piece)
			if not clear_rows():
				combo = 0
			generate_piece()
	else:
		grace = 0
		piece_falling_delta_sum -= get_level_timer()

func move_piece(vec: Vector2i):
	active_piece.pos += vec
	if not is_piece_valid(active_piece):
		active_piece.pos -= vec
	else:
		grace = 0
		

func rotate_piece(piece: TetrisPiece, dir: bool):
	if dir:
		piece.rotate_clockwise()
	else:
		piece.rotat_counter_clockwise()
	
	t_spin = false
	var base_pos = piece.pos
	var offsets = [[0,0],[-1,0],[1,0],[0,1],[0,1],[0,2],[-1,1],[1,1]]
	for offset in offsets:
		var offset_vec = Vector2i(offset[0], offset[1])
		piece.pos = base_pos + offset_vec
		if is_piece_valid(piece):
			grace = 0
			# Check for t_spin
			if piece.piece_type == piece.PIECES.T:
				var corners_filled = 0
				var tspin_offsets = [[-1,1],[1,1],[1,-1],[-1,-1]]
				for tspin_offset in tspin_offsets:
					var tspin_vec = Vector2i(tspin_offset[0], tspin_offset[1])
					var square = piece.pos + tspin_vec
					if not is_inside_board(square) or board[square.y][square.x] != COLORS.NONE:
						corners_filled += 1
				if corners_filled >= 3:
					t_spin = true
			return
	
	# Undo rotation
	piece.pos = base_pos
	if dir:
		piece.rotat_counter_clockwise()
	else:
		piece.rotate_clockwise()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("minesweeper_reset"):
		reset()
	
	if Input.is_action_just_pressed("go_to_main_menu"):
		get_tree().change_scene_to_file("res://Menu/Menu.tscn")
	
	if game_over:
		return
	
	piece_falling_delta_sum += delta
	
	if piece_falling_delta_sum > get_level_timer():
		move_piece_down()
		if Input.is_action_just_pressed("down"):
			piece_falling_delta_sum = 0

	if Input.is_action_just_pressed("left"):
		move_piece(Vector2i.LEFT)
	if Input.is_action_just_pressed("right"):
		move_piece(Vector2i.RIGHT)
	if Input.is_action_just_pressed("fire"):
		active_piece.pos += get_hardrop_offset()
		move_piece_down()

	if Input.is_action_just_pressed("TetrisRotateClockwise"):
		rotate_piece(active_piece, true)
	if Input.is_action_just_pressed("TetrisRotateCounterClockwise"):
		rotate_piece(active_piece, false)
		

	if Input.is_action_just_pressed("hard_mode"):
		total_lines_cleared = 1000
		level = 30
	
	if Input.is_action_just_pressed("TetrisHold") and not just_swapped_piece:
		if piece_held == null:
			piece_held = active_piece
			active_piece = TetrisPiece.new()
			generate_piece()
			just_swapped_piece = true
		else:
			var tmp = active_piece.piece_type
			active_piece.piece_type = piece_held.piece_type
			if not is_piece_valid(active_piece):
				active_piece.piece_type = tmp
			else:
				piece_held.piece_type = tmp
				active_piece.pos = Vector2i(5,3)
				just_swapped_piece = true
	
	draw_board()
	draw_piece(active_piece)
	draw_next()
	draw_held()


func generate_queue():
	var p = TetrisPiece.PIECES
	var base_list = [p.I, p.J, p.L, p.O, p.S, p.T, p.Z, p.I, p.J, p.L, p.O, p.S, p.T, p.Z]
	base_list.shuffle()
	for shape in base_list:
		piece_queue.append(shape)

func get_hardrop_offset():
	var base_pos = active_piece.pos
	while is_piece_valid(active_piece):
		active_piece.pos += Vector2i.DOWN
	active_piece.pos += Vector2i.UP
	var offset = active_piece.pos - base_pos
	active_piece.pos = base_pos
	return offset

func generate_piece():
	if len(piece_queue) <= 1:
		generate_queue()
	active_piece.piece_type = piece_queue.pop_front()
	active_piece.pos = Vector2i(5,1)
	active_piece.rotation = 0
	piece_falling_delta_sum = 0
	just_swapped_piece = false
	
	grace = 0
	total_grace = 0
	
	
	if not is_piece_valid(active_piece):
		game_over = true
		$"../../UI/Gameover".visible = true
		if score > highscore:
			highscore = score
			$"../../UI/TopLeft/VBoxContainer/Highscore".text = str(highscore).pad_zeros(10)
			SaveUtils.save_data({"TetrisHighscore": highscore})


func draw_cell(coords: Vector2i, opaque: bool, color: COLORS):
	var layer = FULL_OPACITY_LAYER if opaque else TRANSPARENT_LAYER 
	set_cell(coords, layer, BLOCK_ATLAS[color])

func is_inside_board(pos: Vector2i) -> bool:
	return not(pos.x < 0 or pos.y < 0 or pos.x >= width or pos.y >= height)

func is_valid_pos(pos: Vector2i) -> bool:
	if not is_inside_board(pos):
		return false
	if board[pos.y][pos.x] != COLORS.NONE:
		return false
	return true

func is_piece_valid(piece: TetrisPiece) -> bool:
	for offset in piece.get_position():
		if not is_valid_pos(offset + piece.pos):
			return false
	return true

func init_board():
	board = []
	for y in range(height):
		var line = []
		for x in range(width):
			line.append(COLORS.NONE)
		board.append(line)

func draw_board():
	for y in range(height):
		for x in range(width):
			draw_cell(Vector2i(x, y), true, board[y][x])

func draw_piece(piece: TetrisPiece):
	var color = piece.get_color()
	var offsets = piece.get_position()
	var shadow_offset = get_hardrop_offset()
	
	if shadow_offset.y < 0:
		return
	# Shadow first so it gets overwritten on collision
	for offset in offsets:
			draw_cell(offset + piece.pos + shadow_offset, false, color) 
	for offset in offsets:
		draw_cell(offset + piece.pos, true, color)
		

func add_piece_to_board(piece: TetrisPiece):
	var color = piece.get_color()
	var offsets = piece.get_position()
	
	for offset in offsets:
		var actual_pos = offset + piece.pos
		board[actual_pos.y][actual_pos.x] = color

func calc_points(nb_lines: int) -> int:
	var res = 0
	var perfect_clear = true
	
	for row in board:
		if row.any(func(x: COLORS): return x != COLORS.NONE):
			perfect_clear = false
			break
	
	if perfect_clear:
		$"../../UI/TextInfo/VBoxContainer/Perfect_clear".show_item()
		if nb_lines == 4 and back_to_back:
			res = 3200
		else:
			res = [800, 1200, 1800, 2000][nb_lines - 1]
	elif t_spin:
		$"../../UI/TextInfo/VBoxContainer/T_spin".show_item()
		return 800 + 400 * nb_lines
	else:
		res = [100,300,500,800][nb_lines-1]
	
	if nb_lines == 4 and back_to_back:
		$"../../UI/TextInfo/VBoxContainer/Back_to_Back".show_item()
		res *= 3/2.0
	if combo > 0:
		res += 50 * combo
	
	if nb_lines == 4:
		$"../../UI/TextInfo/VBoxContainer/Tetris".show_item()
		back_to_back = true
	
	return int(round(res * level))

func clear_rows() -> bool:
	var rows_cleared = []
	
	for i in range(len(board)):
		if COLORS.NONE not in board[i]:
			rows_cleared.append(i)
	
	rows_cleared.reverse()
	for row_index in rows_cleared:
		board.remove_at(row_index)

	var rows_cleared_count = len(rows_cleared)
	for _i in range(rows_cleared_count):
		var new_row = []
		for x in range(width):
			new_row.append(COLORS.NONE)
		board.insert(0, new_row)
	
	if rows_cleared_count != 0:
		total_lines_cleared += rows_cleared_count
		score += calc_points(rows_cleared_count)
		score_label.text = str(score).pad_zeros(10)
		combo += 1
		level = min(30, 1 + (total_lines_cleared / 10))
		$"../../UI/TopRight/Level".text = "Level %d" % level
		
		return true
	return false

# Get how many seconds before peice you automatically drop
func get_level_timer() -> float:
	if level==30:
		return 0
	if Input.is_action_pressed("down"):
		return 0.1
	if level==0:
		return 10**99
	return 0.725*0.85**level

func draw_next():
	$"../../UI/TopRight/NextMapLayer".clear()
	var next_piece = TetrisPiece.new()
	next_piece.piece_type = piece_queue[0]
	var color = next_piece.get_color()
	for offset in next_piece.get_position():
		$"../../UI/TopRight/NextMapLayer".set_cell(offset, FULL_OPACITY_LAYER, BLOCK_ATLAS[color])

func draw_held():
	$"../../UI/TopRight/HoldMapLayer".clear()
	if piece_held == null:
		return
	piece_held.rotation = 0
	var color = piece_held.get_color()
	for offset in piece_held.get_position():
		$"../../UI/TopRight/HoldMapLayer".set_cell(offset, FULL_OPACITY_LAYER, BLOCK_ATLAS[color])
	
