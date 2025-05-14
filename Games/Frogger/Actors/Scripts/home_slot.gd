extends Area2D

class_name FroggerHomeSlot

signal frog_entered_home

@onready var home_frog_sprite = $HomeFrogSprite


func _on_area_entered(area):
	if area is FroggerPlayer:
		frog_entered_home.emit()
		home_frog_sprite.show()
