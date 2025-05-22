extends Node2D
class_name SolitaireScene

var Cards: PackedScene = preload("res://Games/Solitaire/Actors/card.tscn")

func _ready():
	var suit_index = 0
	for suit in SolitaireCard.suits:
		
		for value in range(1, 14):
			var card = Cards.instantiate() as SolitaireCard
			add_child(card)
			card.position.x = card.scale.x * (100 + (value - 1) * 250)
			card.position.y = card.scale.y * (300 + suit_index * 400)
			card.change_card(value, suit)
		suit_index += 1

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and true:
			print(event)
			$CursorArea2d.position = event.position
			print($CursorArea2d.get_overlapping_areas())
	
