extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_Text_To_Nothing()
	GameManager.update_rightDoor_status.connect(update_Text_To_Something)
	pass # Replace with function body.

func update_Text_To_Nothing():
	text = "No one is at your door."
	
func update_Text_To_Something(mascot_name, entered):
	if entered == true:
		text = "You see %s at your door!" % mascot_name
	else:
		update_Text_To_Nothing()
