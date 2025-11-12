extends Node2D

const TuAlert_DataBase = preload("res://Scripts/TuAlert_DataBase.gd")
const TUAlertScene = preload("res://Scenes/TUalert.tscn")

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
var troll_timer: Timer
var aggression_timer: Timer
var tu_alert_instance: Node = null


signal animatronic_flashed(mascot_name)

var list_of_flashed_animatronics = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()

	
	animatronic_started.connect(_animatronic_started_handler)
	animatronic_moved.connect(_animatronic_moved_handler)
	loaded_new_cam.connect(_handle_new_cam)
	troll_message_triggered.connect(_display_troll_message)


	tu_alert_instance = TUAlertScene.instantiate()
	add_child(tu_alert_instance)


	_setup_troll_system()

	print("GameManager ready — animatronic system initialized.")


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
	print("📱 Next troll message in %.1f seconds" % random_interval)


func _trigger_troll_message():
	var message_ids = TuAlert_DataBase.get_all_ids()
	var random_id = message_ids[randi() % message_ids.size()]
	var message_data = TuAlert_DataBase.get_message_data(random_id)
	var random_message = message_data["Text"]
	var message_category = message_data["Category"]

	emit_signal("troll_message_triggered", random_message)
	_display_troll_message(random_message)

	print("TROLL MESSAGE:", random_message)
	print("Category:", message_category)

	# Trigger animatronic-specific boosts
	match message_category:
		"Security":
			print("Triggering Hooters boost!")
			emit_signal("hooters_boost_started")

		"Mascot":
			print("Triggering Gritty + Phillie boosts!")
			emit_signal("gritty_boost_started")
			emit_signal("phillie_boost_started")

		"Utility":
			print("Triggering Phang boost!")
			emit_signal("phang_boost_started")

		"Safety":
			print("Triggering all animatronic boosts!")
			emit_signal("hooters_boost_started")
			emit_signal("gritty_boost_started")
			emit_signal("phillie_boost_started")
			emit_signal("phang_boost_started")

	# Timer to return aggression to normal
	aggression_timer.start()
	_restart_troll_timer()


# === Display Alert UI ===
func _display_troll_message(message: String) -> void:
	if tu_alert_instance and tu_alert_instance.has_method("show_message"):
		tu_alert_instance.show_message(message)
	else:
		push_warning("TuAlert scene missing or 'show_message' not found!")


func _end_aggression_boost():
	print("Oh wait,False Alert, back to what your doing.")

	emit_signal("hooters_boost_ended")
	emit_signal("gritty_boost_ended")
	emit_signal("phillie_boost_ended")
	emit_signal("phang_boost_ended")

	animatronic_flashed.connect(_animatronic_flashed_handler)

func _animatronic_started_handler(mascot_name, room_name):
	animatronics_locations[mascot_name] = room_name
	print(mascot_name, " starting in:", room_name)

func _animatronic_moved_handler(mascot_name, old_room_name, new_room_name):
	animatronics_locations[mascot_name] = new_room_name
	print(mascot_name, " moved from %s → %s" % [old_room_name, new_room_name])


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
	print(mascot_name + "was flashed")

func _process(_delta):
	pass
