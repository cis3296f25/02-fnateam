extends Control

func _ready() -> void:
	$Container/Continue.disabled = not SaveManager.has_save
	print("Main menu ready. has_save =", SaveManager.has_save)


func _on_start_pressed() -> void:
	print(">>> Start pressed")
  SoundEffects.get_node("computerMouseClick").play()

	GameManager.current_night = 1
	SaveManager.current_night = 1
	GameManager.Reset_Night()
	SaveManager.save_game()
	
	if GameManager.current_night == 1:
		get_tree().change_scene_to_file("res://Scenes/Newspaper.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/Night_Transition.tscn")

func _on_Continue_pressed() -> void:
	print(">>> Continue pressed")
  SoundEffects.get_node("computerMouseClick").play()

	SaveManager.load_game()
	GameManager.current_night = SaveManager.current_night
	GameManager.Reset_Night()
	get_tree().change_scene_to_file("res://Scenes/Night_Transition.tscn")


func _on_Options_pressed() -> void:
  SoundEffects.get_node("computerMouseClick").play()
	get_tree().change_scene_to_file("res://Scenes/Options.tscn")


func _on_Exit_pressed() -> void:
  SoundEffects.get_node("computerMouseClick").play()
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
