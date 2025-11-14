extends Node
var counter = 0


var Flash = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Flash:
		scareAway()
	pass



		
func scareAway() -> void:
	var mascots := ["Phang", "Phillie Phanatic", "Hooters", "Gritty"]
	
	for i in range(4):
		if GameManager.animatronics_locations[mascots[i]] == "LeftHall" && Flash || GameManager.animatronics_locations[mascots[i]] == "RightHall" && Flash:
			GameManager.animatronic_flashed.emit(mascots[i])
		


func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		Flash = true
		print("Flashlight on")
	else:
		Flash = false
		print("Flashlight off")
