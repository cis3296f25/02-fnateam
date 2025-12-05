extends Node2D

const TuAlert_DataBase = preload("res://Scripts/TuAlert_DataBase.gd")
const TUAlertScene = preload("res://Scenes/TUalert.tscn")
const TimerManagerScene = preload("res://Scenes/AlertTimer.tscn")

signal troll_message_triggered(message)

var tu_alert_instance: Node = null
@onready var _Troll_Timer: Node = $TrollTimer
@onready var _Aggro_Timer: Node = $AgressionTimer

@export var time_til_next_Troll = 20
@export var length_of_aggro = 10


func _ready() -> void:
	randomize()
	troll_message_triggered.connect(_display_troll_message)

	tu_alert_instance = TUAlertScene.instantiate()
	add_child(tu_alert_instance)

#	_timer_manager = TimerManagerScene.instantiate()
#	add_child(_timer_manager)

#	_timer_manager.troll_timeout.connect(_trigger_troll_message)
	_Troll_Timer.wait_time = time_til_next_Troll
	_Aggro_Timer.wait_time = length_of_aggro
	_Troll_Timer.timeout.connect(_trigger_troll_message)
	_Aggro_Timer.timeout.connect(_end_aggression_boost)
#	_timer_manager.aggression_timeout.connect(_end_aggression_boost)
	print("Alert Timer initialized. Waiting for Start Game input.")
	start_game()


# Called externally when player presses Start
func start_game():
	print("Game started — initializing timers.")
	_Troll_Timer.start()
#	_timer_manager.start_troll_timer()


func _trigger_troll_message():
	var message_ids = TuAlert_DataBase.get_all_ids()
	if message_ids.is_empty():
		push_warning("TuAlert database empty — no messages to show.")
		return

	var random_id = message_ids[randi() % message_ids.size()]
	var message_data = TuAlert_DataBase.get_message_data(random_id)
	var random_message = message_data["Text"]
	var message_category = message_data["Category"]

#	GameManager.troll_message_triggered.emit(random_message)
	_display_troll_message(random_message)

	print("TROLL MESSAGE:", random_message)
	print("Category:", message_category)

	match message_category:
		"Security":
			GameManager.hooters_boost_started.emit()
		"Mascot":
			GameManager.gritty_boost_started.emit()
			GameManager.phillie_boost_started.emit()
		"Utility":
			GameManager.phang_boost_started.emit()
		"Safety":
			GameManager.hooters_boost_started.emit()
			GameManager.gritty_boost_started.emit()
			GameManager.phillie_boost_started.emit()
			GameManager.phang_boost_started.emit()
			GameManager.franklin_boost_started.emit()
	_Troll_Timer.stop()
	_Aggro_Timer.start()
#	_timer_manager.start_aggression_timer()


func _display_troll_message(message: String) -> void:
	if tu_alert_instance and tu_alert_instance.has_method("show_message"):
		tu_alert_instance.show_message(message)
	else:
		push_warning("TuAlert scene missing or 'show_message' method not found.")


func _end_aggression_boost():
	print("False alarm. Returning animatronics to idle state.")
	GameManager.hooters_boost_ended.emit()
	GameManager.gritty_boost_ended.emit()
	GameManager.phillie_boost_ended.emit()
	GameManager.phang_boost_ended.emit()
	_Aggro_Timer.stop()
	_Troll_Timer.start()
	

func _process(_delta):
	pass
