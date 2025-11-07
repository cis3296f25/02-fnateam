extends Node2D

@export var room_database_scene: PackedScene
@export var move_interval: float = 4.98
@export var max_peaks: int = 3

var room_database : Dictionary
var current_room_id = 1
var peak = 0
@onready var move_timer: Timer = $Timer
var ai_level: int = 5
var animatronic_name = "Gritty"


func _ready() -> void:
	randomize()

	#  Instance the room database scene
	var db_scene = preload("res://Scenes/Room_Database.tscn")

	var db_instance = db_scene.instantiate()

	#  Access its exported variable that contains the rooms dictionary
	room_database = db_instance.rooms

	#Send a Signal to the game saying where the animatronic started
	GameManager.animatronic_started.emit(animatronic_name, room_database[current_room_id]["Name"])
	#print("Gritty starting in:", room_database[current_room_id]["Name"])
	
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

		if next_room["Name"] in ["Vent Section 1", "Vent Section 2", "Vent Section 3","Closet", "Left Locker","Left Hallway"] \
		or next_room["SealedDoor"] or not next_room["Empty"]:
			adjacent_rooms.erase(next_room_id)
			continue
		
		GameManager.animatronic_moved.emit(animatronic_name, current_room["Name"],next_room["Name"] )
		#print("Gritty moved from %s → %s" % [current_room["Name"], next_room["Name"]])
		current_room["Empty"] = true
		next_room["Empty"] = false
		current_room_id = next_room_id
		return

	print("Gritty couldn't move from", current_room["Name"], "- no valid rooms available.")

func trigger_attack() -> void:
	print("Gritty attacks the player! GAME OVER ")
	move_timer.stop()
