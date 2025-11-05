extends Node2D



var rng = RandomNumberGenerator.new()
var current_room = "stage"

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
		"stage":
			current_room = ["room A", "room B"].pick_random()
		"room A":
			current_room = ["room B", "stage"].pick_random()
		"room B":
			current_room = ["room A", "stage"].pick_random()
#repeast this for each room. Currently just have placeholders in
#because I don't know what the map looks like.
