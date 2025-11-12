extends Control

func _on_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(0,linear_to_db(value))



func _on_mute_check_box_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0,toggled_on)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


@onready var previous_window = DisplayServer.window_get_mode()
@onready var current_window = DisplayServer.window_get_mode()
func _on_fullscreen_toggle_pressed() -> void:
	current_window = DisplayServer.window_get_mode()
	if current_window != 4:
		previous_window = current_window
		DisplayServer.window_set_mode(4)
	else:
		if previous_window == 4:
			previous_window = 2
		DisplayServer.window_set_mode(previous_window)
