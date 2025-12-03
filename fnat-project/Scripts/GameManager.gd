extends Node

# # Other pre-existing variables, such as current_night 

# AI Level for 4 Characters (0–20)
var ai_levels: Array[int] = [0, 0, 0, 0]  # index 0~3 Corresponding to four roles

func set_ai_level(index: int, level: int) -> void:
	if index < 0 or index >= ai_levels.size():
		return
	ai_levels[index] = clamp(level, 0, 20)

func get_ai_level(index: int) -> int:
	if index < 0 or index >= ai_levels.size():
		return 0
	return ai_levels[index]

# Treat AI Level as a reference for night difficulty
func night_from_level(level: int) -> int:
	if level <= 4:
		return 1
	elif level <= 8:
		return 2
	elif level <= 12:
		return 3
	elif level <= 16:
		return 4
	else:
		return 5
