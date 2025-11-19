extends Node2D

signal animatronic_started(mascot_name, room_name)
signal animatronic_moved(mascot_name, old_room_name, new_room_name)
signal loaded_new_cam(current_cam_node, cam_name)

signal hooters_boost_started
signal gritty_boost_started
signal phillie_boost_started
signal phang_boost_started
signal franklin_boost_started

signal hooters_boost_ended
signal gritty_boost_ended
signal phillie_boost_ended
signal phang_boost_ended
signal franklin_boost_ended

signal cams_opened
signal cams_closed

signal power_ran_out
signal power_back

signal update_vent_status
signal update_rightDoor_status
signal update_leftDoor_status

var animatronics_locations = {}

signal animatronic_flashed(mascot_name)

var list_of_flashed_animatronics = {}
# Called when the node enters the scene tree for the first time.


var shared_room_database = null
signal room_sealed(room_name, is_sealed)
var room_seal_states = {}

func _ready() -> void:
	var db_scene = preload("res://Scenes/Room_Database.tscn")
	shared_room_database = db_scene.instantiate()
	add_child(shared_room_database)
	
	randomize()

	animatronic_started.connect(_animatronic_started_handler)
	animatronic_moved.connect(_animatronic_moved_handler)
	loaded_new_cam.connect(_handle_new_cam)
#	troll_message_triggered.connect(_display_troll_message)
	power_ran_out.connect(power_outage_handler)
	animatronic_flashed.connect(_animatronic_flashed_handler)

#	tu_alert_instance = TUAlertScene.instantiate()
#	add_child(tu_alert_instance)

#	_timer_manager = TimerManagerScene.instantiate()
#	add_child(_timer_manager)

#	_timer_manager.troll_timeout.connect(_trigger_troll_message)
#	_timer_manager.aggression_timeout.connect(_end_aggression_boost)
	
	

	print("GameManager initialized.")
	
func seal_room_doors(room_name: String, is_sealed: bool):
	room_seal_states[room_name] = is_sealed
	room_sealed.emit(room_name, is_sealed)
	
	var rooms = shared_room_database.rooms
	for room_id in rooms:
		if rooms[room_id]["Name"] == room_name:
			rooms[room_id]["SealedDoor"] = is_sealed
			
func get_room_seal_state(room_name: String) -> bool:
	return room_seal_states.get(room_name, false)

func power_outage_handler() -> void:
	var rooms = shared_room_database.rooms
	for room_id in rooms:
		var room_name = rooms[room_id]["Name"]
		var room_seal_state = get_room_seal_state(room_name)
		if room_seal_state == null:
			continue
			
		if room_seal_state == true:
			rooms[room_id]["SealedDoor"] = false
			room_seal_states[room_name] = false
			room_sealed.emit(room_name, false)

func _animatronic_started_handler(mascot_name, room_name):
	animatronics_locations[mascot_name] = room_name
	print(mascot_name, " starting in:", room_name)

func _animatronic_moved_handler(mascot_name, old_room_name, new_room_name):
	animatronics_locations[mascot_name] = new_room_name
	print(mascot_name, " moved from %s → %s" % [old_room_name, new_room_name])
	if new_room_name == "Vent Section 3":
		update_vent_status.emit(mascot_name, true)
	elif new_room_name == "RightOfficeDoor":
		update_rightDoor_status.emit(mascot_name, true)
	elif new_room_name == "LeftOfficeDoor":
		update_leftDoor_status.emit(mascot_name, true)
		
	if old_room_name == "Vent Section 3":
		update_vent_status.emit(mascot_name, false)
	elif old_room_name == "RightOfficeDoor":
		update_rightDoor_status.emit(mascot_name, false)
	elif old_room_name == "LeftOfficeDoor":
		update_leftDoor_status.emit(mascot_name, false)


func _handle_new_cam(current_cam_node, cam_name):
	var mascots_to_show = []
	for mascot in animatronics_locations:
		if animatronics_locations[mascot] == cam_name:
			mascots_to_show.append(mascot)
			print(mascot, " visible in Cam:", cam_name)

	var mascot_container = current_cam_node.get_node_or_null("Mascot_Container")
	if mascot_container == null:
		mascot_container = Container.new()
		mascot_container.name = "Mascot_Container"
		current_cam_node.add_child(mascot_container)

	for child in mascot_container.get_children():
		child.queue_free()

	var i = 0
	for mascot in mascots_to_show:
		var label = Label.new()
		label.name = mascot
		label.text = mascot + " is here!"
		label.position = Vector2(0, 20 * i)
		mascot_container.add_child(label)
		i += 1
	
	#print(current_cam_node)
func _animatronic_flashed_handler(mascot_name):
	list_of_flashed_animatronics[mascot_name] = true
	
	print(mascot_name + " was flashed")


func _process(_delta):
	pass
