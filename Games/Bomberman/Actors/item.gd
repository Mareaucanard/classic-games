extends Area2D
class_name BombermanItem

enum POWER_TYPE {SPEED, EXPLOSION_RADIUS, BOMBS}
var type = POWER_TYPE.SPEED

func _ready() -> void:
	if type == POWER_TYPE.SPEED:
		$AnimatedSprite2D.play("Speed")
	elif type == POWER_TYPE.EXPLOSION_RADIUS:
		$AnimatedSprite2D.play("ExplosionRadius")
	elif type == POWER_TYPE.BOMBS:
		$AnimatedSprite2D.play("Bombs")


func _on_area_entered(area: Area2D) -> void:
	if area is BombermanExplosion:
		queue_free()
