extends Control

func _on_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(0,linear_to_db(value))
