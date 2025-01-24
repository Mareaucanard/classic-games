extends Node2D
class_name PlayerProjectile

var min_y = 0
var speed = 500

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area2D/AnimatedSprite2D.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += Vector2(0, -speed) * delta
	
	if global_position.y < min_y:
		queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	area.get_parent().explode()
	queue_free()
