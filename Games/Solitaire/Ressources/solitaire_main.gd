extends Node2D
class_name SolitaireScene

var Cards: PackedScene = preload("res://Games/Solitaire/Actors/card.tscn")

var dragged_card: SolitaireCard
var default_stack: SolitaireStack

var drag_offset = Vector2(0, 0)

var draw_pile_bottom: SolitaireCard
var draw_pile_play_bottom: SolitaireCard
var hidden_card_queue: Array[SolitaireCard] = []

func _process(_delta: float) -> void:
	if dragged_card != null:
		dragged_card.position = get_global_mouse_position() - drag_offset
	
	if check_for_victory():
		$Label.visible = true
		
func _ready():
	$Label.visible = false
	var cards: Array[SolitaireCard]
	default_stack = SolitaireStack.new()
	default_stack.position= Vector2(100, 100)
	for suit in SolitaireCard.suits:
		for value in range(1, 14):
			var card = Cards.instantiate() as SolitaireCard
			card.position = Vector2(-1000, -1000)
			add_child(card)
			card.change_card(value, suit)
			cards.append(card)
	cards.shuffle()
	
	var stack_counter = 1
	var prev_card = null
	var stack_card_counter = 0
	for card in cards:
		if stack_counter < 8:
				if prev_card == null:
					var stack = $Boards.get_children()[stack_counter - 1] as SolitaireStack
					card.change_stack(stack)
				else:
					card.join_parent(prev_card)
				if stack_card_counter + 1 == stack_counter:
					card.flip()
					stack_card_counter = 0
					stack_counter += 1
					prev_card = null
				else:
					prev_card = card
					stack_card_counter += 1
		else:
			if prev_card == null:
				card.change_stack($DrawPileNext)
			else:
				card.join_parent(prev_card)
			prev_card = card
	draw_pile_bottom = prev_card

func get_top_selected_card(ignore_childful: bool = false) -> Variant:
	var res = null
	var stack_pos = -1
	for card in get_tree().get_nodes_in_group("SolitaireCard") as Array[SolitaireCard]:
		var cur_stack_pos = card.calc_stack_position()
		if not card.dragged and card.is_mouse_inside and cur_stack_pos > stack_pos:
			if card.child != null and ignore_childful:
				continue
			res = card
			stack_pos = cur_stack_pos
	return res

func get_selected_stack() -> Variant:
	for stack in get_tree().get_nodes_in_group("SolitaireStack") as Array[SolitaireStack]:
		if stack.is_mouse_inside and stack.top_card == null:
			return stack
	return null

func draw_3_cards():
	if draw_pile_bottom == null:
		var c1 = draw_pile_play_bottom
		var c2 = null
		var c3 = null
		if c1 != null:
			c2 = c1.parent
			if c2 != null:
				c3 = c2.parent
		if c3 != null:
			hidden_card_queue.push_front(c3)
		if c2 != null:
			hidden_card_queue.push_front(c2)
		if c1 != null:
			hidden_card_queue.push_front(c1)
		
		var prev_card = null
		for card in hidden_card_queue:
			card.parent = null
			card.child = null
			card.stack = null
			card.flip()
			if prev_card == null:
				card.change_stack($DrawPileNext)
			else:
				card.join_parent(prev_card)
			prev_card = card
		draw_pile_bottom = prev_card
		draw_pile_play_bottom = null
		hidden_card_queue = []
		return
	var i = 0
	while i < 3 and draw_pile_bottom != null:
		draw_pile_bottom.flip()
		var tmp = draw_pile_bottom.parent
		if draw_pile_play_bottom == null:
			draw_pile_bottom.change_stack($DrawPilePlayable)
		else:
			draw_pile_bottom.join_parent(draw_pile_play_bottom)
		if draw_pile_bottom.calc_stack_position() == 3:
			var new_root = draw_pile_bottom.parent.parent
			var old_root = new_root.parent
			old_root.change_stack($HiddenStack)
			new_root.change_stack($DrawPilePlayable)
			hidden_card_queue.push_front(old_root)
		draw_pile_play_bottom = draw_pile_bottom
		draw_pile_bottom = tmp
		i = i +1


func check_for_victory() ->  bool:
	for stack in $Reserves.get_children() as Array[SolitaireStack]:
		var bottom_card = stack.get_bottom_card()
		if bottom_card is not SolitaireCard or bottom_card.card_value != 13:
			return false
	return true

func handle_draw_pile_bottom():
	var new_root = hidden_card_queue.pop_front() as SolitaireCard
	if new_root == null:
		draw_pile_play_bottom = draw_pile_play_bottom.parent
		return
		
	new_root.change_stack($DrawPilePlayable)
	var new_bottom_card = draw_pile_play_bottom.parent
	
	if new_bottom_card == null:
		draw_pile_play_bottom = new_root
		return
	
	draw_pile_play_bottom = new_bottom_card
	if new_bottom_card.parent == null:
		new_bottom_card.join_parent(new_root)
		return
	else:
		new_bottom_card.parent.join_parent(new_root)
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if $DrawPileNext.is_mouse_inside and  event.button_index == 1 and event.pressed:
			draw_3_cards()
		
		elif event.button_index == 1 and event.pressed and event.double_click:
			var card = get_top_selected_card()
			if card is SolitaireCard:
				for stack in $Reserves.get_children() as Array[SolitaireStack]:
					var bottom_card = stack.get_bottom_card()
					if stack.is_placement_okay(card, bottom_card):
						if card == draw_pile_play_bottom:
							handle_draw_pile_bottom()
						if bottom_card == null:
							card.change_stack(stack)
						else:
							card.join_parent(bottom_card)
						return
						
		
		elif event.button_index == 1 and event.pressed:
			var card = get_top_selected_card()
			if card is SolitaireCard:
				if card.child != null and card.stack.type == SolitaireStack.STACK_TYPES.DRAW_PILE_PLAYABLE:
					return
				drag_offset = get_global_mouse_position() - card.position
				card.drag()
				dragged_card = card

		elif event.button_index == 1 and event.pressed == false:
			if dragged_card != null:
				var stack = get_selected_stack()
				var card = get_top_selected_card(true)
				if card is SolitaireCard:
					if card.stack.is_placement_okay(dragged_card, card):
						if dragged_card == draw_pile_play_bottom:
							handle_draw_pile_bottom()
						dragged_card.join_parent(card)
				elif stack is SolitaireStack:
					if stack.is_placement_okay(dragged_card, null):
						if dragged_card == draw_pile_play_bottom:
							handle_draw_pile_bottom()
						dragged_card.change_stack(stack)
				dragged_card.undrag()
				dragged_card = null
	if Input.is_action_just_pressed("go_to_main_menu"):
		get_tree().change_scene_to_file("res://Menu/Menu.tscn")
	
	if Input.is_action_just_pressed("minesweeper_reset"):
		get_tree().reload_current_scene()
