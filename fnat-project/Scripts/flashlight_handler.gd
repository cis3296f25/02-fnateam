extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_left_button_pressed() -> void:
	var mascots := ["Phillie Phanatic", "Hooters"]
	var missed = true
	for i in range(2):
		if GameManager.animatronics_locations[mascots[i]] == "LeftOfficeDoor" :
			missed = false
			GameManager.animatronic_flashed.emit(mascots[i])
			
	if missed == true:
		print("Missed Target.")
	pass # Replace with function body.


func _on_middle_button_pressed() -> void:
	var mascots := ["Phang"]
	var missed = true
	for i in range(1):
		if GameManager.animatronics_locations[mascots[i]] == "Vent Section 3"  :
			missed = false
			GameManager.animatronic_flashed.emit(mascots[i])
			
	if missed == true:
		print("Missed Target.")
	pass # Replace with function body.


func _on_right_button_pressed() -> void:
	var mascots := ["Hooters", "Gritty"]
	var missed = true
	for i in range(2):
		if GameManager.animatronics_locations[mascots[i]] == "RightOfficeDoor" :
			missed = false
			GameManager.animatronic_flashed.emit(mascots[i])
			
	if missed == true:
		print("Missed Target.")
	pass # Replace with function body.
