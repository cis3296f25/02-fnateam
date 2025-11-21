extends Node

const SAVE_PATH := "user://savegame.json"

var current_night: int = 1
var has_save: bool = false

func _ready() -> void:
	load_game()


func save_game() -> void:
	var data := {
		"current_night": current_night,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
		has_save = true
		print("SaveManager: saved", data)


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		has_save = false
		current_night = 1
		print("SaveManager: no save file")
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var text := file.get_as_text()
	file.close()

	var result = JSON.parse_string(text)
	if typeof(result) == TYPE_DICTIONARY:
		current_night = int(result.get("current_night", 1))
		has_save = true
		print("SaveManager: loaded", result)
	else:
		print("SaveManager: bad save file, resetting")
		current_night = 1
		has_save = false
