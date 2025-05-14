extends Area2D

class_name FroggerPlayer

signal life_lost
signal game_lost

const PLAYER_START_POSITION = Vector2(0, 418)
const POSITION_INCREMENT = 64


@export var death_texture: Texture
@export var idle_texture: Texture
@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var collision_shape_2d = $CollisionShape2D
@onready var death_timer = $DeathTimer


@export var lifes = 1
@export var camera: Camera2D
@export var speed = 40

var dead = false

var new_position: Vector2 = Vector2.ZERO
var camera_bounds = {
	"left": 0,
	"right": 0,
	"bottom": 0
}


func _ready():
	death_timer.timeout.connect(on_death_timer_timeout)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dead:
		return
	
	var overlapping_areas = get_overlapping_areas()
	if overlapping_areas.size() != 0 and !overlapping_areas.any(func(area): return !(area is FroggerWater)):
		die()
		return

	if new_position == Vector2.ZERO:
		return
	position = lerp(position, new_position, speed * delta)
	
	if absf((position - new_position).length()) < 0.001:
		position = round(position)
		new_position = Vector2.ZERO
	else:
		animation_player.play("leap")
		

func _input(_event):
	if Input.is_action_just_pressed("go_to_main_menu"):
		get_tree().change_scene_to_file("res://Menu/Menu.tscn")
	
	if Input.is_action_just_pressed("minesweeper_reset"):
		get_tree().reload_current_scene()

	if dead == true:
		return

	var position_candidate
	if Input.is_action_just_pressed("down"):
		position_candidate = Vector2.DOWN * POSITION_INCREMENT + position
		sprite_2d.rotation_degrees = 180
	elif Input.is_action_just_pressed("up"):
		position_candidate = Vector2.UP * POSITION_INCREMENT + position
		sprite_2d.rotation_degrees = 0
	elif Input.is_action_just_pressed("left"):
		position_candidate = Vector2.LEFT * POSITION_INCREMENT + position
		sprite_2d.rotation_degrees = 270
	elif Input.is_action_just_pressed("right"):
		sprite_2d.rotation_degrees = 90
		position_candidate = Vector2.RIGHT * POSITION_INCREMENT + position
	
	if !position_candidate:
		return
	
	if position_candidate.y > 418 or position_candidate.y < -425 or abs(position_candidate.x) > 425:
		return
	
	new_position = position_candidate

func die():
	collision_shape_2d.set_deferred("disabled", true)
	animation_player.stop()
	sprite_2d.texture = death_texture
	dead = true
	death_timer.start()

func on_death_timer_timeout():
	lifes -= 1
	life_lost.emit()
	
	if lifes == 0:
		game_lost.emit()
	else:
		reset_player()

func reset_player():
	set_process_input(true)
	collision_shape_2d.set_deferred("disabled", false)
	sprite_2d.texture = idle_texture
	global_position = PLAYER_START_POSITION
	new_position = PLAYER_START_POSITION
