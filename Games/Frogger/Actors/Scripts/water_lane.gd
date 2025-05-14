extends Node2D

class_name FroggerWaterLane

const HALF_LOG_LENGTH = 32

@export var logs_length = [4, 4, 4]
@export var distance_between_logs = 180
@export var speed = 200
@export var movement_x_limit = 720.0
@export var movement_direction = 1

@export var log_scene: PackedScene = preload("res://Games/Frogger/Actors/Scenes/log.tscn")

var logs: Array[FroggerLog] = []

func _ready():
	var index = 0
	
	for log_length in logs_length:
		var wood_log = log_scene.instantiate() as FroggerLog
		wood_log.middle_section_length = log_length - 2
		add_child(wood_log)
		
		var previous_log_position = - movement_x_limit if index == 0 else logs[index - 1].position.x
		wood_log.position.x = (log_length * HALF_LOG_LENGTH + distance_between_logs) * -movement_direction + previous_log_position
		index += 1
		logs.append(wood_log)
		
func _process(delta):
	for wood_log in logs:
		var new_position_x = speed * delta * movement_direction + wood_log.position.x
		if abs(new_position_x - movement_x_limit) < 10:
			wood_log.position.x = - movement_x_limit
		else:
			wood_log.position.x = new_position_x
