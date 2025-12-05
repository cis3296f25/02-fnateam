extends Control

var room_sealed = false;

func _ready() -> void:
	position = Vector2(510, 120) 
	restore_button_state()
	
func _process(_delta: float) -> void:
	pass
			
func get_current_room_name() -> String:
	return get_parent().get_name()  

func _on_check_button_toggled(toggled_on: bool) -> void:
	var current_room_name = get_current_room_name()
	if toggled_on == true:
		room_sealed = true
		GameManager.seal_room_doors(current_room_name, true)
		print("Room %s is sealed" % current_room_name)
	else:
		room_sealed = false
		GameManager.seal_room_doors(current_room_name, false)
		print("Room %s is unsealed" % current_room_name)
	

func restore_button_state():
	var current_room_name = get_current_room_name()
	var button = $CheckButton  
	var sealed_state = GameManager.get_room_seal_state(current_room_name)
	button.set_pressed_no_signal(sealed_state) # Changed this from just pressing the button, so it wouldn't add power.
	room_sealed = sealed_state
		
