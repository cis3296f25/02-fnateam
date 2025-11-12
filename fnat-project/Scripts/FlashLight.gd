extends Node
var counter = 0


var Flash = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		Flash = true
		print("Flashlight on")
	else:
		Flash = false
		print("Flashlight off")
		
func _on_button_pressed() -> void:
	if counter % 2 == 0:
		_on_button_toggled(1)
		scareAway()
	else:
		_on_button_toggled(0)
	counter += 1
	pass # Replace with function body.

func scareAway() -> void:
	var mascots := ["Phang", "Phillies Fnatic", "Hooter", "Gritty"]
	
	for i in range(4):
		if GameManager.animatronics_locations[mascots[i]] == "LeftHall" && Flash || GameManager.animatronics_locations[mascots[i]] == "RightHall" && Flash:
			GameManager.animatronic_flashed.emit(mascots[i])
		
