extends Node2D



var rng = RandomNumberGenerator.new()
var current_room = "Storage"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.timeout.connect(timeout)

func timeout() -> void:
	
	var my_random_number = rng.randi_range(1, 20)
	if randi_range(1,20) <= my_random_number:
		move()
		
		print("Fnatic has moved to ", current_room)


func move() -> void:
	match current_room:
		"Storage":
			current_room = "Lobby"
		"Lobby":
			current_room = ["Closet", "Leftlocker", "Storage"].pick_random()
		"Closet":
			current_room = "Lobby"
		"Leftlocker":
			current_room = ["Gym", "Lobby"].pick_random()
		"Gym":
			current_room = ["Lefthallway","Lefthallway","Lefthallway","Lefthallway","Leftlocker"].pick_random()
		"Lefthallway":
			current_room = ["Gym", "Office"].pick_random()
		"Office":
			print("Game over")
		
#repeast this for each room. Currently just have placeholders in
#because I don't know what the map looks like.
