extends Node2D

@export var room_database_scene: PackedScene
@export var move_interval: float = 5.0
@export var max_peaks: int = 3

var room_database : Dictionary
var current_room_id = 1
var peak = 0
var move_timer: Timer
var ai_level: int = 5


func _ready() -> void:
	randomize()

	#  Instance the room database scene
	var db_instance = room_database_scene.instantiate()

	#  Access its exported variable that contains the rooms dictionary
	room_database = db_instance.rooms

	print("Hooter starting in:", room_database[current_room_id]["Name"])

func _aggro():
	ai_level = min(ai_level + 1, 20)

func _action() -> void:
	var roll = randi() % 21
	if roll < ai_level:
		move_to_next_room()

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

		print("Hooter moved from %s → %s" % [current_room["Name"], next_room["Name"]])
		current_room["Empty"] = true
		next_room["Empty"] = false
		current_room_id = next_room_id

		if next_room["Name"] in ["Left Hallway", "Right Hallway"]:
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
