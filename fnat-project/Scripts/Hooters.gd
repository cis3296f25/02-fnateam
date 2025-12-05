extends Node2D

@export var room_database_scene: PackedScene
@export var move_interval: float = 4.98
@export var max_peaks: int = 3

var room_database: Dictionary
var current_room_id = 1
var last_room_id = 1
var peak = 0

@onready var move_timer: Timer = $Timer
@onready var taunt: Timer = $TauntTimer
@onready var Jumpscare: CanvasLayer = $Jumpscare
@onready var JumpScare_Image = Jumpscare.get_node("JumpImage")
@onready var sprite: Sprite2D = $sprite

@export var ai_level: int = 5
var animatronic_name = "Hooters"
var aggression_multiplier: float = 1.0
var is_agressive: bool = false

var last_hour_applied := 0


func _ready() -> void:
	add_to_group("Hooters")
	randomize()
	JumpScare_Image.visible = false
	room_database = GameManager.shared_room_database.rooms
	
	GameManager.animatronic_started.emit(animatronic_name, room_database[current_room_id]["Name"])
	GameManager.animatronic_flashed.connect(handle_flashed)

	move_timer.wait_time = move_interval
	move_timer.timeout.connect(_action)
	move_timer.start()

	if GameManager:
		GameManager.hooters_boost_started.connect(_on_aggression_boost_started)
		GameManager.hooters_boost_ended.connect(_on_aggression_boost_ended)

	set_AI_Level(GameManager.set_night_start_AI("Hooter"))

	print("%s initialized in room: %s" %
		[animatronic_name, room_database[current_room_id]["Name"]])


func set_AI_Level(new_Level : int):
	ai_level = new_Level
	print("Updated HOOTER AI LEVEL: ", ai_level)


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
	apply_hour_increments()

	var roll = randi() % 20 + 1
	var effective_ai = int(ai_level * aggression_multiplier)

	if roll < effective_ai:
		move_to_next_room()
		print("%s moved! (Roll: %d < EffectiveAI: %d)" %
			[animatronic_name, roll, effective_ai])


func apply_hour_increments():
	var hour = GameManager.get_in_game_hour()

	if hour <= last_hour_applied:
		return

	for h in range(last_hour_applied + 1, hour + 1):
		var add = GameManager.get_AI_for_hour("Hooter", h)
		if add != 0:
			ai_level += add
			print("Hooter AI increased by %d at %d AM → %d" %
				[add, h, ai_level])

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
		"Storage": 0.5,
		"Closet": 3.0,
		"Lounge": 1.0
	}

	var valid_rooms = []

	for next_room_id in adjacent_rooms:
		var next_room = room_database[next_room_id]

		if next_room["SealedDoor"]:
			continue

		if next_room["Name"] in ["Vent Section 1", "Vent Section 2", "Vent Section 3", "Cafe", "LeftLocker", "LeftOfficeDoor"]:
			continue

		# === NO MOVING BACKWARDS ===
		if next_room_id == last_room_id:
			continue

		if not next_room["Empty"]:
			continue

		valid_rooms.append(next_room_id)

	if valid_rooms.is_empty():
		print("%s stuck — no valid rooms." % animatronic_name)
		return

	var weighted_rooms = []

	for next_room_id in valid_rooms:
		var next_room = room_database[next_room_id]
		var weight = room_weights.get(next_room["Name"], 1.0)

		for i in range(int(weight * 10)):
			weighted_rooms.append(next_room_id)

	var next_room_id = weighted_rooms[randi() % weighted_rooms.size()]
	var next_room = room_database[next_room_id]

	GameManager.animatronic_moved.emit(animatronic_name,
		current_room["Name"], next_room["Name"])

	current_room["Empty"] = true
	next_room["Empty"] = false

	# track previous room (for no-backwards rule)
	last_room_id = current_room_id
	current_room_id = next_room_id

	print("%s moved to %s" % [animatronic_name, next_room["Name"]])

	if next_room["Name"] == "Office":
		trigger_attack()


func handle_peek(room_name: String) -> void:
	move_timer.stop()
	taunt.start()
	peak += 1

	print("%s is at %s! Peek %d" %
		[animatronic_name, room_name, peak])

	await get_tree().create_timer(1.0).timeout

	if peak >= max_peaks:
		trigger_attack()
	else:
		taunt.stop()
		move_timer.start()


func handle_flashed(mascot_name):
	if mascot_name == animatronic_name:
		var current_room = room_database[current_room_id]
		var flashed_room_id = 2
		var next_room = room_database[flashed_room_id]

		GameManager.animatronic_moved.emit(animatronic_name,
			current_room["Name"], next_room["Name"])

		current_room["Empty"] = true
		next_room["Empty"] = false

		last_room_id = current_room_id
		current_room_id = flashed_room_id

func Show_Jumpscare() -> void:
	JumpScare_Image.visible = true
	print("Done Jumpscare.")

func trigger_attack() -> void:
	Show_Jumpscare()
	SoundEffects.get_node("jumpscare1").play()
	move_timer.stop()
	await get_tree().create_timer(0.8).timeout 
	get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")

#func show_mascot() -> void:
	#sprite.visible = true
#
#func hide_mascot() -> void:
	#sprite.visible = false;
