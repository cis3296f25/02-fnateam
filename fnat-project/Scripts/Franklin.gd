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
var time_without_check: float = 0.0


func _ready() -> void:
	randomize()

	room_database = GameManager.shared_room_database.rooms

	GameManager.animatronic_started.emit(animatronic_name, room_database[current_room_id]["Name"])
	GameManager.animatronic_flashed.connect(_on_flashed)

	move_timer.wait_time = move_interval
	move_timer.timeout.connect(_action)
	move_timer.start()

	if GameManager:
		GameManager.franklin_boost_started.connect(_on_aggression_boost_started)
		GameManager.franklin_boost_ended.connect(_on_aggression_boost_ended)

	print("%s initialized in room: %s" % [animatronic_name, room_database[current_room_id]["Name"]])


func _on_aggression_boost_started():
	if !is_agressive:
		is_agressive = true
		aggression_multiplier = 2.0
		print("%s is now AGGRESSIVE! (2x movement chance)" % animatronic_name)

func _on_aggression_boost_ended():
	if is_agressive:
		is_agressive = false
		aggression_multiplier = 1.0
		print("%s calmed down." % animatronic_name)


func _action() -> void:
	var roll = randi() % 20 + 1
	var effective_ai = int(ai_level * aggression_multiplier)

	if roll < effective_ai:
		move_to_next_room()
		print("%s moved! (Roll: %d < Effective AI: %d)" %
			[animatronic_name, roll, effective_ai])


func move_to_next_room():
	var current_room = room_database[current_room_id]
	var adjacent_rooms = current_room["AdjacentRooms"].duplicate()

	var room_weights = {
		"Office": 4.0,
		"LeftHall": 3.0,
		"RightHall": 3.0,
		"gym": 2.5,
		"RightLocker": 1.5,
		"LeftLocker": 1.5,
		"Storage": 0.5,
		"Lounge": 1.0
	}

	var valid_rooms = []
	for next_room_id in adjacent_rooms:
		var next_room = room_database[next_room_id]

		if next_room["SealedDoor"]:
			continue
		if next_room["Name"] in ["Vent Section 1", "Vent Section 2", "Vent Section 3", "Cafe", "LeftLocker", "LeftOfficeDoor"]:
			continue

		valid_rooms.append(next_room_id)

	if valid_rooms.is_empty():
		print("%s couldn't move from %s - no valid rooms available." %
			[animatronic_name, current_room["Name"]])
		return

	var weighted_rooms: Array = []
	for next_room_id in valid_rooms:
		var next_room = room_database[next_room_id]
		var name = next_room["Name"]
		var w = room_weights.get(name, 1.0)

		for i in range(int(w * 10)):
			weighted_rooms.append(next_room_id)

	var next_room_id = weighted_rooms[randi() % weighted_rooms.size()]
	var next_room = room_database[next_room_id]

	GameManager.animatronic_moved.emit(animatronic_name, current_room["Name"], next_room["Name"])
	current_room["Empty"] = true
	next_room["Empty"] = false
	current_room_id = next_room_id

	print("%s moved towards %s (Weighted choice)" % [animatronic_name, next_room["Name"]])

	if next_room["Name"] == "Office":
		trigger_attack()


func _on_flashed(mascot_name):
	if mascot_name != animatronic_name:
		return

	print("%s was flashed!" % animatronic_name)

	stage = 1
	time_without_check = 0

	var current_room = room_database[current_room_id]
	var current_name = current_room["Name"]

	var LEFT_DOOR_NAME = "LeftOfficeDoor"
	var RIGHT_DOOR_NAME = "RightOfficeDoor"

	var LEFT_DOOR_ID = 17
	var RIGHT_DOOR_ID = 16

	var target_room_id = 15

	if current_name == LEFT_DOOR_NAME:
		target_room_id = RIGHT_DOOR_ID
		print("Franklin flashed in LeftHall → jumping to RightHall")

	elif current_name == RIGHT_DOOR_NAME:
		target_room_id = LEFT_DOOR_ID
		print("Franklin flashed in RightHall → jumping to LeftHall")

	else:
		var choices = [LEFT_DOOR_ID, RIGHT_DOOR_ID]
		target_room_id = choices[randi() % 2]
		print("Franklin flashed elsewhere → jumping to random door")

	var next_room = room_database[target_room_id]
	GameManager.animatronic_moved.emit(animatronic_name, current_room["Name"], next_room["Name"])

	current_room["Empty"] = true
	next_room["Empty"] = false
	current_room_id = target_room_id

	print("%s teleported to %s after flash" % [animatronic_name, next_room["Name"]])

	if GameManager.has_method("drain_power"):
		GameManager.drain_power(5)
		print("Franklin drained 5% power upon flash!")
	else:
		push_warning("GameManager.drain_power(amount) is missing!")


func trigger_attack() -> void:
	print("%s attacks the player! GAME OVER" % animatronic_name)
	move_timer.stop()
	get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")
