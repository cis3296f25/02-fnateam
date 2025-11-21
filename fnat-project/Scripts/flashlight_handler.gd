extends Node

@export var Flash_Power_Use = 10
@export var Battery_Charges = 12

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func check_for_power() -> bool:
	if GameManager.has_power == true:
		return true
		
	if Battery_Charges > 0:
		return true
	
	return false

func impact_power(amount : int) -> void:
	if GameManager.has_power == true:
		GameManager.impact_power.emit(amount)
	else:
		if Battery_Charges > 0:
			Battery_Charges -= 1
			print("Charges Left: ", Battery_Charges)

func _on_left_button_pressed() -> void:
	if check_for_power() == false:
		return
	SoundEffects.get_node("flashlightOn").play()
	var mascots := ["Phillie Phanatic", "Hooters", "Franklin"]
	var missed = true
	for i in range(3):
		if GameManager.animatronics_locations[mascots[i]] == "LeftOfficeDoor" :
			missed = false
			GameManager.animatronic_flashed.emit(mascots[i])
			
	if missed == true:
		print("Missed Target.")
		
	impact_power(Flash_Power_Use)
	pass # Replace with function body.


func _on_middle_button_pressed() -> void:
	if check_for_power() == false:
		return
	SoundEffects.get_node("flashlightOn").play()
	var mascots := ["Phang"]
	var missed = true
	for i in range(1):
		if GameManager.animatronics_locations[mascots[i]] == "Vent Section 3"  :
			missed = false
			GameManager.animatronic_flashed.emit(mascots[i])
			
	if missed == true:
		print("Missed Target.")
	impact_power(Flash_Power_Use)


func _on_right_button_pressed() -> void:
	if check_for_power() == false:
		return
	SoundEffects.get_node("flashlightOn").play()
	var mascots := ["Hooters", "Gritty","Franklin"]
	var missed = true
	for i in range(3):
		if GameManager.animatronics_locations[mascots[i]] == "RightOfficeDoor" :
			missed = false
			GameManager.animatronic_flashed.emit(mascots[i])
			
	if missed == true:
		print("Missed Target.")
	impact_power(Flash_Power_Use)
