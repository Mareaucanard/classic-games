extends Node2D
class_name SolitaireStack

@export var offset = Vector2(0, 0)
var is_mouse_inside = false
var top_card: SolitaireCard
@export var type: STACK_TYPES = STACK_TYPES.BOARD

enum STACK_TYPES {
	DRAW_PILE_NEXT,
	DRAW_PILE_PLAYABLE,
	RESERVE,
	BOARD,
}

func _ready() -> void:
	if type == STACK_TYPES.DRAW_PILE_PLAYABLE:
		visible = false

func get_bottom_card() -> SolitaireCard:
	if top_card == null:
		return null
	var cur = top_card
	while cur.child != null:
		cur = cur.child
	return cur
	
func is_placement_okay(card_to_add: SolitaireCard, top_card: SolitaireCard) -> bool:
	if type == STACK_TYPES.BOARD:
		if top_card == null:
			return true
		if top_card.face_down:
			return false
		if top_card.is_red() != card_to_add.is_red() and top_card.card_value == card_to_add.card_value + 1:
			return true
	if type == STACK_TYPES.RESERVE:
		if card_to_add.child != null:
			return false
		var value = 1
		if top_card != null:
			value = top_card.card_value + 1
		if card_to_add.card_value == value:
			if top_card != null and top_card.card_suit != card_to_add.card_suit:
				return false
			return true
	return false

func _on_area_2d_mouse_entered() -> void:
	is_mouse_inside = true


func _on_area_2d_mouse_exited() -> void:
	is_mouse_inside = false
