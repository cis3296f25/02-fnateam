extends Control

func _on_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(0,linear_to_db(value))



func _on_mute_check_box_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0,toggled_on)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
