extends Area2D
class_name BombermanExplosion

var explosion_size = 1
var needs_update = false
var atlas_origin = Vector2i(2, 6)

func change_explosion_size(new_size: int):
	explosion_size = new_size
	needs_update = true
	
func _physics_process(_delta: float) -> void:
	if needs_update:
		needs_update = false
		$CollisionPolygon2D.polygon = 	PackedVector2Array([
			Vector2(7, -7),
			Vector2(7 + 16 * explosion_size, -7),
			Vector2(7 + 16 * explosion_size, 7),
			Vector2(7, 7),
			Vector2(7, 7 + 16 * explosion_size),
			Vector2(-7, 7 + 16 * explosion_size),
			Vector2(-7, 7),
			Vector2(-(7 + 16 * explosion_size), 7),
			Vector2(-(7 + 16 * explosion_size), -7),
			Vector2(-7, -7),
			Vector2(-7, -(7 + 16 * explosion_size)),
			Vector2(7, -(7 + 16 * explosion_size))
		])
		
		$Effects.clear()
		$Effects.set_cell(Vector2i(0, 0), 1, atlas_origin)
		var vecs = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
		for vec in vecs:
			for i in range(explosion_size):
				if i == explosion_size - 1:
					$Effects.set_cell(vec * (i + 1), 1, atlas_origin + vec * 2)
				else:
					$Effects.set_cell(vec * (i + 1), 1, atlas_origin + vec)
					


func _on_timer_timeout() -> void:
	queue_free()
