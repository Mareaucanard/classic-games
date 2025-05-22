extends Node2D

class_name SolitaireCard

const suits = ["c", "d", "h", "s"]

@export var cardback: Texture
@export var card_folder: String = "res://Games/Solitaire/Ressources/Cards/cardset-4-colours/"

@onready var Sprite: Sprite2D = $Sprite

var card_textures: Dictionary = {}

var card_value = 1
var card_suit = "v"

func init_card_textures():
	card_textures = {}
	for value in range(1, 14):
		for suit_name in suits:
			var name = str(value).pad_zeros(2) + suit_name
			card_textures[name] = load(card_folder.path_join(name + ".png"))

func _ready() -> void:
	init_card_textures()
	
func change_card(value: int, suit: String) -> void:
	init_card_textures()
	if value < 1 or value > 13 or suit not in suits:
		Sprite.texture = cardback
		return
	else:
		card_value = value
		card_suit = suit
		Sprite.texture = card_textures[str(value).pad_zeros(2) + suit]
