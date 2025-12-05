extends Label

var showingFlash = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_Text_To_Nothing()
	GameManager.update_leftDoor_status.connect(update_Text_To_Something)
	GameManager.left_flash_used.connect(used_flash)
	visible = false
	pass # Replace with function body.

func update_Text_To_Nothing():
	#Stop Sound for Animatronic Being here
	text = "No one is at your door."


func used_flash(missed):
	if showingFlash == false:
		showingFlash = true
		visible = true
		if missed == false:
			text = "Something Moved Away!"
		await get_tree().create_timer(2).timeout 
		visible = false
		showingFlash = false
	
	
func update_Text_To_Something(mascot_name, entered):
	if entered == true:
		SoundEffects.get_node("LeftDoor").play()
		text = "You see %s at your door!" % mascot_name
	else:
		update_Text_To_Nothing()
