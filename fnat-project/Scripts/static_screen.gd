extends Node2D

@onready var animated_static = $StaticAnimation

func _ready() -> void:
	animated_static.play("default")
