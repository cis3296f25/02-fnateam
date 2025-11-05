extends Node2D

@onready var room_container = $RoomContainer

var current_room : Node = null

var room_paths = {
	"Office": "res://scenes/rooms/Room.tscn",
	"CamGym": "res://scenes/rooms/Room.tscn",
	"CamRH": "res://scenes/rooms/Room.tscn",
	"CamLH": "res://scenes/rooms/Room.tscn",
	"CamBC": "res://scenes/rooms/Room.tscn",
	"CamRL": "res://scenes/rooms/Room.tscn",
	"CamLL": "res://scenes/rooms/Room.tscn",
	"CamLounge": "res://scenes/rooms/Room.tscn",
	"CamStorage": "res://scenes/rooms/Room.tscn",
	"CamCafe": "res://scenes/rooms/Room.tscn",
	"CamCloset": "res://scenes/rooms/Room.tscn",
	"CamUtility": "res://scenes/rooms/Room.tscn"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass 
	#load_room(room_paths["Office"])

#func load_room(scene_path: String):
	#if current_room:
		#current_room.queue_free()  # remove previous room
#
	#var new_room_scene = load(scene_path)
	#var new_room = new_room_scene.instantiate()
	#room_container.add_child(new_room)
	#current_room = new_room

func _on_cam_gym_pressed() -> void:
	pass # Replace with function body.


func _on_cam_rh_pressed() -> void:
	pass # Replace with function body.


func _on_cam_lh_pressed() -> void:
	pass # Replace with function body.


func _on_cam_bc_pressed() -> void:
	pass # Replace with function body.


func _on_cam_rl_pressed() -> void:
	pass # Replace with function body.


func _on_cam_ll_pressed() -> void:
	pass # Replace with function body.


func _on_cam_lounge_pressed() -> void:
	pass # Replace with function body.


func _on_cam_storage_pressed() -> void:
	pass # Replace with function body.


func _on_cam_cafe_pressed() -> void:
	pass # Replace with function body.


func _on_cam_closet_pressed() -> void:
	pass # Replace with function body.


func _on_cam_utility_pressed() -> void:
	pass # Replace with function body.
