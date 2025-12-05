extends Node2D

@export var room_database_scene: PackedScene
@export var move_interval: float = 4.98
@export var max_peaks: int = 3

var room_database: Dictionary
var current_room_id := 1
var peak := 0
@onready var move_timer: Timer = $Timer
@onready var Jumpscare: CanvasLayer = $Jumpscare
@onready var JumpScare_Image = Jumpscare.get_node("JumpImage")

var animatronic_name := "Phillies_Fnatic"
var ai_key := "Phanatic"

var ai_level: int = 0
var aggression_multiplier: float = 1.0
var is_aggressive: bool = false
var last_hour_applied := 0


func _ready() -> void:
	add_to_group("Phillies_Fnatic")
	randomize()
	JumpScare_Image.visible = false
	room_database = GameManager.shared_room_database.rooms

	GameManager.animatronic_started.emit(animatronic_name, room_database[current_room_id]["Name"])
	GameManager.animatronic_flashed.connect(handle_flashed)

	ai_level = GameManager.set_night_start_AI(ai_key)
	print(animatronic_name, "starting AI =", ai_level)

	move_timer.wait_time = move_interval
	move_timer.timeout.connect(_action)
	move_timer.start()

	GameManager.phanatic_boost_started.connect(_on_aggression_boost_started)
	GameManager.phanatic_boost_ended.connect(_on_aggression_boost_ended)
	

func _on_aggression_boost_started() -> void:
	if not is_aggressive:
		is_aggressive = true
		aggression_multiplier = 2.0
		print("%s is now AGGRESSIVE!" % animatronic_name)

func _on_aggression_boost_ended() -> void:
	if is_aggressive:
		is_aggressive = false
		aggression_multiplier = 1.0
		print("%s calmed down." % animatronic_name)


func _action() -> void:
	_update_ai_for_hour()

	var roll = randi() % 20 + 1
	var effective_ai = int(ai_level * aggression_multiplier)

	if roll < effective_ai:
		move_to_next_room()
		print("%s moved (roll=%d, AI=%d)" % [animatronic_name, roll, effective_ai])


func _update_ai_for_hour() -> void:
	var hour = GameManager.get_in_game_hour()
	if hour <= last_hour_applied:
		return

	for h in range(last_hour_applied + 1, hour + 1):
		var add = GameManager.get_AI_for_hour(ai_key, h)
		if add != 0:
			ai_level += add
			print("%s AI +%d at %d AM → %d" % [animatronic_name, add, h, ai_level])

	last_hour_applied = hour


func move_to_next_room() -> void:
	var current_room = room_database[current_room_id]
	var adjacent_rooms: Array = current_room["AdjacentRooms"].duplicate()

	var room_weights = {
		"Office": 200.0,
		"LeftOfficeDoor" : 10.0,
		"RightOfficeDoor" : 10.0,
		"LeftHall": 9.0,
		"RightHall": 9.0,
		"Gym": 3.0,
		"RightLockers": 6.0,
		"LeftLockers": 6.0,
		"Storage": 0,
		"Closet": 3.0,
		"Lounge": 1.0
	}

	var valid: Array = []
	for id in adjacent_rooms:
		var room = room_database[id]
		if room["SealedDoor"]:
			continue
		if room["Name"] in ["Vent Section 1", "Vent Section 2", "Vent Section 3", "Cafe", "RightLockers", "RightHall", "RightOfficeDoor"]:
			continue
		valid.append(id)

	if valid.is_empty():
		return

	var weighted: Array = []
	for id in valid:
		var name: String = room_database[id]["Name"]
		var w: float = room_weights.get(name, 1.0)
		for i in range(int(w * 10)):
			weighted.append(id)

	var next_id = weighted[randi() % weighted.size()]
	var next_room = room_database[next_id]

	GameManager.animatronic_moved.emit(animatronic_name, current_room["Name"], next_room["Name"])

	current_room["Empty"] = true
	next_room["Empty"] = false
	current_room_id = next_id

	if next_room["Name"] == "Office":
		trigger_attack()


func handle_flashed(mascot_name: String) -> void:
	if mascot_name != animatronic_name:
		return

	var current_room = room_database[current_room_id]
	var reset_id := 7
	var next_room = room_database[reset_id]

	GameManager.animatronic_moved.emit(animatronic_name, current_room["Name"], next_room["Name"])

	current_room["Empty"] = true
	next_room["Empty"] = false
	current_room_id = reset_id

	ai_level = GameManager.set_night_start_AI(ai_key)
	last_hour_applied = 0
	print("%s flashed → reset to AI %d" % [animatronic_name, ai_level])

func Show_Jumpscare() -> void:
	JumpScare_Image.visible = true
	print("Done Jumpscare.")

func trigger_attack() -> void:
	Show_Jumpscare()
	SoundEffects.get_node("jumpscare1").play()
	move_timer.stop()
	await get_tree().create_timer(0.8).timeout 
	get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")
