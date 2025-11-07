extends Node2D

var room_paths = {
	"Office": "res://scenes/rooms/Office.tscn",
	"CamGym": "res://scenes/rooms/Gym.tscn",
	"CamRH": "res://scenes/rooms/RightHall.tscn",
	"CamLH": "res://scenes/rooms/LeftHall.tscn",
	"CamBC": "res://scenes/rooms/BallCart.tscn",
	"CamRL": "res://scenes/rooms/RightLockers.tscn",
	"CamLL": "res://scenes/rooms/LeftLockers.tscn",
	"CamLounge": "res://scenes/rooms/Lounge.tscn",
	"CamStorage": "res://scenes/rooms/Storage.tscn",
	"CamCafe": "res://scenes/rooms/Cafe.tscn",
	"CamCloset": "res://scenes/rooms/Closet.tscn",
	"CamUtility": "res://scenes/rooms/Utility.tscn"
}

func _ready() -> void: 
	GameManager.animatronic_moved.connect(update_Animatronics_On_Cam)
	load_room(room_paths["Office"])
	
var office_active = true
var last_room_path: String = ""
var current_room_path: String = room_paths["Office"]
var current_room: Node = null
@onready var room_container = $RoomContainer

func load_room(scene_path: String) -> void:
	if current_room:
		current_room.queue_free()

	var new_room_scene = load(scene_path)
	var new_room = new_room_scene.instantiate()
	GameManager.loaded_new_cam.emit(new_room, new_room.get_name())
	room_container.add_child(new_room)
		

	# Update state tracking
	if scene_path != current_room_path:
		last_room_path = current_room_path
	current_room_path = scene_path
	current_room = new_room
	
func update_Animatronics_On_Cam(mascot, old_room, new_room) -> void:
	if old_room == current_room.get_name():
		print("Static Static, Animatronic has Moved on Cam.")
		GameManager.loaded_new_cam.emit(current_room, current_room.get_name())
	
	

func _on_cam_gym_pressed() -> void:
	load_room(room_paths["CamGym"])


func _on_cam_rh_pressed() -> void:
	load_room(room_paths["CamRH"])


func _on_cam_lh_pressed() -> void:
	load_room(room_paths["CamLH"])


func _on_cam_bc_pressed() -> void:
	load_room(room_paths["CamBC"])


func _on_cam_rl_pressed() -> void:
	load_room(room_paths["CamRL"])


func _on_cam_ll_pressed() -> void:
	load_room(room_paths["CamLL"])


func _on_cam_lounge_pressed() -> void:
	load_room(room_paths["CamLounge"])


func _on_cam_storage_pressed() -> void:
	load_room(room_paths["CamStorage"])


func _on_cam_cafe_pressed() -> void:
	load_room(room_paths["CamCafe"])


func _on_cam_closet_pressed() -> void:
	load_room(room_paths["CamCloset"])


func _on_cam_utility_pressed() -> void:
	load_room(room_paths["CamUtility"])


func _on_switch_button_mouse_entered() -> void:
	if office_active:
		# If last room, go back to it
		if last_room_path != "":
			load_room(last_room_path)
			make_camera_map_visible()
	else:
		# Go back to office
		load_room(room_paths["Office"])
		make_camera_map_invisible()

	office_active = !office_active
	
func make_camera_map_invisible():
	for child in get_children():
		# Check if the child node is a Button (or inherits from it)
		if child is Button:
			# Set the Button's visible property to false
			child.visible = false
func make_camera_map_visible():
	for child in get_children():
		# Check if the child node is a Button (or inherits from it)
		if child is Button:
			# Set the Button's visible property to false
			child.visible = true
