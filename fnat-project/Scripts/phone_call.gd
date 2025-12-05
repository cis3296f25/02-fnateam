extends Node2D

@onready var phone_ring = $PhoneRinging
@onready var phone_transition = $Transition
@onready var night_one = $NightOnePhoneCall
@onready var night_two = $NightTwoPhoneCall
@onready var night_three = $NightThreePhoneCall
@onready var night_four = $NightFourPhoneCall
@onready var night_five = $NightFivePhoneCall

func play_Ring():
	phone_ring.play()
	await phone_ring.finished
	phone_transition.play()
	await phone_transition.finished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match GameManager.current_night:
		1:
			await play_Ring()
			night_one.play()
		2:
			await play_Ring()
			night_two.play()
		3:
			await play_Ring()
			night_three.play()
		4:
			await play_Ring()
			night_four.play()
		5:
			await play_Ring()
			night_five.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
