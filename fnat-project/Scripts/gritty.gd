extends Node2D

@export var room_database_scene: PackedScene
@export var move_interval: float = 4.98
@export var max_peaks: int = 3

var room_database: Dictionary
var current_room_id = 1
var peak = 0
@onready var move_timer: Timer = $Timer
@onready var Jumpscare: CanvasLayer = $Jumpscare
@onready var JumpScare_Image = Jumpscare.get_node("JumpImage")

var animatronic_name = "Gritty"

var ai_level: int = 0
var aggression_multiplier: float = 1.0
var is_aggressive: bool = false

var last_hour_applied: int = 0

func _ready() -> void:
	randomize()
	JumpScare_Image.visible = false
	room_database = GameManager.shared_room_database.rooms

	GameManager.animatronic_started.emit(animatronic_name, room_database[current_room_id]["Name"])
	GameManager.animatronic_flashed.connect(handle_flashed)

	ai_level = GameManager.set_night_start_AI("Gritty")

	move_timer.wait_time = move_interval
	move_timer.timeout.connect(_action)
	move_timer.start()

	if GameManager:
		GameManager.gritty_boost_started.connect(_on_aggression_boost_started)
		GameManager.gritty_boost_ended.connect(_on_aggression_boost_ended)

	print("%s initialized in room: %s (AI %d)" % [animatronic_name, room_database[current_room_id]["Name"], ai_level])


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


func _update_ai_for_hour():
	var hour = GameManager.get_in_game_hour()

	if hour <= last_hour_applied:
		return

	for h in range(last_hour_applied + 1, hour + 1):
		var add = GameManager.get_AI_for_hour("Gritty", h)
		if add != 0:
			ai_level += add
			print("%s AI increased by %d at %d AM → %d" % [animatronic_name, add, h, ai_level])

	last_hour_applied = hour

func move_to_next_room():
	var current_room = room_database[current_room_id]
	var adjacent_rooms = current_room["AdjacentRooms"].duplicate()

	var room_weights = {
		"Office": 10.0,
		"LeftOfficeDoor" : 6.0,
		"RightOfficeDoor" : 6.0,
		"LeftHall": 3.0,
		"RightHall": 3.0,
		"Gym": 2.5,
		"RightLocker": 1.5,
		"LeftLocker": 1.5,
		"Storage": 0,
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
		return

	var weighted_rooms: Array = []
	for next_room_id in valid_rooms:
		var next_room = room_database[next_room_id]
		var room_name = next_room["Name"]
		var weight = room_weights.get(room_name, 1.0)

		for i in range(int(weight * 10)):
			weighted_rooms.append(next_room_id)

	var next_room_id = weighted_rooms[randi() % weighted_rooms.size()]
	var next_room = room_database[next_room_id]

	GameManager.animatronic_moved.emit(animatronic_name, current_room["Name"], next_room["Name"])

	current_room["Empty"] = true
	next_room["Empty"] = false
	current_room_id = next_room_id

	if next_room["Name"] == "Office":
		trigger_attack()


func handle_flashed(mascot_name) -> void:
	if mascot_name == animatronic_name:
		var current_room = room_database[current_room_id]
		var flashed_room_id = 7
		var next_room = room_database[flashed_room_id]

		GameManager.animatronic_moved.emit(animatronic_name, current_room["Name"], next_room["Name"])
		current_room["Empty"] = true
		next_room["Empty"] = false
		current_room_id = flashed_room_id

		print("%s was flashed and returned to %s" % [animatronic_name, next_room["Name"]])


func Show_Jumpscare() -> void:
	JumpScare_Image.visible = true
	print("Done Jumpscare.")

func trigger_attack() -> void:
	Show_Jumpscare()
	SoundEffects.get_node("jumpscare1").play()
	move_timer.stop()
	await get_tree().create_timer(0.8).timeout 
	get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")
