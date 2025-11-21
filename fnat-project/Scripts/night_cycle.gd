extends Node
signal hour_changed(hour_index:int, text:String)

@export var seconds_per_hour: float = 40.0
@export var total_hours: int = 6
@export var auto_start: bool = true
@export var start_paused: bool = false

@onready var clock_label: Label = %NightClockLabel
@onready var night_label: Label = %NightIndicator

var _running := false
var _paused := false
var _hour_index := 0
var _elapsed := 0.0

func _ready() -> void:
	add_to_group("NightCycle")  # <<< IMPORTANT
	if clock_label == null:
		clock_label = get_node_or_null("NightClockLabel")
	if clock_label == null:
		push_error("NightClockLabel not found.")
		return
	_update_label()
	_update_night()
	_running = auto_start
	_paused = start_paused

func _process(delta: float) -> void:
	if not _running or _paused:
		return
	_elapsed += delta
	if _elapsed >= seconds_per_hour:
		_elapsed -= seconds_per_hour
		_hour_index += 1
		if _hour_index < total_hours:
			_update_label()
			hour_changed.emit(_hour_index, _format_hour_text(_hour_index))
		else:
			_show_6am_and_finish()

func _show_6am_and_finish() -> void:
	if clock_label:
		clock_label.text = "6 AM"
	_running = false
	get_tree().change_scene_to_file("res://Scenes/Win.tscn")

func _format_hour_text(i:int) -> String:
	return "12 AM" if i == 0 else str(i) + " AM"

func _update_label() -> void:
	if clock_label:
		clock_label.text = _format_hour_text(_hour_index)
		
func _update_night() -> void:
	if night_label:
		night_label.text = "Night " + str(GameManager.current_night)

func start(): _running = true; _paused = false
func pause_cycle(): _paused = true
func resume_cycle(): _paused = false
func reset_to_midnight():
	_hour_index = 0; _elapsed = 0; _running = false; _paused = false; _update_label()
