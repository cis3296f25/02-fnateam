extends Node2D

# Custom Signals for the entire game to handle.
signal animatronic_started(mascot_name, room_name)
signal animatronic_moved(mascot_name, old_room_name, new_room_name)
signal loaded_new_cam(current_cam_node, cam_name)
signal animatronic_flashed(mascot_name)

var animatronics_locations = {}
var list_of_flashed_animatronics = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animatronic_started.connect(_animatronic_started_handler)
	animatronic_moved.connect(_animatronic_moved_handler)
	loaded_new_cam.connect(_handle_new_cam)
	animatronic_flashed.connect(_animatronic_flashed_handler)

func _animatronic_started_handler(mascot_name, room_name):
	animatronics_locations[mascot_name] = room_name
	print(mascot_name, " starting in:", room_name)
	
func _animatronic_moved_handler(mascot_name, old_room_name, new_room_name):
	animatronics_locations[mascot_name] = new_room_name
	#NEED TO CLEAR ANIMATRONIC FROM OLD ROOM
	print(mascot_name, " moved from %s → %s" % [old_room_name, new_room_name])

func _handle_new_cam(current_cam_node, cam_name):
	var mascots_to_show = []
	# Gets all the current animatronic's locations and adds it to the mascots to show on cam.
	for mascot in animatronics_locations:
		if animatronics_locations[mascot] == cam_name:
			mascots_to_show.append(mascot)
			print(mascot, " should display in Cam, ", cam_name)
			
	# Creates a Mascot Container in the Camera if it doesn't exist.
	var mascot_container = current_cam_node.get_node("Mascot_Container")
	if mascot_container == null:
		mascot_container = Container.new()
		mascot_container.name = "Mascot_Container"
		current_cam_node.add_child(mascot_container)

	# REMOVE ALL CHILDREN!!
	
	var current_child = 0
	for mascot_child in mascot_container.get_children():
		mascot_container.remove_child(mascot_child)
			
			
	
	for mascot in mascots_to_show:
		var new_mascot_label = Label.new()
		new_mascot_label.name = mascot
		new_mascot_label.text = mascot + " is here!"
		new_mascot_label.set_position(Vector2(0, 20*current_child))
		mascot_container.add_child(new_mascot_label)
		current_child += 1
	
	#print(current_cam_node)
func _animatronic_flashed_handler(mascot_name):
	list_of_flashed_animatronics[mascot_name] = true
	print(mascot_name + "was flashed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
