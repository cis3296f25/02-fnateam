extends Control

func _on_start_pressed() -> void:
	# When player starts gane, they will go to the night transition scene,
	#  also we should have a value in GameManager to
	get_tree().change_scene_to_file("res://Scenes/Night_Transition.tscn")

func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Options.tscn")


func _on_exit_pressed() -> void:
	# notification alerts all other nodes of the program termination
	# we can use this to save game before closing
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
