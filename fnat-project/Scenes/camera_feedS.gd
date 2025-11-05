extends Node2D

@onready var room_container = $RoomContainer

var current_room : Node = null

var room_paths = {
	"CamF": "res://scenes/rooms/RoomF.tscn",
	"CamL1": "res://scenes/rooms/RoomL1.tscn",
	"CamL2": "res://scenes/rooms/RoomL2.tscn",
	"CamR1": "res://scenes/rooms/RoomR1.tscn",
	"CamR2": "res://scenes/rooms/RoomR2.tscn",
	"CamR3": "res://scenes/rooms/RoomR3.tscn",
	"CamSec": "res://scenes/rooms/RoomSec.tscn"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_room(room_paths["CamSec"])

func load_room(scene_path: String):
	if current_room:
		current_room.queue_free()  # remove previous room

	var new_room_scene = load(scene_path)
	var new_room = new_room_scene.instantiate()
	room_container.add_child(new_room)
	current_room = new_room

func _on_f_pressed() -> void:
	load_room(room_paths["CamF"])


func _on_l1_pressed() -> void:
	load_room(room_paths["CamL1"])


func _on_l2_pressed() -> void:
	load_room(room_paths["CamL2"])


func _on_r1_pressed() -> void:
	load_room(room_paths["CamR1"])


func _on_r2_pressed() -> void:
	load_room(room_paths["CamR2"])
	
	
func _on_r3_pressed() -> void:
	load_room(room_paths["CamR3"])


func _on_sec_pressed() -> void:
	load_room(room_paths["CamSec"])


func _on_switch_button_mouse_entered() -> void:
	load_room(room_paths["CamSec"])


func _on_switch_button_mouse_exited() -> void:
	pass # Replace with function body.
