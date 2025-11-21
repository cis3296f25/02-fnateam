extends Control

var winGame := false

func _ready() -> void:
	if name == "Win":
		winGame = true
		
	if winGame == true:
		print("Play animation of the win")
		await get_tree().create_timer(5).timeout
		print("Transition to next night.")
		var new_night = GameManager.Advance_To_Next_Night()
		if new_night == -1:
			print("No New Night available, will showcase the paycheck.")
			get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
			return
			
		SaveManager.current_night = new_night
		GameManager.Reset_Night()
		SaveManager.save_game()
		get_tree().change_scene_to_file("res://Scenes/Night_Transition.tscn")
	else:
		print("Play Transition for loss.")
		await get_tree().create_timer(5).timeout
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
	pass

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _on_exit_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
