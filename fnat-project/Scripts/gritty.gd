extends Node2D

@export var room_database_scene: PackedScene
@export var move_interval: float = 4.98
@export var max_peaks: int = 3

var room_database: Dictionary
var current_room_id = 1
var peak = 0
@onready var move_timer: Timer = $Timer

@export var ai_level: int = 5
var animatronic_name = "Gritty"
var aggression_multiplier: float = 1.0
var is_aggressive: bool = false

func _ready() -> void:
	randomize()

	room_database = GameManager.shared_room_database.rooms

	GameManager.animatronic_started.emit(animatronic_name, room_database[current_room_id]["Name"])
	GameManager.animatronic_flashed.connect(handle_flashed)

	move_timer.wait_time = move_interval
	move_timer.timeout.connect(_action)
	move_timer.start()

	if GameManager:
		GameManager.gritty_boost_started.connect(_on_aggression_boost_started)
		GameManager.gritty_boost_ended.connect(_on_aggression_boost_ended)
	
	set_AI_Level(GameManager.set_night_start_AI("Gritty"))
	print("%s initialized in room: %s" % [animatronic_name, room_database[current_room_id]["Name"]])

func set_AI_Level(new_Level : int):
	ai_level = new_Level
	print("Updated GRITTY AI LEVEL: ", ai_level)
	pass
	
	

func _on_aggression_boost_started():
	if not is_aggressive:
		is_aggressive = true
		aggression_multiplier = 2.0
		print("%s is now AGGRESSIVE! (2x movement chance)" % animatronic_name)

func _on_aggression_boost_ended():
	if is_aggressive:
		aggression_multiplier = 1.0
		is_aggressive = false
		print("%s calmed down." % animatronic_name)


func _action() -> void:
	var roll = randi() % 20 + 1  # 1-20 range
	var effective_ai = int(ai_level * aggression_multiplier)

	if roll < effective_ai:
		move_to_next_room()
		print("%s moved! (Roll: %d < Effective AI: %d)" % [animatronic_name, roll, effective_ai])


func move_to_next_room():
	var current_room = room_database[current_room_id]
	var adjacent_rooms = current_room["AdjacentRooms"].duplicate()

	# Custom weights for movement preference (RoomName: Weight)
	var room_weights = {
		"Office": 4.0,
		"LeftHall": 3.0,
		"RightHall": 3.0,
		"gym": 2.5,
		"RightLocker": 1.5,
		"LeftLocker": 1.5,
		"Storage": 0.5,
		"Cafe": 3.0,
		"Lounge": 1.0
	}

	var valid_rooms = []
	for next_room_id in adjacent_rooms:
		var next_room = room_database[next_room_id]

		if next_room["SealedDoor"]:
			continue
		if next_room["Name"] in ["Vent Section 1", "Vent Section 2", "Vent Section 3", "Closet", "LeftLocker", "LeftOfficeDoor"]:
			continue

		valid_rooms.append(next_room_id)

	if valid_rooms.is_empty():
		print("%s couldn't move from %s - no valid rooms available." % [animatronic_name, current_room["Name"]])
		return

	# Build weighted list
	var weighted_rooms: Array = []
	for next_room_id in valid_rooms:
		var next_room = room_database[next_room_id]
		var room_name = next_room["Name"]
		var weight = room_weights.get(room_name, 1.0)

		# Add weight entries
		for i in range(int(weight * 10)):  # Weight * 10 smooths probabilities
			weighted_rooms.append(next_room_id)

	# Randomly select room from weighted array
	var next_room_id = weighted_rooms[randi() % weighted_rooms.size()]
	var next_room = room_database[next_room_id]

	GameManager.animatronic_moved.emit(animatronic_name, current_room["Name"], next_room["Name"])
	current_room["Empty"] = true
	next_room["Empty"] = false
	current_room_id = next_room_id

	print("%s moved towards %s (Weighted choice)" % [animatronic_name, next_room["Name"]])

	if next_room["Name"] == "Office":
		trigger_attack()

func handle_flashed(mascot_name) -> void:
	if mascot_name == animatronic_name:
		var current_room = room_database[current_room_id]
		var flashed_room_id = 7  # Example fallback room (e.g., Dining)
		var next_room = room_database[flashed_room_id]

		GameManager.animatronic_moved.emit(animatronic_name, current_room["Name"], next_room["Name"])
		current_room["Empty"] = true
		next_room["Empty"] = false
		current_room_id = flashed_room_id
		print("%s was flashed and returned to '%s'" % [animatronic_name, next_room["Name"]])

# === ATTACK TRIGGER ===

func trigger_attack() -> void:
	print("%s attacks the player! GAME OVER" % animatronic_name)
	move_timer.stop()
	get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")
