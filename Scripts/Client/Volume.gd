extends HBoxContainer

@export var slider : HSlider
var volume = 75

func _ready():
	load_game()
	updateVolume()

func updateVolume():
	GameManager.updateVolume(-100 + slider.value)

func _on_h_slider_drag_ended(value_changed):
	volume = -100 + slider.value
	updateVolume()
	save_game()
	
func save_game():
	var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_dict = {
		"volume" : slider.value
	}
	var json_string = JSON.stringify(save_dict)

	save_game.store_line(json_string)
	
func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return
		
	var save_game = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		var node_data = json.get_data()
		slider.value = node_data["volume"]
		volume = -100 + slider.value
		updateVolume()
