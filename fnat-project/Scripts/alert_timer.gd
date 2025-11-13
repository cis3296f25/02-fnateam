extends Node2D

const TuAlert_DataBase = preload("res://Scripts/TuAlert_DataBase.gd")
const TUAlertScene = preload("res://Scenes/TUalert.tscn")
const TimerManagerScene = preload("res://Scenes/AlertTimer.tscn")

signal animatronic_started(mascot_name, room_name)
signal animatronic_moved(mascot_name, old_room_name, new_room_name)
signal loaded_new_cam(current_cam_node, cam_name)
signal troll_message_triggered(message)

signal hooters_boost_started
signal gritty_boost_started
signal phillie_boost_started
signal phang_boost_started

signal hooters_boost_ended
signal gritty_boost_ended
signal phillie_boost_ended
signal phang_boost_ended

var animatronics_locations = {}
var tu_alert_instance: Node = null
var _timer_manager: Node = null


func _ready() -> void:
	randomize()

	animatronic_started.connect(_animatronic_started_handler)
	animatronic_moved.connect(_animatronic_moved_handler)
	loaded_new_cam.connect(_handle_new_cam)
	troll_message_triggered.connect(_display_troll_message)

	tu_alert_instance = TUAlertScene.instantiate()
	add_child(tu_alert_instance)

	_timer_manager = TimerManagerScene.instantiate()
	add_child(_timer_manager)

	_timer_manager.troll_timeout.connect(_trigger_troll_message)
	_timer_manager.aggression_timeout.connect(_end_aggression_boost)

	print("GameManager initialized. Waiting for Start Game input.")


# Called externally when player presses Start
func start_game():
	print("Game started — initializing timers.")
	_timer_manager.start_troll_timer()


func _trigger_troll_message():
	var message_ids = TuAlert_DataBase.get_all_ids()
	if message_ids.is_empty():
		push_warning("TuAlert database empty — no messages to show.")
		return

	var random_id = message_ids[randi() % message_ids.size()]
	var message_data = TuAlert_DataBase.get_message_data(random_id)
	var random_message = message_data["Text"]
	var message_category = message_data["Category"]

	emit_signal("troll_message_triggered", random_message)
	_display_troll_message(random_message)

	print("TROLL MESSAGE:", random_message)
	print("Category:", message_category)

	match message_category:
		"Security":
			emit_signal("hooters_boost_started")
		"Mascot":
			emit_signal("gritty_boost_started")
			emit_signal("phillie_boost_started")
		"Utility":
			emit_signal("phang_boost_started")
		"Safety":
			emit_signal("hooters_boost_started")
			emit_signal("gritty_boost_started")
			emit_signal("phillie_boost_started")
			emit_signal("phang_boost_started")

	_timer_manager.start_aggression_timer()


func _display_troll_message(message: String) -> void:
	if tu_alert_instance and tu_alert_instance.has_method("show_message"):
		tu_alert_instance.show_message(message)
	else:
		push_warning("TuAlert scene missing or 'show_message' method not found.")


func _end_aggression_boost():
	print("False alarm. Returning animatronics to idle state.")
	emit_signal("hooters_boost_ended")
	emit_signal("gritty_boost_ended")
	emit_signal("phillie_boost_ended")
	emit_signal("phang_boost_ended")


func _animatronic_started_handler(mascot_name, room_name):
	animatronics_locations[mascot_name] = room_name
	print(mascot_name, "starting in:", room_name)

func _animatronic_moved_handler(mascot_name, old_room_name, new_room_name):
	animatronics_locations[mascot_name] = new_room_name
	print(mascot_name, "moved from %s → %s" % [old_room_name, new_room_name])


func _handle_new_cam(current_cam_node, cam_name):
	var mascots_to_show = []
	for mascot in animatronics_locations:
		if animatronics_locations[mascot] == cam_name:
			mascots_to_show.append(mascot)
			print(mascot, "visible in Cam:", cam_name)

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


func _process(_delta):
	pass
