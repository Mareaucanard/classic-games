extends Node

var selectedItem: MenuItem
@onready var itemListContainer = $ScrollContainer/MarginContainer/VBoxContainer

func _ready() -> void:
	$LaunchButton.disabled = true
	for itemMenu in itemListContainer.get_children():
		itemMenu.connect("onPressedToggled", _onItemSelected)

func _onItemSelected(item: MenuItem, toggled_on: bool):
	$LaunchButton.disabled = false
	if toggled_on == true:
		if selectedItem != null:
			selectedItem.deselect()
		selectedItem = item
	if toggled_on == false:
		selectedItem.launch_game()

func _on_launch_button_pressed() -> void:
	selectedItem.launch_game()
