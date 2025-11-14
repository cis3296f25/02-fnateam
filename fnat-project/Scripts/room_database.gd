extends Node


@export var rooms = {
	1 : {
		"Name" : "Storage", # Where Phillie FNATIC, Gritty, and Hoooter Start.
		"AdjacentRooms" : [2],
		"SealedDoor" : false,
		"Empty" : true,
		"Usage" : 10
	},
	2 : {
		"Name" : "Lounge", # Main HUB!!
		"AdjacentRooms" : [3,4, 5, 6],
		"SealedDoor" : false,
		"Empty" : true,
		"Usage" : 10
	},
	3 : { #Alternate Pathing to delay the approach of Gritty
		"Name" : "Cafe", 
		"AdjacentRooms" : [2],
		"SealedDoor" : false,
		"Empty" : true,
		"Usage" : 10
	},
	4 : { # Alternate Pathing to delay the approach of Phillie Fnatic
		"Name" : "Closet", 
		"AdjacentRooms" : [2],
		"SealedDoor" : false,
		"Empty" : true,
		"Usage" : 10
	},
	5 : { # Connecting section between the Lobby and the Gym
		"Name" : "LeftLockers", 
		"AdjacentRooms" : [2,7],
		"SealedDoor" : false,
		"Empty" : true,
		"Usage" : 10
	},
	6 : { # Connecting section between the Lobby and the Gym
		"Name" : "RightLockers", 
		"AdjacentRooms" : [2,7],
		"SealedDoor" : false,
		"Empty" : true,
		"Usage" : 10
	},
	7 : { # HUB section connecting the final defense against the mascots.
		"Name" : "Gym", 
		"AdjacentRooms" : [5,6,8,9,14],
		"SealedDoor" : false,
		"Empty" : true,
		"Usage" : 10
	},
	8 : { # Where the other animatronics will come down to get to the office.
		"Name" : "LeftHall", 
		"AdjacentRooms" : [7,17],
		"SealedDoor" : false,
		"Empty" : true,
		"Usage" : 10
	},
	9 : { # Where the other animatronics will come down to get to the office.
		"Name" : "RightHall", 
		"AdjacentRooms" : [7,16],
		"SealedDoor" : false,
		"Empty" : true,
		"Usage" : 10
	},
	10 : { # This is where Phang will start.
		"Name" : "Utility", 
		"AdjacentRooms" : [2, 11],
		"SealedDoor" : false,
		"Empty" : true,
		"Usage" : 10
	},
	11 : { # Connecting section to have Phang take some time to get to the office. Connects the vents to the Utility.
		"Name" : "Vent Section 1", 
		"AdjacentRooms" : [10, 12],
		"SealedDoor" : false,
		"Empty" : true,
		"Usage" : 10
	},
	12 : { # Connecting section to have Phang take some time to get to the office.
		"Name" : "Vent Section 2", 
		"AdjacentRooms" : [11,13],
		"SealedDoor" : false,
		"Empty" : true,
		"Usage" : 10
	},
	13 : { # This will be the section linking the vents to the office. Where Phang will come throguh to get to the office.
		"Name" : "Vent Section 3", 
		"AdjacentRooms" : [12, 15],
		"SealedDoor" : false,
		"Empty" : true,
		"Usage" : 10
	},
	14 : { # This is where Franklin the Dog will start.
		"Name" : "BallCart", 
		"AdjacentRooms" : [7],
		"SealedDoor" : false,
		"Empty" : true,
		"Usage" : 10
	},
	15 : { # This is where the player is going to be at. All Animatronics are trying to get to here.
		"Name" : "Office", 
		"AdjacentRooms" : [17,16,13],
		"SealedDoor" : false,
		"Empty" : true,
		"Usage" : 10
	},
	16 : { # Animatronics at the left door will enter the office from there
		"Name" : "RightOfficeDoor", 
		"AdjacentRooms" : [9, 15],
		"SealedDoor" : false,
		"Empty" : true,
		"Usage" : 10
	},
	17 : { # Animatronics at the left door will enter the office from there
		"Name" : "LeftOfficeDoor", 
		"AdjacentRooms" : [8,15],
		"SealedDoor" : false,
		"Empty" : true,
		"Usage" : 10
	},
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
