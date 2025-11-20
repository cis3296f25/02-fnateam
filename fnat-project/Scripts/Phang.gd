extends Node2D

@export var room_database_scene: PackedScene
@export var move_interval: float = 4.98
@export var max_peaks: int = 3

var room_database: Dictionary
var current_room_id = 10
var peak = 0
@onready var move_timer: Timer = $Timer

var animatronic_name = "Phang"

var ai_level: int = 0
var aggression_multiplier: float = 1.0
var is_aggressive: bool = false
var last_hour_applied := 0


func _ready() -> void:
	randomize()

	room_database = GameManager.shared_room_database.rooms

	GameManager.animatronic_started.emit(animatronic_name, room_database[current_room_id]["Name"])
	GameManager.animatronic_flashed.connect(handle_flashed)

	ai_level = GameManager.set_night_start_AI("Phang")

	move_timer.wait_time = move_interval
	move_timer.timeout.connect(_action)
	move_timer.start()

	if GameManager:
		GameManager.phang_boost_started.connect(_on_aggression_boost_started)
		GameManager.phang_boost_ended.connect(_on_aggression_boost_ended)

	print("%s initialized in room: %s (AI %d)" %
		[animatronic_name, room_database[current_room_id]["Name"], ai_level])


func _on_aggression_boost_started():
	if not is_aggressive:
		is_aggressive = true
		aggression_multiplier = 2.0


func _on_aggression_boost_ended():
	if is_aggressive:
		is_aggressive = false
		aggression_multiplier = 1.0


func _action() -> void:
	_update_ai_for_hour()

	var roll = randi() % 20 + 1
	var effective_ai = int(ai_level * aggression_multiplier)

	if roll < effective_ai:
		move_to_next_room()
		print("%s moved! (Roll: %d < Effective AI: %d)" %
			[animatronic_name, roll, effective_ai])


func _update_ai_for_hour():
	var hour = GameManager.get_in_game_hour()

	if hour <= last_hour_applied:
		return

	for h in range(last_hour_applied + 1, hour + 1):
		var add = GameManager.get_AI_for_hour("Phang", h)
		if add != 0:
			ai_level += add
			print("%s AI increased by %d at %d AM → %d" %
				[animatronic_name, add, h, ai_level])

	last_hour_applied = hour


func move_to_next_room():
	var current_room = room_database[current_room_id]
	var adjacent = current_room["AdjacentRooms"]

	var weights = {
		"Utility": 2.0,
		"Vent Section 1": 5.0,
		"Vent Section 2": 3.0,
		"Vent Section 3": 2.5,
		"Office": 5.0
	}

	var valid_rooms: Array = []

	for next_id in adjacent:
		var next_room = room_database[next_id]

		if next_room["SealedDoor"]:
			continue
		if next_room["Name"] == "Lounge":
			continue
		if not next_room["Empty"]:
			continue

		valid_rooms.append(next_id)

	if valid_rooms.is_empty():
		return

	var weighted: Array = []
	for id in valid_rooms:
		var room_name = room_database[id]["Name"]
		var w = weights.get(room_name, 1.0)
		for i in range(int(w * 10)):
			weighted.append(id)

	var next_room_id = weighted[randi() % weighted.size()]
	var next_room = room_database[next_room_id]

	GameManager.animatronic_moved.emit(
		animatronic_name,
		current_room["Name"],
		next_room["Name"]
	)

	current_room["Empty"] = true
	next_room["Empty"] = false
	current_room_id = next_room_id

	if next_room["Name"] == "Office":
		trigger_attack()


func handle_flashed(mascot_name) -> void:
	if mascot_name != animatronic_name:
		return

	var current_room = room_database[current_room_id]
	var reset_id = 11
	var next_room = room_database[reset_id]

	GameManager.animatronic_moved.emit(animatronic_name, current_room["Name"], next_room["Name"])

	current_room["Empty"] = true
	next_room["Empty"] = false
	current_room_id = reset_id

	ai_level = GameManager.set_night_start_AI("Phang")
	last_hour_applied = 0

	print("%s was flashed → AI reset to %d" % [animatronic_name, ai_level])


func trigger_attack():
	move_timer.stop()
	print("%s attacks the player!" % animatronic_name)
	get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")
