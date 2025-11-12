extends Node2D

const TuAlert_DataBase = preload("res://Scripts/TuAlert_DataBase.gd")
const TUAlertScene = preload("res://Scenes/TUalert.tscn")

signal animatronic_started(mascot_name, room_name)
signal animatronic_moved(mascot_name, old_room_name, new_room_name)
signal loaded_new_cam(current_cam_node, cam_name)
signal troll_message_triggered(message)
signal aggression_boost_started()
signal aggression_boost_ended()

var animatronics_locations = {}
var aggression_multiplier: float = 1.0
var troll_timer: Timer
var aggression_timer: Timer
var tu_alert_instance: Node = null

func _ready() -> void:
	randomize()

	animatronic_started.connect(_animatronic_started_handler)
	animatronic_moved.connect(_animatronic_moved_handler)
	loaded_new_cam.connect(_handle_new_cam)
	troll_message_triggered.connect(_display_troll_message)

	# Instance the TUalert scene once
	tu_alert_instance = TUAlertScene.instantiate()
	add_child(tu_alert_instance)

	_setup_troll_system()


# ===== Troll System =====
func _setup_troll_system():
	troll_timer = Timer.new()
	troll_timer.name = "TrollTimer"
	troll_timer.one_shot = false
	troll_timer.timeout.connect(_trigger_troll_message)
	add_child(troll_timer)
	_restart_troll_timer()

	aggression_timer = Timer.new()
	aggression_timer.name = "AggressionTimer"
	aggression_timer.one_shot = true
	aggression_timer.wait_time = 30.0
	aggression_timer.timeout.connect(_end_aggression_boost)
	add_child(aggression_timer)

func _restart_troll_timer():
	var random_interval = randf_range(45.0, 120.0)
	troll_timer.wait_time = random_interval
	troll_timer.start()

func _trigger_troll_message():
	var message_ids = TuAlert_DataBase.get_all_ids()
	var random_id = message_ids[randi() % message_ids.size()]
	var message_data = TuAlert_DataBase.get_message_data(random_id)
	var random_message = message_data["Text"]
	var message_category = message_data["Category"]

	emit_signal("troll_message_triggered", random_message)
	print("TROLL MESSAGE:", random_message)
	print("Category:", message_category)

	# Boost aggression temporarily
	aggression_multiplier = 2.0

	match message_category:
		"Security":
			_send_aggression_to_animatronics(["Hooters"])
			print("Hooters responding to security alert.")
		"Mascot":
			_send_aggression_to_animatronics(["Gritty", "PhilliePhanatic"])
			print("Gritty and PhilliePhanatic responding to mascot alert.")
		"Utility":
			_send_aggression_to_animatronics(["Phang"])
			print("Phang responding to utility alert.")
		"Safety":
			_send_aggression_to_animatronics(["Phang", "Gritty", "PhilliePhanatic", "Hooters"])
			print("All animatronics responding to safety alert.")

	aggression_timer.start()
	_restart_troll_timer()


# ===== Display Troll Message =====
func _display_troll_message(message: String) -> void:
	if tu_alert_instance and tu_alert_instance.has_method("show_message"):
		tu_alert_instance.show_message(message)
	else:
		push_warning("⚠ TuAlert scene missing or 'show_message' method not found!")


# ===== Aggression Control =====
func _send_aggression_to_animatronics(animatronic_names: Array):
	for name in animatronic_names:
		var animatronic = get_node_or_null(name)
		if animatronic and animatronic.has_signal("aggression_boost_started"):
			animatronic.emit_signal("aggression_boost_started")
			print(name, "received aggression boost!")
		else:
			push_warning("⚠ Animatronic not found or missing signal:", name)

func _end_aggression_boost():
	aggression_multiplier = 1.0
	emit_signal("aggression_boost_ended")
	print("False alarm. Return to your normal activity.")

func get_aggression_multiplier() -> float:
	return aggression_multiplier


# ===== Animatronic & Camera Management =====
func _animatronic_started_handler(mascot_name, room_name):
	animatronics_locations[mascot_name] = room_name
	print(mascot_name, "starting in:", room_name)

func _animatronic_moved_handler(mascot_name, old_room_name, new_room_name):
	animatronics_locations[mascot_name] = new_room_name
	print(mascot_name, " moved from %s → %s" % [old_room_name, new_room_name])

func _handle_new_cam(current_cam_node, cam_name):
	var mascots_to_show = []

	for mascot in animatronics_locations:
		if animatronics_locations[mascot] == cam_name:
			mascots_to_show.append(mascot)
			print(mascot, "should display in Cam:", cam_name)

	var mascot_container = current_cam_node.get_node_or_null("Mascot_Container")
	if mascot_container == null:
		mascot_container = Container.new()
		mascot_container.name = "Mascot_Container"
		current_cam_node.add_child(mascot_container)

	for mascot_child in mascot_container.get_children():
		mascot_child.queue_free()

	var current_child = 0


	for mascot in mascots_to_show:
		var new_mascot_label = Label.new()
		new_mascot_label.name = mascot
		new_mascot_label.text = mascot + " is here!"
		new_mascot_label.set_position(Vector2(0, 20 * current_child))
		mascot_container.add_child(new_mascot_label)
		current_child += 1


# ===== Process =====
func _process(delta: float) -> void:
	pass
