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
		
		print("Gritty has moved to ", current_room)


func move() -> void:
	match current_room:
		"Storage":
			current_room = "Lobby"
		"Lobby":
			current_room = ["Cafeteria", "Rightlocker", "Storage"].pick_random()
		"Cafeteria":
			current_room = "Lobby"
		"Rightlocker":
			current_room = ["Gym", "Lobby"].pick_random()
		"Gym":
			current_room = ["Righthallway","Righthallway","Righthallway","Righthallway","Rightlocker"].pick_random()
		"Righthallway":
			current_room = ["Gym", "Office"].pick_random()
		"Office":
			print("Game over")
		
#repeast this for each room. Currently just have placeholders in
#because I don't know what the map looks like.
