extends Control


func _on_start_pressed() -> void:
	SoundEffects.get_node("computerMouseClick").play()
	get_tree().change_scene_to_file("res://Scenes/SecurityDesk.tscn")
	
	
func _on_options_pressed() -> void:
	SoundEffects.get_node("computerMouseClick").play()
	get_tree().change_scene_to_file("res://Scenes/Options.tscn")


func _on_exit_pressed() -> void:
	SoundEffects.get_node("computerMouseClick").play()
	# notification alerts all other nodes of the program termination
	# we can use this to save game before closing
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
