extends Node2D

@export var room_database_scene: PackedScene
@export var move_interval: float = 4.98

var room_database: Dictionary
var current_room_id = 14

@onready var move_timer: Timer = $Timer
@onready var stage_timer: Timer = $stage_time

@export var ai_level: int = 5
var animatronic_name = "Franklin"

var aggression_multiplier: float = 1.0
var is_agressive: bool = false

var stage: int = 1


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

	_setup_stage_timer()

	print("%s initialized in room: %s" % [animatronic_name, room_database[current_room_id]["Name"]])


func _setup_stage_timer():
	# Use the Timer node in the scene, DO NOT create a new timer
	stage_timer.one_shot = false
	stage_timer.timeout.connect(_on_stage_tick)
	stage_timer.start()


func _on_stage_tick():
	if stage >= 5:
		return

	stage += 1
	print("%s advanced to STAGE %d" % [animatronic_name, stage])

	if stage == 4:
		_run_towards_hall()

	if stage == 5:
		trigger_attack()


func _on_aggression_boost_started():
	if not is_agressive:
		is_agressive = true
		aggression_multiplier = 2.0
		print("%s is now AGGRESSIVE!" % animatronic_name)


func _on_aggression_boost_ended():
	if is_agressive:
		aggression_multiplier = 1.0
		is_agressive = false
		print("%s calmed down." % animatronic_name)


func _action() -> void:
	if stage < 4:
		var roll = randi() % 20
		var effective_ai = int(ai_level * aggression_multiplier)

		if roll < effective_ai:
			move_to_next_room()
			print("%s moved! Roll %d < AI %d" % [animatronic_name, roll, effective_ai])


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
	for id in adjacent_rooms:
		var next_room = room_database[id]
		if next_room["SealedDoor"]:
			continue
		if next_room["Name"] in ["Vent Section 1", "Vent Section 2", "Vent Section 3", "Cafe", "LeftOfficeDoor"]:
			continue
		valid_rooms.append(id)

	if valid_rooms.is_empty():
		print("%s stuck in %s" % [animatronic_name, current_room["Name"]])
		return

	var weighted: Array = []
	for id in valid_rooms:
		var next_room = room_database[id]
		var w = room_weights.get(next_room["Name"], 1.0)
		for i in range(int(w * 10)):
			weighted.append(id)

	var next_room_id = weighted[randi() % weighted.size()]
	var next_room = room_database[next_room_id]

	GameManager.animatronic_moved.emit(animatronic_name, current_room["Name"], next_room["Name"])
	current_room["Empty"] = true
	next_room["Empty"] = false
	current_room_id = next_room_id

	print("%s moved toward %s" % [animatronic_name, next_room["Name"]])

	if next_room["Name"] == "Office":
		trigger_attack()


func handle_flashed(mascot_name) -> void:
	if mascot_name != animatronic_name:
		return

	stage = 1
	stage_timer.start()

	var ballcart_id = _get_room_id_by_name("BallCart")

	var current_room = room_database[current_room_id]
	var next_room = room_database[ballcart_id]

	GameManager.animatronic_moved.emit(animatronic_name, current_room["Name"], next_room["Name"])

	current_room["Empty"] = true
	next_room["Empty"] = false
	current_room_id = ballcart_id

	print("%s flashed → returned to BallCart." % animatronic_name)


func _get_room_id_by_name(room_name: String) -> int:
	for id in room_database:
		if room_database[id]["Name"] == room_name:
			return id
	return -1


func trigger_attack():
	print("%s attacks the player!" % animatronic_name)
	move_timer.stop()
	stage_timer.stop()
	get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")
