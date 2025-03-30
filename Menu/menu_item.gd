extends TextureRect
class_name MenuItem

@export var scene: PackedScene
signal onPressedToggled(MenuItem, toggled_on: bool)

func _on_button_toggled(toggled_on: bool) -> void:
	onPressedToggled.emit(self, toggled_on)

func deselect():
	$Button.button_pressed = false

func launch_game():
	get_tree().change_scene_to_packed(scene)
