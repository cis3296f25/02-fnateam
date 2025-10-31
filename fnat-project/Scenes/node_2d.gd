extends Node2D

var _called_once := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_thisIsaFunction()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not _called_once:
		_thisIsaFunction()
		_called_once = true


func _thisIsaFunction() -> void:
	print("Han Made this") 
	pass
