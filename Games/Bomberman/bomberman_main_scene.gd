extends Node2D
class_name BombermanMainScene

var block_count: int = 0
var block_scene := preload("res://Games/Bomberman/Actors/Block.tscn")
var enemy_scene := preload("res://Games/Bomberman/Actors/Enemies/DefaultEnemy.tscn")

var blocks: Array[BombermanBlock] = []
var enemies: Array[BombermanEnemy] = []


var left = 0
var level = 1
var timer_count = 200

func _ready() -> void:
	generate_blocks()

func spawn_enemies(num: int):
	while len(enemies) < num:
		var x = randi_range(1, 29)
		var y = randi_range(1, 12)
		var potential_position: Vector2 = Vector2i(8, 8) + Vector2i(x, y) * 16
		
		if x % 2 == 0 and y % 2 == 0:
			continue
		if x <= 3 and y <= 3:
			continue
		if blocks.any(func (block: BombermanBlock): return block.position.distance_to(potential_position) < 1):
			continue
		
		var enemy = enemy_scene.instantiate() as BombermanEnemy
		enemy.position = potential_position
		enemy.connect("died", _on_enemy_death)
		enemies.append(enemy)
		enemy.coordinates = Vector2i(x, y)
		add_child(enemy)
		
func _on_enemy_death(enemy: BombermanEnemy):
	enemies.erase(enemy)
	left = max(0, left - 1)
	$CanvasLayer/UI/Left.text = "Left: %d" % left

func generate_blocks(density: float = 0.2):
	timer_count = 200
	$CanvasLayer/UI/Timer.text = "Timer: %d" % timer_count
	$CanvasLayer/UI/Timer/TimerUITimeout.start()
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
	if len(blocks) == 0:
		var block = block_scene.instantiate()
		block.position = Vector2i(8, 8) + Vector2i(20, 1) * 16
		add_child(block)
		blocks.append(block)
		block.connect("exploded", on_block_exploded)
		
	$Door.position = blocks.pick_random().position
	spawn_enemies(ceil(3/2.0 * (level + 1)))
	left = len(enemies) - 1
	$CanvasLayer/UI/Left.text = "Left: %d" % left
	

func on_block_exploded(block: BombermanBlock):
	blocks.erase(block)

func clear_enemies_and_blocks():
	for enemy in enemies:
		enemy.queue_free()
	for block in blocks:
		block.queue_free()
	
	enemies = []
	blocks = []

func _on_player_died() -> void:
	$CanvasLayer/UI/Timer/TimerUITimeout.stop()


func _on_player_finished_dying() -> void:
	clear_enemies_and_blocks()
	$Player.reset_position()
	$Player.alive = true
	generate_blocks()
	


func _on_player_won() -> void:
	if left == 0:
		clear_enemies_and_blocks()
		level = level + 1
		$Player.reset_position()
		generate_blocks()


func _on_timer_ui_timeout_timeout() -> void:
	timer_count -= 1
	$CanvasLayer/UI/Timer.text = "Timer: %d" % timer_count
	if timer_count <= 0:
		$Player.die()
