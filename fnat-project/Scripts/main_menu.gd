extends Control

func _ready() -> void:
	$Container/Continue.disabled = not SaveManager.has_save
	print("Main menu ready. has_save =", SaveManager.has_save)


# ------------------------
# Start Game
# ------------------------
func _on_start_pressed() -> void:
	print(">>> Start pressed")

	GameManager.current_night = 1
	SaveManager.current_night = 1
	SaveManager.save_game()

	get_tree().change_scene_to_file("res://Scenes/Night_Transition.tscn")


# ------------------------
# Continue Game
# ------------------------
func _on_Continue_pressed() -> void:
	print(">>> Continue pressed")

	SaveManager.load_game()
	GameManager.current_night = SaveManager.current_night

	get_tree().change_scene_to_file("res://Scenes/Night_Transition.tscn")


# ------------------------
# Options
# ------------------------
func _on_Options_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Options.tscn")


# ------------------------
# Exit Game
# ------------------------
func _on_Exit_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()



# ------------------------
func _on_reset_pressed() -> void:
	print(">>> Reset pressed")
	$Panel/ResetDialog.popup_centered()


# ------------------------
# Reset Dialog Confirmed
# ------------------------
func _on_reset_dialog_confirmed() -> void:
	print(">>> Reset Confirmed")

	SaveManager.reset_save()
	GameManager.current_night = 1

	$Container/Continue.disabled = true

	print("All save data cleared.")
