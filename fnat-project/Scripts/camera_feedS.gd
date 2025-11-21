extends Node2D

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
	"CamUtility": preload("res://Scenes/rooms/Utility.tscn"),
	"CamStatic": preload("res://Scenes/StaticScreen.tscn"),
}

func _ready() -> void: 
	GameManager.animatronic_moved.connect(update_Animatronics_On_Cam)
	GameManager.power_ran_out.connect(power_outage_handler)
	GameManager.power_back.connect(power_return_handler)
	make_camera_map_invisible()
	load_room(room_scenes["Office"])
	$ButtonContainer/RoomLabel.text = "STORAGE"
	
var office_active = true
var camera_locked = false
@onready var button_container = $ButtonContainer
@onready var room_label = $ButtonContainer/RoomLabel
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
	
func power_outage_handler():
	camera_locked = true
	load_room(room_scenes["Office"])
	make_camera_map_invisible()
	office_active = true

func power_return_handler():
	camera_locked = false
	

func update_Animatronics_On_Cam(_mascot, old_room, new_room) -> void:
	if old_room == current_room.get_name() or new_room == current_room.get_name():
		print("Static Static, Animatronic has Moved on Cam.")
		load_room(room_scenes["CamStatic"])
		GameManager.loaded_new_cam.emit(current_room, current_room.get_name())
	

func _on_cam_gym_pressed() -> void:
	SoundEffects.get_node("screenTap").play()
	load_room(room_scenes["CamGym"])
	room_label.text = "GYM"

func _on_cam_rh_pressed() -> void:
	SoundEffects.get_node("screenTap").play()
	load_room(room_scenes["CamRH"])
	room_label.text = "RIGHT HALLWAY"

func _on_cam_lh_pressed() -> void:
	SoundEffects.get_node("screenTap").play()
	load_room(room_scenes["CamLH"])
	room_label.text = "LEFT HALLWAY"

func _on_cam_bc_pressed() -> void:
	SoundEffects.get_node("screenTap").play()
	load_room(room_scenes["CamBC"])
	room_label.text = "BALL CART"

func _on_cam_rl_pressed() -> void:
	SoundEffects.get_node("screenTap").play()
	load_room(room_scenes["CamRL"])
	room_label.text = "RIGHT LOCKERS"

func _on_cam_ll_pressed() -> void:
	SoundEffects.get_node("screenTap").play()
	load_room(room_scenes["CamLL"])
	room_label.text = "LEFT LOCKERS"

func _on_cam_lounge_pressed() -> void:
	SoundEffects.get_node("screenTap").play()
	load_room(room_scenes["CamLounge"])
	room_label.text = "LOUNGE"

func _on_cam_storage_pressed() -> void:
	SoundEffects.get_node("screenTap").play()
	load_room(room_scenes["CamStorage"])
	room_label.text = "STORAGE"

func _on_cam_cafe_pressed() -> void:
	SoundEffects.get_node("screenTap").play()
	load_room(room_scenes["CamCafe"])
	room_label.text = "CAFE"

func _on_cam_closet_pressed() -> void:
	SoundEffects.get_node("screenTap").play()
	load_room(room_scenes["CamCloset"])
	room_label.text = "CLOSET"

func _on_cam_utility_pressed() -> void:
	SoundEffects.get_node("screenTap").play()
	load_room(room_scenes["CamUtility"])
	room_label.text = "UTILITY"

func _on_switch_button_mouse_entered() -> void:
	if camera_locked == true:
		return
		
	if office_active:
		#go back to last room
		if last_room_scene != null:
			load_room(last_room_scene)
			make_camera_map_visible()
			
	else:
		# Go back to office
		load_room(room_scenes["Office"])
		make_camera_map_invisible()
	office_active = !office_active
	

func make_camera_map_invisible():
	SoundEffects.get_node("clickClose").play()
	GameManager.cams_closed.emit()
	#emit_signal("cams_closed")
	button_container.visible = false

func make_camera_map_visible():
	SoundEffects.get_node("clickOpen").play()
	GameManager.cams_opened.emit()
	#emit_signal("")
	button_container.visible = true
