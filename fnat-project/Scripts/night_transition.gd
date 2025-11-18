extends Control

@onready var night_label = $Panel/Night

func _ready() -> void:
	print("Night_Transition: current_night =", GameManager.current_night)

	match GameManager.current_night:
		1:
			night_label.text = "1st Night"			
		2:
			night_label.text = "2nd Night"
		3:
			night_label.text = "3rd Night"
		_:
			night_label.text = str(GameManager.current_night) + "th Night"
			print("We don't know what Night we are in.")

	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file("res://Scenes/SecurityDesk.tscn")
