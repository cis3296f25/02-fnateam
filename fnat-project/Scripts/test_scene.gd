extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print($RoomDatabase.rooms)
	julesTestFunc()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _thisIsaFunction() -> void:
	print("Dylan Made this")
	pass

func julesTestFunc() -> void:
	print("Jules did this")
	pass
