class_name TetrisPiece

enum PIECES {I, J, L, O, S, T, Z}
var rotation = 0
var piece_type = PIECES.I
var pos = Vector2i(5,3) # 5,3 is the spawn point

func rotate_clockwise():
	rotation += 1
	if rotation > 3:
		rotation = 0

func rotat_counter_clockwise():
	rotation -= 1
	if rotation < 0:
		rotation = 3

func get_color() -> TetrisBoard.COLORS:
	if piece_type == PIECES.I:
		return TetrisBoard.COLORS.CYAN
	if piece_type == PIECES.J:
		return TetrisBoard.COLORS.BLUE
	if piece_type == PIECES.L:
		return TetrisBoard.COLORS.ORANGE
	if piece_type == PIECES.O:
		return TetrisBoard.COLORS.YELLOW
	if piece_type == PIECES.S:
		return TetrisBoard.COLORS.RED
	if piece_type == PIECES.T:
		return TetrisBoard.COLORS.PURPLE
	if piece_type == PIECES.Z:
		return TetrisBoard.COLORS.GREEN
	return TetrisBoard.COLORS.NONE


func get_position() -> Array[Vector2i]:
	if piece_type==PIECES.I:
		if rotation==0:
			return [Vector2i(-1,0),Vector2i(0,0),Vector2i(1,0),Vector2i(2,0)]
		if rotation==1:
			return [Vector2i(0,1),Vector2i(0,0),Vector2i(0,-1),Vector2i(0,-2)]
		if rotation==2:
			return [Vector2i(-2,0),Vector2i(-1,0),Vector2i(0,0),Vector2i(1,0)]
		if rotation==3:
			return [Vector2i(0,2),Vector2i(0,1),Vector2i(0,0),Vector2i(0,-1)]
	if piece_type==PIECES.J: #J piece
		if rotation==0:
			return [Vector2i(-1,1),Vector2i(-1,0),Vector2i(0,0),Vector2i(1,0)]
		if rotation==1:
			return [Vector2i(1,1),Vector2i(0,1),Vector2i(0,0),Vector2i(0,-1)]
		if rotation==2:
			return [Vector2i(1,-1),Vector2i(1,0),Vector2i(0,0),Vector2i(-1,0)]
		if rotation==3:
			return [Vector2i(-1,-1),Vector2i(0,-1),Vector2i(0,0),Vector2i(0,1)]
	if piece_type==PIECES.L:#L piece
		if rotation==0:
			return [Vector2i(-1,0),Vector2i(0,0),Vector2i(1,0),Vector2i(1,1)]   
		if rotation==1:
			return [Vector2i(0,1),Vector2i(0,0),Vector2i(0,-1),Vector2i(1,-1)]
		if rotation==2:
			return [Vector2i(1,0),Vector2i(0,0),Vector2i(-1,0),Vector2i(-1,-1)]
		if rotation==3:
			return [Vector2i(0,-1),Vector2i(0,0),Vector2i(0,1),Vector2i(-1,1)]
	if piece_type==PIECES.O:
			return [Vector2i(0,0),Vector2i(0,1),Vector2i(-1,0),Vector2i(-1,1)]
	if piece_type==PIECES.S:#S piece
		if rotation==0:
			return [Vector2i(-1,0),Vector2i(0,0),Vector2i(0,1),Vector2i(1,1)]    
		if rotation==1:
			return [Vector2i(0,1),Vector2i(0,0),Vector2i(1,0),Vector2i(1,-1)]
		if rotation==2:
			return [Vector2i(1,0),Vector2i(0,0),Vector2i(0,-1),Vector2i(-1,-1)]
		if rotation==3:
			return [Vector2i(0,-1),Vector2i(0,0),Vector2i(-1,0),Vector2i(-1,1)]
	if piece_type==PIECES.T:#T piece
		if rotation==0:
			return [Vector2i(-1,0),Vector2i(0,0),Vector2i(0,1),Vector2i(1,0)]
		if rotation==1:
			return [Vector2i(0,1),Vector2i(0,0),Vector2i(1,0),Vector2i(0,-1)]
		if rotation==2:
			return [Vector2i(1,0),Vector2i(0,0),Vector2i(0,-1),Vector2i(-1,0)]
		if rotation==3:
			return [Vector2i(0,-1),Vector2i(0,0),Vector2i(-1,0),Vector2i(0,1)]
	if piece_type==PIECES.Z:#Z piece
		if rotation==0:
			return [Vector2i(-1,1),Vector2i(0,1),Vector2i(0,0),Vector2i(1,0)]
		if rotation==1:
			return [Vector2i(1,1),Vector2i(1,0),Vector2i(0,0),Vector2i(0,-1)]
		if rotation==2:
			return [Vector2i(1,-1),Vector2i(0,-1),Vector2i(0,0),Vector2i(-1,0)]
		if rotation==3:
			return [Vector2i(-1,-1),Vector2i(-1,0),Vector2i(0,0),Vector2i(0,1)]
	return []
