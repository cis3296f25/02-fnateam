extends Node2D

@export var room_database_scene: PackedScene
@export var move_interval: float = 4.98
@export var max_peaks: int = 3

var room_database: Dictionary
var current_room_id = 10
var peak = 0
@onready var move_timer: Timer = $Timer
@export var ai_level: int = 5
var animatronic_name = "Phang"
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
		GameManager.phang_boost_started.connect(_on_aggression_boost_started)
		GameManager.phang_boost_ended.connect(_on_aggression_boost_ended)

	print("%s initialized in room: %s" % [animatronic_name, room_database[current_room_id]["Name"]])


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
	var roll = randi() % 20 + 1
	var effective_ai = int(ai_level * aggression_multiplier)

	if roll < effective_ai:
		move_to_next_room()
		print("%s moved! (Roll: %d < Effective AI: %d)" % [animatronic_name, roll, effective_ai])


func move_to_next_room():
	var current_room = room_database[current_room_id]
	var adjacent_rooms = current_room["AdjacentRooms"]

	# Weights for movement preference
	var room_weights = {
		"Utility": 2.0,
		"Vent Section 1": 5.0,
		"Vent Section 2": 3.0,
		"Vent Section 3": 2.5,
		"Office": 5.0
	}

	var valid_rooms: Array = []
	for next_room_id in adjacent_rooms:
		var next_room = room_database[next_room_id]

		if next_room["SealedDoor"]:
			continue
		if next_room["Name"] == "Lounge":
			continue
		if not next_room["Empty"]:
			continue

		valid_rooms.append(next_room_id)

	if valid_rooms.is_empty():
		print("%s could not move - no valid rooms available." % animatronic_name)
		return

	var weighted_rooms: Array = []
	for next_room_id in valid_rooms:
		var next_room = room_database[next_room_id]
		var weight = room_weights.get(next_room["Name"], 1.0)

		for i in range(int(weight * 10)):
			weighted_rooms.append(next_room_id)

	var next_room_id = weighted_rooms[randi() % weighted_rooms.size()]
	var next_room = room_database[next_room_id]

	GameManager.animatronic_moved.emit(animatronic_name, current_room["Name"], next_room["Name"])

	current_room["Empty"] = true
	next_room["Empty"] = false
	current_room_id = next_room_id

	print("%s moved toward %s (weighted choice)" % [animatronic_name, next_room["Name"]])

	if next_room["Name"] == "Office":
		trigger_attack()


func handle_flashed(mascot_name) -> void:
	if mascot_name == animatronic_name:
		var current_room = room_database[current_room_id]
		var flashed_room_id = 11  # Wherever you want Phang to reset to
		var next_room = room_database[flashed_room_id]

		GameManager.animatronic_moved.emit(animatronic_name, current_room["Name"], next_room["Name"])

		current_room["Empty"] = true
		next_room["Empty"] = false
		current_room_id = flashed_room_id

		print("%s was flashed back to '%s'" % [animatronic_name, next_room["Name"]])

func trigger_attack() -> void:
	print("%s attacks the player! GAME OVER" % animatronic_name)
	move_timer.stop()
	get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")
