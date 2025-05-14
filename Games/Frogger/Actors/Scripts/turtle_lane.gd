extends Node2D

class_name FroggerTurtlelane

const HALF_TURTLE_SIZE = 32

@export var turtle_section_scene = preload("res://Games/Frogger/Actors/Scenes/turtle_section.tscn")

@export var distance_between_sections = 60
@export var speed = 150
@export var turtle_sections_lenghts = [4, 3, 2]
@export var movement_x_limit = 720
@export var movement_direction = 1

var turtle_sections = []


func _ready():
	var index = 0
	
	for section_length in turtle_sections_lenghts:
		var turtle_section = turtle_section_scene.instantiate() as FroggerTurtleSection
		turtle_section.turtle_count = section_length
		turtle_section.movement_direction = movement_direction
		add_child(turtle_section)
		
		var previous_turtle_section_position = - movement_x_limit if index == 0 else turtle_sections[index - 1].position.x
		var previous_section_length = 0 if index == 0 else turtle_sections[index - 1].get_section_length() / 2
		turtle_section.position.x = previous_turtle_section_position + (distance_between_sections + previous_section_length + section_length * HALF_TURTLE_SIZE) * -movement_direction
		turtle_sections.append(turtle_section)
		index += 1
		
func _process(delta):
	for turtle_section in turtle_sections:
		var new_position_x = speed * delta * movement_direction + turtle_section.position.x
		
		if abs(new_position_x - movement_x_limit) < 10:
			turtle_section.position.x = - movement_x_limit
		else:
			turtle_section.position.x = new_position_x
