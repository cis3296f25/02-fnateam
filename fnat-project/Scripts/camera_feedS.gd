extends Node2D

signal cams_opened
signal cams_closed

var room_scenes = {
	"Office": preload("res://Scenes/rooms/Office.tscn"),
	"CamGym": preload("res://Scenes/rooms/Gym.tscn"),
	"CamRH": preload("res://Scenes/rooms/RightHall.tscn"),
	"CamLH": preload("res://Scenes/rooms/LeftHall.tscn"),
	"CamBC": preload("res://Scenes/rooms/BallCart.tscn"),
	"CamRL": preload("res://Scenes/rooms/RightLockers.tscn"),
	"CamLL": preload("res://Scenes/rooms/LeftLockers.tscn"),
	"CamLounge": preload("res://Scenes/rooms/Lounge.tscn"),
	"CamStorage": preload("res://Scenes/rooms/Storage.tscn"),
	"CamCafe": preload("res://Scenes/rooms/Cafe.tscn"),
	"CamCloset": preload("res://Scenes/rooms/Closet.tscn"),
	"CamUtility": preload("res://Scenes/rooms/Utility.tscn")
}

func _ready() -> void: 
	GameManager.animatronic_moved.connect(update_Animatronics_On_Cam)
	make_camera_map_invisible()
	load_room(room_scenes["Office"])
	
var office_active = true
var last_room_scene = room_scenes["CamStorage"]
var current_room_scene = room_scenes["Office"]
var current_room: Node = null
@onready var room_container = $RoomContainer

func load_room(scene_object) -> void:
	if current_room:
		current_room.queue_free()

	var new_room_scene = scene_object
	var new_room = new_room_scene.instantiate()
	GameManager.loaded_new_cam.emit(new_room, new_room.get_name())
	room_container.add_child(new_room)
		

	# Update state tracking
	if scene_object != current_room_scene:
		last_room_scene = current_room_scene
	current_room_scene = scene_object
	current_room = new_room
	
	
func update_Animatronics_On_Cam(_mascot, old_room, _new_room) -> void:
	if old_room == current_room.get_name():
		print("Static Static, Animatronic has Moved on Cam.")
		GameManager.loaded_new_cam.emit(current_room, current_room.get_name())
	
	

func _on_cam_gym_pressed() -> void:
	load_room(room_scenes["CamGym"])


func _on_cam_rh_pressed() -> void:
	load_room(room_scenes["CamRH"])


func _on_cam_lh_pressed() -> void:
	load_room(room_scenes["CamLH"])


func _on_cam_bc_pressed() -> void:
	load_room(room_scenes["CamBC"])


func _on_cam_rl_pressed() -> void:
	load_room(room_scenes["CamRL"])


func _on_cam_ll_pressed() -> void:
	load_room(room_scenes["CamLL"])


func _on_cam_lounge_pressed() -> void:
	load_room(room_scenes["CamLounge"])


func _on_cam_storage_pressed() -> void:
	load_room(room_scenes["CamStorage"])


func _on_cam_cafe_pressed() -> void:
	load_room(room_scenes["CamCafe"])


func _on_cam_closet_pressed() -> void:
	load_room(room_scenes["CamCloset"])


func _on_cam_utility_pressed() -> void:
	load_room(room_scenes["CamUtility"])


func _on_switch_button_mouse_entered() -> void:
	if office_active:
		# If last room, go back to it
		if last_room_scene != null:
			load_room(last_room_scene)
			make_camera_map_visible()
			
	else:
		# Go back to office
		load_room(room_scenes["Office"])
		make_camera_map_invisible()

	office_active = !office_active
	
func make_camera_map_invisible():
	emit_signal("cams_closed")
	for child in get_children():
		# Check if the child node is a Button (or inherits from it)
		if child is Button:
			# Set the Button's visible property to false
			child.visible = false
func make_camera_map_visible():
	emit_signal("cams_opened")
	for child in get_children():
		# Check if the child node is a Button (or inherits from it)
		if child is Button:
			# Set the Button's visible property to false
			child.visible = true
