extends Node2D

@export var room_database_scene: PackedScene
@export var move_interval: float = 4.98

var room_database: Dictionary
var current_room_id = 14

@onready var move_timer: Timer = $Timer
@onready var stage_timer_n1: Timer = $stage_time1
@onready var stage_timer_n2: Timer = $stage_time2
@onready var stage_timer_n3: Timer = $stage_time3
@onready var stage_timer_n4: Timer = $stage_time4
@onready var stage_timer_n5: Timer = $stage_time5

var active_stage_timer: Timer

@onready var Jumpscare: CanvasLayer = $Jumpscare
@onready var JumpScare_Image = Jumpscare.get_node("JumpImage")

@export var ai_level: int = 0
var animatronic_name = "Franklin"

var aggression_multiplier: float = 1.0
var is_aggressive: bool = false

var stage: int = 1
var last_hour_applied: int = 0

var stun_time := 0
var looking_at_franklin := false

func _ready() -> void:
	randomize()
	JumpScare_Image.visible = false
	room_database = GameManager.shared_room_database.rooms

	GameManager.animatronic_started.emit(animatronic_name, room_database[current_room_id]["Name"])
	GameManager.animatronic_flashed.connect(handle_flashed)
	GameManager.loaded_new_cam.connect(_on_cam_loaded)
	GameManager.cams_closed.connect(_on_cams_closed)

	move_timer.wait_time = move_interval
	move_timer.timeout.connect(_action)
	move_timer.start()

	GameManager.franklin_boost_started.connect(_on_aggression_boost_started)
	GameManager.franklin_boost_ended.connect(_on_aggression_boost_ended)

	ai_level = GameManager.set_night_start_AI("Franklin")
	_select_stage_timer()
	_update_stage_timer_state()
	_setup_stage_timer()

func _select_stage_timer():
	var n = GameManager.current_night
	if n == 1:
		active_stage_timer = stage_timer_n1
	elif n == 2:
		active_stage_timer = stage_timer_n2
	elif n == 3:
		active_stage_timer = stage_timer_n3
	elif n == 4:
		active_stage_timer = stage_timer_n4
	else:
		active_stage_timer = stage_timer_n5

func _setup_stage_timer():
#	stage_timer.one_shot = false
	#stage_timer.timeout.connect(_on_stage_tick)
	_update_stage_timer_state()

func apply_hourly_increments():
	var hour = GameManager.get_in_game_hour()
	if hour <= last_hour_applied:
		return
	for h in range(last_hour_applied + 1, hour + 1):
		var add = GameManager.get_AI_for_hour("Franklin", h)
		if add != 0:
			ai_level += add
	last_hour_applied = hour
	_update_stage_timer_state()

func _update_stage_timer_state():
	if ai_level >= 1:
		if active_stage_timer.is_stopped():
			active_stage_timer.start()
	else:
		if not active_stage_timer.is_stopped():
			active_stage_timer.stop()

func _on_stage_tick():
	if looking_at_franklin:
		return
	if stage >= 5:
		return
	stage += 1
	ai_level += 1
	print("%s advanced to STAGE %d → AI %d" % [animatronic_name, stage, ai_level])

	match stage:
		2:
			_get_up()
		3:
			_run_to_hall()
		4:
			_run_to_office_door()
		5: 
			trigger_attack()

	_update_stage_timer_state()

func _get_up():
	var target = "Gym"
	
	var door_id = _get_room_id_by_name(target)
	if door_id == -1:
		return

	var current_room = room_database[current_room_id]
	var next_room = room_database[door_id]

	GameManager.animatronic_moved.emit(
		animatronic_name,
		current_room["Name"],
		next_room["Name"]
	)

	current_room["Empty"] = true
	next_room["Empty"] = false
	current_room_id = door_id

	print("%s rushed to %s (Stage 2 trigger)" % [animatronic_name, target])
	
func _run_to_hall():
	var target = ""
	if randf() < 0.5:
		target = "LeftHall"
	else:
		target = "RightHall"

	var door_id = _get_room_id_by_name(target)
	if door_id == -1:
		return

	var current_room = room_database[current_room_id]
	var gym_id = _get_room_id_by_name("Gym")
	var gym_room = room_database[gym_id]
	var next_room = room_database[door_id]
	if gym_room["SealedDoor"] == true or current_room["SealedDoor"] == true:
		stage = 1
		ai_level = GameManager.set_night_start_AI("Franklin")
		_update_stage_timer_state()

		var ballcart_id = _get_room_id_by_name("BallCart")

		next_room = room_database[ballcart_id]

		GameManager.animatronic_moved.emit(
			animatronic_name,
			current_room["Name"],
			next_room["Name"]
		)

		current_room["Empty"] = true
		next_room["Empty"] = false
		current_room_id = ballcart_id
		stun_time = 5
		print("%s HIT A DOOR → returned to BallCart." % animatronic_name)
		return
	
	GameManager.animatronic_moved.emit(
		animatronic_name,
		current_room["Name"],
		next_room["Name"]
	)

	current_room["Empty"] = true
	next_room["Empty"] = false
	current_room_id = door_id

	print("%s rushed to %s (Stage 3 trigger)" % [animatronic_name, target])


func _run_to_office_door():
	var target = "LeftOfficeDoor" if randf() < 0.5 else "RightOfficeDoor"
	var door_id = _get_room_id_by_name(target)
	if door_id == -1:
		return
	var current_room = room_database[current_room_id]
	var next_room = room_database[door_id]
	GameManager.animatronic_moved.emit(animatronic_name, current_room["Name"], next_room["Name"])
	current_room["Empty"] = true
	next_room["Empty"] = false
	current_room_id = door_id

func _on_aggression_boost_started():
	if not is_aggressive:
		is_aggressive = true
		aggression_multiplier = 2.0
		print("%s is now AGGRESSIVE!" % animatronic_name)

func _on_aggression_boost_ended():
	if is_aggressive:
		is_aggressive = false
		aggression_multiplier = 1.0
		print("%s calmed down." % animatronic_name)

func _action() -> void:
	apply_hourly_increments()

	var roll = randi() % 20 + 1
	var effective_ai = int(ai_level * aggression_multiplier)
	
	if stun_time > 0:
		stun_time -= 1
		print("Franklin is stunned!")
		return
	
	if roll < effective_ai:
		_on_stage_tick()
		print("%s moved! Roll %d < AI %d" %
			[animatronic_name, roll, effective_ai])


func move_to_next_room():
	var current_room = room_database[current_room_id]
	var adjacent_rooms = current_room["AdjacentRooms"].duplicate()

	var room_weights = {
		"Office": 4.0,
		"LeftHall": 3.0,
		"RightHall": 3.0,
		"Gym": 2.5,
		"RightOfficeDoor": 3.5,
		"LeftOfficeDoor": 3.5
	}

	var valid = []
	for id in adjacent_rooms:
		var next_room = room_database[id]
		if next_room["SealedDoor"]:
			continue
		if next_room["Name"] in ["Vent Section 1","Vent Section 2","Vent Section 3","Cafe","LeftOfficeDoor"]:
			continue
		valid.append(id)

	if valid.is_empty():
		return

	var weighted = []
	for id in valid:
		var w = room_weights.get(room_database[id]["Name"], 1.0)
		for i in range(int(w * 10)):
			weighted.append(id)

	var next_id = weighted[randi() % weighted.size()]
	var next_room = room_database[next_id]

	GameManager.animatronic_moved.emit(animatronic_name, current_room["Name"], next_room["Name"])
	current_room["Empty"] = true
	next_room["Empty"] = false
	current_room_id = next_id

	if next_room["Name"] == "Office":
		trigger_attack()

func handle_flashed(mascot_name) -> void:
	if mascot_name != animatronic_name:
		return
	stage = 1
	ai_level = GameManager.set_night_start_AI("Franklin")
	_update_stage_timer_state()

	var reset_id = _get_room_id_by_name("BallCart")
	var current_room = room_database[current_room_id]
	var next_room = room_database[reset_id]

	GameManager.animatronic_moved.emit(animatronic_name, current_room["Name"], next_room["Name"])
	current_room["Empty"] = true
	next_room["Empty"] = false
	current_room_id = reset_id

func _get_room_id_by_name(room_name: String) -> int:
	for id in room_database:
		if room_database[id]["Name"] == room_name:
			return id
	return -1

func _on_cam_loaded(cam_node, cam_name):
	var franklin_room_name = room_database[current_room_id]["Name"]
	if cam_name == franklin_room_name:
		looking_at_franklin = true
		if not active_stage_timer.is_stopped():
			active_stage_timer.stop()
		active_stage_timer.start()
	else:
		looking_at_franklin = false

func _on_cams_closed():
	looking_at_franklin = false
	_update_stage_timer_state()

func Show_Jumpscare():
	JumpScare_Image.visible = true

func trigger_attack():
	Show_Jumpscare()
	SoundEffects.get_node("jumpscare1").play()
	move_timer.stop()
	active_stage_timer.stop()
	await get_tree().create_timer(0.8).timeout
	get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")
