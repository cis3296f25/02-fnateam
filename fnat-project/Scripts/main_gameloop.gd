extends Node2D

# Custom Signals for the entire game to handle.
signal animatronic_started(mascot_name, room_name)
signal animatronic_moved(mascot_name, old_room_name, new_room_name)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animatronic_started.connect(_animatronic_started_handler)
	animatronic_moved.connect(_animatronic_moved_handler)

func _animatronic_started_handler(mascot_name, room_name):
	print(mascot_name, " starting in:", room_name)
	
func _animatronic_moved_handler(mascot_name, old_room_name, new_room_name):
	print(mascot_name, " moved from %s → %s" % [old_room_name, new_room_name])
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
