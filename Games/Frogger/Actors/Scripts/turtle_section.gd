extends Node2D

class_name FroggerTurtleSection
const TURTLE_SIZE = 64

@export var turtle_scene = preload("res://Games/Frogger/Actors/Scenes/turtle.tscn")

var turtle_count = 3
var movement_direction = 1

func _ready():
	for i in turtle_count:
		var turtle = turtle_scene.instantiate() as FroggerTurtle
		add_child(turtle)
		turtle.scale = Vector2(4, 4)
		
		if movement_direction == 1:
			turtle.set_sprite_rotation_degrees(180)
		
		@warning_ignore("integer_division")
		turtle.position.x = TURTLE_SIZE / 2 - TURTLE_SIZE * i

func get_section_length():
	return turtle_count * TURTLE_SIZE
