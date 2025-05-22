extends Node2D

class_name SolitaireCard

const suits = ["c", "d", "h", "s"]

var is_mouse_inside = false

var dragged = false
var original_pos = Vector2(0, 0)

@export var cardback: Texture
@export var card_folder: String = "res://Games/Solitaire/Ressources/Cards/cardset-4-colours/"

@onready var Sprite: Sprite2D = $Wrapper/Sprite

var card_textures: Dictionary = {}

var stack: SolitaireStack
var parent: SolitaireCard
var child: SolitaireCard

var card_value = 1
var card_suit = "h"
var face_down = true

func calc_stack_position() -> int:
	if parent == null:
		return 0
	else:
		return parent.calc_stack_position() + 1

func calc_z_index() -> int:
	if dragged:
		return 100
	if parent == null:
		return 1
	else:
		return parent.calc_z_index() + 1

func _process(delta: float) -> void:
	z_index = calc_z_index()
	if not dragged:
		if parent != null:
			position = parent.position + stack.offset
		elif stack != null:
			position = stack.global_position
	

func is_red() -> bool:
	if card_suit == "h" or card_suit == "d":
		return true
	return false

func init_card_textures():
	card_textures = {}
	for value in range(1, 14):
		for suit_name in suits:
			var file_name = str(value).pad_zeros(2) + suit_name
			card_textures[file_name] = load(card_folder.path_join(file_name + ".png"))

func _ready() -> void:
	init_card_textures()
	
func update_texture():
	if face_down:
		Sprite.texture = cardback
	else:
		Sprite.texture = card_textures[str(card_value).pad_zeros(2) + card_suit]

func flip():
	face_down = !face_down
	update_texture()

func change_card(value: int, suit: String) -> void:
	if value < 1 or value > 13 or suit not in suits:
		return
	else:
		card_value = value
		card_suit = suit
		update_texture()

func drag():
	dragged = true
	
func undrag():
	dragged = false

func join_parent(new_parent: SolitaireCard):
	if parent == null:
		if stack != null:
			stack.top_card = null
	else:
		leave_parent()
	if new_parent == null:
		return
	parent = new_parent
	stack = parent.stack
	parent.child = self

func leave_parent():
	if parent != null:
		if parent.face_down and stack.type == SolitaireStack.STACK_TYPES.BOARD:
			parent.flip()
		parent.child = null
	parent = null

func change_stack(new_stack: SolitaireStack):
	if parent == null and stack != null:
		stack.top_card = null
	leave_parent()
	stack = new_stack
	stack.top_card = self

func _on_area_2d_mouse_entered() -> void:
	is_mouse_inside = true


func _on_area_2d_mouse_exited() -> void:
	is_mouse_inside = false
