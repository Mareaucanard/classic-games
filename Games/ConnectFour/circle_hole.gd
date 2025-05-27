extends Area2D
class_name ConnectFourHole

const RADIUS = 35

enum HOLE_STATE {
	EMPTY,
	RED,
	YELLOW
}

var color_dict = {
	HOLE_STATE.EMPTY: Color(0, 0, 0),
	HOLE_STATE.YELLOW: Color(255, 255, 0),
	HOLE_STATE.RED: Color(255, 0, 0),
	
}

var state = HOLE_STATE.EMPTY

func _ready():
	change_color(HOLE_STATE.EMPTY)
	var sprite_scale = (RADIUS / 25.0) * 0.1
	$Circle.scale = Vector2(sprite_scale, sprite_scale)
	var s = $CollisionShape2D.shape as CircleShape2D
	s.radius = RADIUS

func change_color(new_color: HOLE_STATE):
	state = new_color
	$Circle.modulate = color_dict[state]
