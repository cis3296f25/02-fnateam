extends Node


@export var rooms = {
	1 : {
		"Name" : "Storage", # Where Phillie FNATIC, Gritty, and Hoooter Start.
		"AdjacentRooms" : [2],
		"SealedDoor" : false
	},
	2 : {
		"Name" : "Lobby", # Main HUB!!
		"AdjacentRooms" : [3,4, 5, 6],
		"SealedDoor" : false
	},
	3 : { #Alternate Pathing to delay the approach of Gritty
		"Name" : "Cafeteria", 
		"AdjacentRooms" : [2],
		"SealedDoor" : false
	},
	4 : { # Alternate Pathing to delay the approach of Phillie Fnatic
		"Name" : "Closet", 
		"AdjacentRooms" : [2],
		"SealedDoor" : false
	},
	5 : { # Connecting section between the Lobby and the Gym
		"Name" : "Left Locker", 
		"AdjacentRooms" : [2,7],
		"SealedDoor" : false
	},
	6 : { # Connecting section between the Lobby and the Gym
		"Name" : "Right Locker", 
		"AdjacentRooms" : [2,7],
		"SealedDoor" : false
	},
	7 : { # HUB section connecting the final defense against the mascots.
		"Name" : "Gym", 
		"AdjacentRooms" : [5,6,8,9,14],
		"SealedDoor" : false
	},
	8 : { # Where the other animatronics will come down to get to the office.
		"Name" : "Left Hallway", 
		"AdjacentRooms" : [7,15],
		"SealedDoor" : false
	},
	9 : { # Where the other animatronics will come down to get to the office.
		"Name" : "Right Hallway", 
		"AdjacentRooms" : [7,15],
		"SealedDoor" : false
	},
	10 : { # This is where Phang will start.
		"Name" : "Utility", 
		"AdjacentRooms" : [2, 11],
		"SealedDoor" : false
	},
	11 : { # Connecting section to have Phang take some time to get to the office. Connects the vents to the Utility.
		"Name" : "Vent Section 1", 
		"AdjacentRooms" : [10, 12],
		"SealedDoor" : false
	},
	12 : { # Connecting section to have Phang take some time to get to the office.
		"Name" : "Vent Section 2", 
		"AdjacentRooms" : [11,13],
		"SealedDoor" : false
	},
	13 : { # This will be the section linking the vents to the office. Where Phang will come throguh to get to the office.
		"Name" : "Vent Section 3", 
		"AdjacentRooms" : [12, 15],
		"SealedDoor" : false
	},
	14 : { # This is where Franklin the Dog will start.
		"Name" : "Ball Cart", 
		"AdjacentRooms" : [7],
		"SealedDoor" : false
	},
	15 : { # This is where the player is going to be at. All Animatronics are trying to get to here.
		"Name" : "Office", 
		"AdjacentRooms" : [8,9,13],
		"SealedDoor" : false
	},
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
