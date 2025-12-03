extends Node2D

signal animatronic_started(mascot_name, room_name)
signal animatronic_moved(mascot_name, old_room_name, new_room_name)
signal loaded_new_cam(current_cam_node, cam_name)

var current_night := 5
var nights_beaten := {}

var ai_levels: Array[int] = [0, 0, 0, 0, 0]

func set_ai_level(index: int, level: int) -> void:
	if index < 0 or index >= ai_levels.size():
		return
	ai_levels[index] = clamp(level, 0, 20)

func get_ai_level(index: int) -> int:
	if index < 0 or index >= ai_levels.size():
		return 0
	return ai_levels[index]

func night_from_level(level: int) -> int:
	if level <= 4:
		return 1
	elif level <= 8:
		return 2
	elif level <= 12:
		return 3
	elif level <= 16:
		return 4
	else:
		return 5


signal hooters_boost_started
signal gritty_boost_started
signal phillie_boost_started
signal phang_boost_started
signal franklin_boost_started
signal phanatic_boost_started

signal hooters_boost_ended
signal gritty_boost_ended
signal phillie_boost_ended
signal phang_boost_ended
signal franklin_boost_ended
signal phanatic_boost_ended

signal cams_opened
signal cams_closed

signal power_ran_out
signal power_back

signal impact_power(amount)
var has_power := true

signal update_vent_status
signal update_rightDoor_status
signal update_leftDoor_status

var animatronics_locations := {}
signal animatronic_flashed(mascot_name)
var list_of_flashed_animatronics := {}

var shared_room_database = null
var night_database = null

signal room_sealed(room_name, is_sealed)
var room_seal_states := {}


signal hooters_setAI(start, TwoAMInc, ThreeAMInc, FourAMInc)
signal gritty_setAI(start, TwoAMInc, ThreeAMInc, FourAMInc)
signal phillie_setAI(start, TwoAMInc, ThreeAMInc, FourAMInc)
signal phang_setAI(start, TwoAMInc, ThreeAMInc, FourAMInc)

var current_hour := 0
var night_cycle_connected := false


func _ready() -> void:
	var db_scene = preload("res://Scenes/Room_Database.tscn")
	shared_room_database = db_scene.instantiate()
	add_child(shared_room_database)

	var night_db_scene = preload("res://Scenes/Night_Database.tscn")
	night_database = night_db_scene.instantiate()
	add_child(night_database)

	randomize()

	animatronic_started.connect(_animatronic_started_handler)
	animatronic_moved.connect(_animatronic_moved_handler)
	loaded_new_cam.connect(_handle_new_cam)
	power_ran_out.connect(power_outage_handler)
	power_back.connect(power_back_handler)
	animatronic_flashed.connect(_animatronic_flashed_handler)

	print("GameManager initialized.")

func Reset_Night() -> void:
	room_seal_states = {}
	animatronics_locations = {}
	has_power = true
	current_hour = 0
	list_of_flashed_animatronics = {}
	
func Advance_To_Next_Night() -> int:
	if current_night < 5:
		current_night += 1
		return current_night
		
	return -1 # -1 Means that it could not return a night and therefore will send back to main menu.
	

func _process(_delta: float) -> void:
	if not night_cycle_connected:
		var night_cycle = get_tree().get_first_node_in_group("NightCycle")
		if night_cycle:
			night_cycle.hour_changed.connect(_on_hour_changed)
			night_cycle_connected = true
			print("NightCycle connected.")


func _on_hour_changed(hour_index: int, _txt: String) -> void:
	current_hour = hour_index


func get_in_game_hour() -> int:
	return current_hour


func get_AI_for_hour(ai_key: String, hour: int) -> int:
	var night_info = night_database.Night.get(current_night, null)
	if night_info == null:
		return 0

	match hour:
		2:
			return int(night_info.get(ai_key + "AI_2AMIncr", 0))
		3:
			return int(night_info.get(ai_key + "AI_3AMIncr", 0))
		4:
			return int(night_info.get(ai_key + "AI_4AMIncr", 0))
		_:
			return 0


func set_night_start_AI(ai_key: String) -> int:
	var night_info = night_database.Night.get(current_night, null)
	if night_info == null:
		return 0
	return int(night_info.get(ai_key + "AI_Start", 0))
	
func custom_night_update_AI(ai_key: String, newAI_Level : int) -> void:
	var night_info = night_database.Night.get(8, null) #GOES TO THE CUSTOM NIGHT MODE.
	if night_info[ai_key + "AI_Start"] != null:
		night_info[ai_key + "AI_Start"] = newAI_Level
	


func seal_room_doors(room_name: String, is_sealed: bool) -> void:
	room_seal_states[room_name] = is_sealed
	room_sealed.emit(room_name, is_sealed)

	var rooms = shared_room_database.rooms
	for room_id in rooms:
		if rooms[room_id]["Name"] == room_name:
			rooms[room_id]["SealedDoor"] = is_sealed


func get_room_seal_state(room_name: String) -> bool:
	return room_seal_states.get(room_name, false)


func power_back_handler() -> void:
	has_power = true


func power_outage_handler() -> void:
	has_power = false
	var rooms = shared_room_database.rooms
	for room_id in rooms:
		var room_name = rooms[room_id]["Name"]
		var room_seal_state = get_room_seal_state(room_name)
		if room_seal_state:
			rooms[room_id]["SealedDoor"] = false
			room_seal_states[room_name] = false
			room_sealed.emit(room_name, false)


func _animatronic_started_handler(mascot_name, room_name) -> void:
	animatronics_locations[mascot_name] = room_name
	print(mascot_name, " starting in:", room_name)


func _animatronic_moved_handler(mascot_name, old_room_name, new_room_name) -> void:
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


func _handle_new_cam(current_cam_node, cam_name: String) -> void:
	var mascots_to_show: Array = []
	for mascot in animatronics_locations:
		if animatronics_locations[mascot] == cam_name:
			mascots_to_show.append(mascot)

	var mascot_container = current_cam_node.get_node_or_null("Mascot_Container")
	if mascot_container == null:
		mascot_container = Container.new()
		mascot_container.name = "Mascot_Container"
		current_cam_node.add_child(mascot_container)

	for child in mascot_container.get_children():
		child.queue_free()

	var i := 0
	for mascot in mascots_to_show:
		var label := Label.new()
		label.name = mascot
		label.text = mascot + " is here!"
		label.position = Vector2(0, 20 * i)
		mascot_container.add_child(label)
		i += 1


func _animatronic_flashed_handler(mascot_name: String) -> void:
	list_of_flashed_animatronics[mascot_name] = true
	print(mascot_name + " was flashed")


func _notification(what: int) -> void:
	if what == NOTIFICATION_READY:
		call_deferred("_connect_night_cycle")


func _connect_night_cycle() -> void:
	if night_cycle_connected:
		return
	var night_cycle = get_tree().get_first_node_in_group("NightCycle")
	if night_cycle:
		night_cycle.hour_changed.connect(_on_hour_changed)
		night_cycle_connected = true
		print("NightCycle connected via _connect_night_cycle()")
