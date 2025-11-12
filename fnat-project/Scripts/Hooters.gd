extends Node2D


@export var room_database_scene: PackedScene
@export var move_interval: float = 4.98
@export var max_peaks: int = 3

var room_database: Dictionary
var current_room_id = 1
var peak = 0
@onready var move_timer: Timer = $Timer
var ai_level: int = 5
var animatronic_name = "Hooter"
var aggression_multiplier: float = 1.0

func _ready() -> void:
	randomize()

	# Instance the room database scene
	var db_scene = preload("res://Scenes/Room_Database.tscn")
	var db_instance = db_scene.instantiate()

	# Access exported rooms dictionary
	room_database = db_instance.rooms

	# Send signal that this animatronic started
	GameManager.animatronic_started.emit(animatronic_name, room_database[current_room_id]["Name"])

	# Set up movement timer
	move_timer.wait_time = move_interval
	move_timer.timeout.connect(_action)

	# Connect to GameManager signals
	if GameManager:
		GameManager.aggression_boost_started.connect(_on_aggression_boost_started)
		GameManager.aggression_boost_ended.connect(_on_aggression_boost_ended)

func _on_aggression_boost_started():
	aggression_multiplier = 2.0
	print("%s is now AGGRESSIVE! (2x movement chance)" % animatronic_name)

func _on_aggression_boost_ended():
	aggression_multiplier = 1.0
	print("%s calmed down" % animatronic_name)

func _action() -> void:
	var roll = randi() % 21
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

		if next_room["Name"] in ["Vent Section 1", "Vent Section 2", "Vent Section 3"] \
		or next_room["SealedDoor"] or not next_room["Empty"]:
			adjacent_rooms.erase(next_room_id)
			continue
		
		GameManager.animatronic_moved.emit(animatronic_name, current_room["Name"],next_room["Name"] )
		#print("Hooter moved from %s → %s" % [current_room["Name"], next_room["Name"]])
		current_room["Empty"] = true
		next_room["Empty"] = false
		current_room_id = next_room_id

		if next_room["Name"] in ["LeftHall", "RightHall"]:
			handle_peek(next_room["Name"])

		return

	print("Hooter couldn't move from", current_room["Name"], "- no valid rooms available.")


func handle_peek(room_name: String) -> void:
	move_timer.stop()
	peak += 1
	print("Hooter is at the %s! Peek count: %d" % [room_name, peak])

	await get_tree().create_timer(1.0).timeout

	if peak >= max_peaks:
		trigger_attack()
	else:
		print("Hooter leaves the hallway after peeking.")
		move_timer.start()


func trigger_attack() -> void:
	print("Hooter attacks the player! GAME OVER ")
	move_timer.stop()
