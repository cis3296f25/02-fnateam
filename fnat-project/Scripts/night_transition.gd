extends Control

@onready var night_label = $Panel/Night

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match GameManager.current_night:
		1:
			night_label.text = "1st Night"			
		2:
			night_label.text = "2nd Night"
		3:
			night_label.text = "3rd Night"
		_:
			night_label.text =  str(GameManager.current_night) + "th Night"
			print("We don't know what Night we are in.")
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file("res://Scenes/SecurityDesk.tscn")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
