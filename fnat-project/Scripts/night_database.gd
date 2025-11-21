extends Node

@export var Night = {
	1 : { # Active Mascots, FNATIC, GRITTY, and HOOTER
		"PhangAI_Start" : 0,
		"PhangAI_2AMIncr" : 0,
		"PhangAI_3AMIncr" : 0,
		"PhangAI_4AMIncr" : 0,

		"PhanaticAI_Start" : 0,
		"PhanaticAI_2AMIncr" : 1,
		"PhanaticAI_3AMIncr" : 2,
		"PhanaticAI_4AMIncr" : 1,

		"GrittyAI_Start" : 0,
		"GrittyAI_2AMIncr" : 0,
		"GrittyAI_3AMIncr" : 1,
		"GrittyAI_4AMIncr" : 1,

		"HooterAI_Start" : 0,
		"HooterAI_2AMIncr" : 1,
		"HooterAI_3AMIncr" : 1,
		"HooterAI_4AMIncr" : 1,

		"FranklinAI_Start" : 0,
		"FranklinAI_2AMIncr" : 0,
		"FranklinAI_3AMIncr" : 0,
		"FranklinAI_4AMIncr" : 0,

		"PassiveDrain" : 0,
		"MaxDrainCountdown" : 6
	},

	2 : { # We will introduce Phang and Franklin.
		"PhangAI_Start" : 2,
		"PhangAI_2AMIncr" : 0,
		"PhangAI_3AMIncr" : 3,
		"PhangAI_4AMIncr" : 0,

		"PhanaticAI_Start" : 5,
		"PhanaticAI_2AMIncr" : 1,
		"PhanaticAI_3AMIncr" : 2,
		"PhanaticAI_4AMIncr" : 1,

		"GrittyAI_Start" : 5,
		"GrittyAI_2AMIncr" : 1,
		"GrittyAI_3AMIncr" : 2,
		"GrittyAI_4AMIncr" : 1,

		"HooterAI_Start" : 2,
		"HooterAI_2AMIncr" : 0,
		"HooterAI_3AMIncr" : 2,
		"HooterAI_4AMIncr" : 1,

		"FranklinAI_Start" : 2,
		"FranklinAI_2AMIncr" : 1,
		"FranklinAI_3AMIncr" : 2,
		"FranklinAI_4AMIncr" : 0,

		"PassiveDrain" : 0,
		"MaxDrainCountdown" : 6
	},

	3 : {
		"PhangAI_Start" : 10,
		"PhangAI_2AMIncr" : 0,
		"PhangAI_3AMIncr" : 0,
		"PhangAI_4AMIncr" : 0,

		"PhanaticAI_Start" : 7,
		"PhanaticAI_2AMIncr" : 0,
		"PhanaticAI_3AMIncr" : 3,
		"PhanaticAI_4AMIncr" : 0,

		"GrittyAI_Start" : 7,
		"GrittyAI_2AMIncr" : 0,
		"GrittyAI_3AMIncr" : 3,
		"GrittyAI_4AMIncr" : 0,

		"HooterAI_Start" : 3,
		"HooterAI_2AMIncr" : 0,
		"HooterAI_3AMIncr" : 0,
		"HooterAI_4AMIncr" : 2,

		"FranklinAI_Start" : 3,
		"FranklinAI_2AMIncr" : 0,
		"FranklinAI_3AMIncr" : 0,
		"FranklinAI_4AMIncr" : 4,

		"PassiveDrain" : 0,
		"MaxDrainCountdown" : 6
	},

	4 : {
		"PhangAI_Start" : 5,
		"PhangAI_2AMIncr" : 0,
		"PhangAI_3AMIncr" : 5,
		"PhangAI_4AMIncr" : 0,

		"PhanaticAI_Start" : 10,
		"PhanaticAI_2AMIncr" : 0,
		"PhanaticAI_3AMIncr" : 2,
		"PhanaticAI_4AMIncr" : 1,

		"GrittyAI_Start" : 10,
		"GrittyAI_2AMIncr" : 0,
		"GrittyAI_3AMIncr" : 2,
		"GrittyAI_4AMIncr" : 1,

		"HooterAI_Start" : 4,
		"HooterAI_2AMIncr" : 1,
		"HooterAI_3AMIncr" : 3,
		"HooterAI_4AMIncr" : 2,

		"FranklinAI_Start" : 4,
		"FranklinAI_2AMIncr" : 1,
		"FranklinAI_3AMIncr" : 1,
		"FranklinAI_4AMIncr" : 1,

		"PassiveDrain" : 0,
		"MaxDrainCountdown" : 6
	},

	5 : {
		"PhangAI_Start" : 5,
		"PhangAI_2AMIncr" : 0,
		"PhangAI_3AMIncr" : 1,
		"PhangAI_4AMIncr" : 1,

		"PhanaticAI_Start" : 12,
		"PhanaticAI_2AMIncr" : 1,
		"PhanaticAI_3AMIncr" : 1,
		"PhanaticAI_4AMIncr" : 2,

		"GrittyAI_Start" : 12,
		"GrittyAI_2AMIncr" : 1,
		"GrittyAI_3AMIncr" : 1,
		"GrittyAI_4AMIncr" : 2,

		"HooterAI_Start" : 10,
		"HooterAI_2AMIncr" : 0,
		"HooterAI_3AMIncr" : 2,
		"HooterAI_4AMIncr" : 0,

		"FranklinAI_Start" : 10,
		"FranklinAI_2AMIncr" : 0,
		"FranklinAI_3AMIncr" : 1,
		"FranklinAI_4AMIncr" : 1,

		"PassiveDrain" : 0,
		"MaxDrainCountdown" : 6
	},
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
