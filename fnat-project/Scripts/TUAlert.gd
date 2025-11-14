extends Node2D

@onready var label: Label = $TUalert 

func show_message(message: String):
	label.text = message
	label.visible = true
	label.modulate = Color(1, 0.2, 0.2)
	print("TUAlert:", message)

	# Optional fade-out effect
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 1.5).set_delay(3.0)
	await tween.finished
	label.visible = false
