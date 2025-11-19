extends Node2D

@export var room_database_scene: PackedScene
@export var move_interval: float = 4.98
@export var max_peaks: int = 3

var room_database: Dictionary
var current_room_id = 1
var peak = 0
@onready var move_timer: Timer = $Timer
@export var ai_level: int = 5
var animatronic_name = "Phillie Phanatic"
var aggression_multiplier: float = 1.0
var is_agressive: bool = false


func _ready() -> void:
	randomize()

	room_database = GameManager.shared_room_database.rooms

	GameManager.animatronic_started.emit(animatronic_name, room_database[current_room_id]["Name"])
	GameManager.animatronic_flashed.connect(handle_flashed)

	move_timer.wait_time = move_interval
	move_timer.timeout.connect(_action)
	move_timer.start()

	
	if GameManager:
		GameManager.phillie_boost_started.connect(_on_aggression_boost_started)
		GameManager.phillie_boost_ended.connect(_on_aggression_boost_ended)
	
	set_AI_Level(GameManager.set_night_start_AI("Fnatic"))
	
	print("%s initialized in room: %s" % [animatronic_name, room_database[current_room_id]["Name"]])

func set_AI_Level(new_Level : int):
	ai_level = new_Level
	print("Updated FNATIC AI LEVEL: ", ai_level)
	pass
	

func _on_aggression_boost_started():
	if is_agressive == false:
		is_agressive = true
		aggression_multiplier = 2.0
		print("%s is now AGGRESSIVE! (2x movement chance)" % animatronic_name)

func _on_aggression_boost_ended():
	if is_agressive == true:
		aggression_multiplier = 1.0
		is_agressive = false
		print("%s calmed down." % animatronic_name)


func _action() -> void:
	var roll = randi() % (20 - 1) + 1
	var effective_ai = int(ai_level * aggression_multiplier)

	if roll < effective_ai:
		move_to_next_room()
		print("%s moved! (Roll: %d < Effective AI: %d)" % [animatronic_name, roll, effective_ai])


func move_to_next_room():
	var current_room = room_database[current_room_id]
	var adjacent_rooms = current_room["AdjacentRooms"].duplicate()

	while adjacent_rooms.size() > 0:
		var next_room_id = adjacent_rooms[randi() % adjacent_rooms.size()]
		var next_room = room_database[next_room_id]
		
		if current_room["SealedDoor"]:
			adjacent_rooms.clear()
			break

		#if next_room["Name"] in ["Vent Section 1", "Vent Section 2", "Vent Section 3", "Closet", "LeftLocker", "LeftHall"] \
		#or next_room["SealedDoor"] or not next_room["Empty"]:
			#adjacent_rooms.erase(next_room_id)
		if next_room["Name"] in ["Vent Section 1", "Vent Section 2", "Vent Section 3", "Cafe", "RightLockers", "RightHall", "RightOfficeDoor"] \
		or next_room["SealedDoor"]:
			adjacent_rooms.erase(next_room_id)
			continue

		GameManager.animatronic_moved.emit(animatronic_name, current_room["Name"], next_room["Name"])
		current_room["Empty"] = true
		next_room["Empty"] = false
		current_room_id = next_room_id
		if next_room["Name"] == "Office":
			trigger_attack()
		return

	print("%s couldn't move from %s - no valid rooms available." % [animatronic_name, current_room["Name"]])

func handle_flashed(mascot_name) -> void:
	if mascot_name == animatronic_name:
		var current_room = room_database[current_room_id]
		var flashed_room_ID = 7
		var next_room = room_database[flashed_room_ID]
		GameManager.animatronic_moved.emit(animatronic_name, current_room["Name"], next_room["Name"])
		current_room["Empty"] = true
		next_room["Empty"] = false
		current_room_id = flashed_room_ID

func trigger_attack() -> void:
	print("%s attacks the player! GAME OVER" % animatronic_name)
	move_timer.stop()
	get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")
