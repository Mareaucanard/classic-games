class_name SaveUtils


static func save_data(data: Dictionary):
	var old_data = read_data()
	old_data.merge(data, true)
	var file = FileAccess.open("user://classic_games.save", FileAccess.WRITE)
	var text = JSON.stringify(old_data)
	file.store_line(text)
	file.close()

static func read_data() -> Dictionary:
	var data: Dictionary = {}
	var file = FileAccess.open("user://classic_games.save", FileAccess.READ_WRITE)
	if file == null:
		return data
	while file.get_position() < file.get_length():
		var json_string = file.get_line()
		var row = JSON.new()
		var parse_result = row.parse(json_string)
		if not parse_result == OK:
			continue
		data.merge(row.data, true)
	file.close()
	return data
