extends Node2D

@export var room_database_scene: PackedScene
@export var move_interval: float = 4.98

var room_database: Dictionary
var current_room_id = 14
@onready var move_timer: Timer = $Timer

@export var ai_level: int = 5
var animatronic_name = "Franklin"

var aggression_multiplier: float = 1.0
var is_agressive: bool = false

var stage: int = 1
var time_without_check := 0.0
var time_to_stage_up := 10.0

var FLASH_POWER_COST := 5

func _ready() -> void:
	randomize()
	room_database = GameManager.shared_room_database.rooms
	GameManager.animatronic_started.emit(animatronic_name, room_database[current_room_id]["Name"])
	GameManager.animatronic_flashed.connect(handle_flashed)
	move_timer.wait_time = move_interval
	move_timer.timeout.connect(_action)
	move_timer.start()

	if GameManager:
		GameManager.franklin_boost_started.connect(_on_aggression_boost_started)
		GameManager.franklin_boost_ended.connect(_on_aggression_boost_ended)

	print("%s initialized in room: %s" % [animatronic_name, room_database[current_room_id]["Name"]])


func _on_aggression_boost_started():
	if is_agressive == false:
		is_agressive = true
		aggression_multiplier = 2.0
		print("%s is now AGGRESSIVE!" % animatronic_name)

func _on_aggression_boost_ended():
	if is_agressive == true:
		aggression_multiplier = 1.0
		is_agressive = false
		print("%s calmed down." % animatronic_name)


func _action() -> void:
	time_without_check += move_interval
	_process_stage_system()

	if stage < 4:
		var roll = randi() % 20
		var effective_ai = int(ai_level * aggression_multiplier)
		if roll < effective_ai:
			move_to_next_room()
			print("%s moved! (Roll: %d < AI: %d)" % [animatronic_name, roll, effective_ai])


func _process_stage_system():
	if time_without_check >= time_to_stage_up and stage < 5:
		stage += 1
		time_without_check = 0
		print("%s advanced to STAGE %d" % [animatronic_name, stage])

		if stage == 4:
			_run_towards_hall()
		if stage == 5:
			trigger_attack()


func _run_towards_hall():
	var hall_choice = randf()
	var target_room := ""
	if hall_choice < 0.5:
		target_room = "LeftOfficeDoor"
	else:
		target_room = "RightOfficeDoor"

	var current_room = room_database[current_room_id]
	var next_room_id = _get_room_id_by_name(target_room)
	var next_room = room_database[next_room_id]

	GameManager.animatronic_moved.emit(animatronic_name, current_room["Name"], next_room["Name"])
	current_room["Empty"] = true
	next_room["Empty"] = false
	current_room_id = next_room_id

	print("%s sprinted to %s!" % [animatronic_name, target_room])


func move_to_next_room():
	var current_room = room_database[current_room_id]
	var adjacent_rooms = current_room["AdjacentRooms"].duplicate()

	var room_weights = {
		"Office": 4.0,
		"LeftHall": 3.0,
		"RightHall": 3.0,
		"gym": 2.5,
		"RightOfficeDoor": 3.5,
		"LeftOfficeDoor": 3.5
	}

	var valid_rooms = []
	for next_room_id in adjacent_rooms:
		var next_room = room_database[next_room_id]
		if next_room["SealedDoor"]:
			continue
		if next_room["Name"] in ["Vent Section 1", "Vent Section 2", "Vent Section 3", "Cafe", "LeftOfficeDoor"]:
			continue
		valid_rooms.append(next_room_id)

	if valid_rooms.is_empty():
		print("%s stuck in room: %s" % [animatronic_name, current_room["Name"]])
		return

	var weighted_rooms: Array = []
	for next_room_id in valid_rooms:
		var next_room = room_database[next_room_id]
		var w = room_weights.get(next_room["Name"], 1.0)
		for i in range(int(w * 10)):
			weighted_rooms.append(next_room_id)

	var next_room_id = weighted_rooms[randi() % weighted_rooms.size()]
	var next_room = room_database[next_room_id]

	GameManager.animatronic_moved.emit(animatronic_name, current_room["Name"], next_room["Name"])
	current_room["Empty"] = true
	next_room["Empty"] = false
	current_room_id = next_room_id

	print("%s moved toward %s" % [animatronic_name, next_room["Name"]])

	if next_room["Name"] == "Office":
		trigger_attack()


func handle_flashed(mascot_name):
	if mascot_name != animatronic_name:
		return

	print("%s was FLASHED!" % animatronic_name)
	GameManager.reduce_power(FLASH_POWER_COST)

	stage = 1
	time_without_check = 0

	var current_name = room_database[current_room_id]["Name"]
	if stage >= 4:
		_jump_to_opposite_hall()
		return

	var safe_room_id = 14
	var current_room = room_database[current_room_id]
	var safe_room = room_database[safe_room_id]

	GameManager.animatronic_moved.emit(animatronic_name, current_room["Name"], safe_room["Name"])
	current_room["Empty"] = true
	safe_room["Empty"] = false
	current_room_id = safe_room_id

	print("%s returned to safe room." % animatronic_name)


func _jump_to_opposite_hall():
	var current_name = room_database[current_room_id]["Name"]
	var target_room := ""
	if current_name == "LeftOfficeDoor":
		target_room = "RightOfficeDoor"
	else:
		target_room = "LeftOfficeDoor"

	var new_room_id = _get_room_id_by_name(target_room)
	var next_room = room_database[new_room_id]
	var current_room = room_database[current_room_id]

	GameManager.animatronic_moved.emit(animatronic_name, current_room["Name"], next_room["Name"])
	current_room["Empty"] = true
	next_room["Empty"] = false
	current_room_id = new_room_id

	print("%s jumped to the opposite hall!" % animatronic_name)


func _get_room_id_by_name(room_name: String) -> int:
	for id in room_database:
		if room_database[id]["Name"] == room_name:
			return id
	return -1


func trigger_attack():
	print("%s attacks the player!" % animatronic_name)
	move_timer.stop()
	get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")
