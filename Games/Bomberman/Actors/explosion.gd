extends Area2D
class_name BombermanExplosion

var explosion_size = 1
var needs_update = false
var atlas_origin = Vector2i(2, 6)
var coordinates = Vector2i(0, 0)

func change_explosion_size(new_size: int):
	explosion_size = new_size
	needs_update = true

func make_collision(pos: Vector2, big_rect: bool = false):
	var collision = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(15.75, 15.75)
	if big_rect:
		rect.size += Vector2(0.5,0.5)
	collision.position = pos
	collision.shape = rect
	add_child(collision)	

func _physics_process(_delta: float) -> void:
	if needs_update:
		needs_update = false
		
		$Effects.clear()
		$Effects.set_cell(Vector2i(0, 0), 1, atlas_origin)
		var vecs = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
		var blocks = get_tree().get_nodes_in_group("bombermainscene")[0].blocks as Array[BombermanBlock]
		for vec in vecs:
			for i in range(explosion_size + 1):
				if i == explosion_size:
					make_collision(Vector2(vec) * i * 16)
					$Effects.set_cell(vec * i, 1, atlas_origin + vec * 2)
					break
				var is_next_okay = true
				var t_cord = vec * (i + 1) + coordinates
				var next_block_position = Vector2(vec) * (i + 1) * 16 + position
				if blocks.any(func (block: BombermanBlock): return block.position.distance_to(next_block_position) < 1):
					is_next_okay = false
				if t_cord.y == 0 or t_cord.y == 12 or t_cord.x == 0 or t_cord.x == 30:
					is_next_okay = false
				if t_cord.x % 2 == 0 and t_cord.y % 2 == 0:
					is_next_okay = false
				
				if i == 0:
					if is_next_okay:
						continue
					else:
						break
				
				if not is_next_okay:
					make_collision(Vector2(vec) * i * 16, true)
					$Effects.set_cell(vec * i, 1, atlas_origin + vec * 2)
					break
				else:
					make_collision(Vector2(vec) * i * 16)
					$Effects.set_cell(vec * i, 1, atlas_origin + vec)
					


func _on_timer_timeout() -> void:
	queue_free()
