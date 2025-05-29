extends Node2D
class_name BombermanMainScene

var block_count: int = 0
var block_scene = preload("res://Games/Bomberman/Actors/Block.tscn")
var blocks: Array[BombermanBlock] = []

func _ready() -> void:
	generate_blocks(0.2)

func generate_blocks(density: float):
	for x in range(1, 30):
		for y in range(1, 12):
			var cord := Vector2i(x, y)
			
			# Inner blocks
			if cord.x % 2 == 0 and cord.y % 2 == 0:
				continue
			
			# Spawn
			if x <= 3 and y <= 3:
				continue
				
			if randf() < density:
				
				var block = block_scene.instantiate()
				block.position = Vector2i(8, 8) + cord * 16
				add_child(block)
				blocks.append(block)
				block.connect("exploded", on_block_exploded)

func on_block_exploded(block: BombermanBlock):
	blocks.erase(block)

func pause_enemies():
	pass

func _on_player_died() -> void:
	pause_enemies()


func _on_player_finished_dying() -> void:
	$Player.position = Vector2(24, 24)
	$Player.alive = true
	generate_blocks(0.2)
