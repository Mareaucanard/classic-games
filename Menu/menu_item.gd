extends TextureRect
class_name MenuItem

@export var scene: PackedScene
@export var screenshot: Texture
var manual_deselect = false
signal onPressedToggled(MenuItem, toggled_on: bool)

func _ready():
	$Description.visible = false
func _on_button_toggled(toggled_on: bool) -> void:
	onPressedToggled.emit(self, toggled_on)

func deselect():
	manual_deselect = true
	$Button.button_pressed = false

func select():
	pass

func launch_game():
	if not manual_deselect:
		get_tree().change_scene_to_packed(scene)
	else:
		manual_deselect = false
	
func get_text():
	return $Description.text
	
func get_display_name():
	return $Button.text

func get_screenshot():
	return screenshot
