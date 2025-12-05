extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_Text_To_Nothing()
	GameManager.update_rightDoor_status.connect(update_Text_To_Something)
	GameManager.right_flash_used.connect(used_flash)
	visible = false
	pass # Replace with function body.

func update_Text_To_Nothing():
	#Stop Sound for Animatronic Being here
	text = "No one is at your door."
	
var showingFlash = false

func used_flash():
	if showingFlash == false:
		showingFlash = true
		visible = true
		await get_tree().create_timer(2).timeout 
		visible = false
		showingFlash = false
	
func update_Text_To_Something(mascot_name, entered):
	if entered == true:
		#Play Sound for Animatronic Being here
		text = "You see %s at your door!" % mascot_name
	else:
		update_Text_To_Nothing()
