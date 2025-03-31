extends Node

var selectedItem: MenuItem

@onready var itemListContainer = $HBoxContainer/MarginContainer/ScrollContainer/MarginContainer/ItemListContainer
@onready var LaunchButton = $LaunchSceneContainer/LaunchButton
@onready var Description = $HBoxContainer/InfoMarginContainer/InfoContainer/Description
@onready var Screenshot = $HBoxContainer/InfoMarginContainer/InfoContainer/Screenshot


func _ready() -> void:
	Description.text = ""
	Screenshot.texture = null
	LaunchButton.disabled = true
	for itemMenu in itemListContainer.get_children():
		itemMenu.connect("onPressedToggled", _onItemSelected)

func _onItemSelected(item: MenuItem, toggled_on: bool):
	LaunchButton.disabled = false
	if toggled_on == false and item == selectedItem:
		selectedItem.launch_game()
	if toggled_on == true:
		if selectedItem != null:
			selectedItem.deselect()
		selectedItem = item
		Description.text = selectedItem.get_text()
		Screenshot.texture = selectedItem.get_screenshot()

func _on_launch_button_pressed() -> void:
	selectedItem.launch_game()
