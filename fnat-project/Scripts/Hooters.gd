extends Node2D

@export var room_database_scene: PackedScene
var rooms = []
var current_room_index = 0
var move_timer = 0.0
var move_interval = 10.0
var active = true

signal game_over

func _ready():
	# Instantiate the room database
	if room_database_scene:
		var db_instance = room_database_scene.instantiate()
		add_child(db_instance) # Optional: if you want it visible in scene tree

		# Collect all child rooms dynamically
		rooms = db_instance.get_children()

		if rooms.size() > 0:
			print("Hooter starting in: ", rooms[0].name)
		else:
			push_error("Room_Database has no rooms!")
	else:
		push_error("No Room Database scene assigned!")

func _on_timer_timeout():
	if active:
		move_to_next_room()
	

func move_to_next_room():
	if current_room_index < rooms.size() - 1:
		current_room_index += 1
		var new_room = rooms[current_room_index]
		print("Hooter moved to: ", new_room.name)

		move_interval = max(3.0, move_interval - 1.0)

		if new_room.name == "Office":
			trigger_game_over()
	else:
		trigger_game_over()

func trigger_game_over():
	print("Hooter reached the Office! Game Over!")
	emit_signal("game_over")
	active = false
