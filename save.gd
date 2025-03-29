extends Node
class_name SaveUtils

static var save_file = "user://classic_games.save"

static func save_data(data: Dictionary):
	var old_data = read_data()
	old_data.merge(data, true)
	var file = FileAccess.open(save_file, FileAccess.WRITE)
	var text = JSON.stringify(old_data)
	file.store_line(text)

static func read_data() -> Dictionary:
	var data: Dictionary = {}
	var file = FileAccess.open(save_file, FileAccess.READ_WRITE)
	while file.get_position() < file.get_length():
		var json_string = file.get_line()
		var row = JSON.new()
		var parse_result = row.parse(json_string)
		if not parse_result == OK:
			continue
		data.merge(row.data, true)
	return data
