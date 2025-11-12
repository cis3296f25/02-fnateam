extends Node2D

@export var room_database_scene: PackedScene
@export var move_interval: float = 4.97
@export var max_peaks: int = 3
var animatronic_name = "Phillies Fnatic"

var room_database : Dictionary
var current_room_id = 1
var peak = 0
@onready var move_timer: Timer = $Timer
var ai_level: int = 5

var flash = false


func _ready() -> void:
	randomize()
	#  Instance the room database scene
	var db_scene = preload("res://Scenes/Room_Database.tscn")
	var db_instance = db_scene.instantiate()
	
	#  Access its exported variable that contains the rooms dictionary
	room_database = db_instance.rooms
	GameManager.animatronic_started.emit(animatronic_name, room_database[current_room_id]["Name"])
	#print(" starting in:", room_database[current_room_id]["Name"])
	# Setting up the timer
	move_timer.wait_time = move_interval
	move_timer.timeout.connect(_action)

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

		if next_room["Name"] in ["Vent Section 1", "Vent Section 2", "Vent Section 3", "Right Lockers", "RightHall", "Cafe"] \
		or next_room["SealedDoor"] or not next_room["Empty"]:
			adjacent_rooms.erase(next_room_id)
			continue
			
		if next_room["Name"] == "Office Left" and flash == true:
			adjacent_rooms.erase(next_room_id)
			continue
		# when ani in at right outside office and flash is turned on
		if next_room["Name"] == "Office" and flash == true:
			adjacent_rooms.erase(next_room_id)
			continue
			
		GameManager.animatronic_moved.emit(animatronic_name, current_room["Name"],next_room["Name"] )
		#print("Phillies Fnatic moved from %s → %s" % [current_room["Name"], next_room["Name"]])
		current_room["Empty"] = true
		next_room["Empty"] = false
		current_room_id = next_room_id

		return

	print("Phillies Fnatic couldn't move from", current_room["Name"], "- no valid rooms available.")

func trigger_attack() -> void:
	print("Phillies Fnatic attacks the player! GAME OVER ")
	move_timer.stop()
	
