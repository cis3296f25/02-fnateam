extends Node2D

@onready var label: Label = $NotifFnat/TUalert
@onready var noti: Sprite2D = $NotifFnat

func show_message(message: String):
	label.modulate.a = 1.0
	noti.modulate.a = 1.0
	
	var anim_player = get_node("NotiAnim")
	

	label.text = message
	label.visible = true
	noti.visible = true
	anim_player.play("noti_appear")
	
	print("TUAlert:", message)
	await get_tree().create_timer(3).timeout # Wait for .3 seconds


	#var tween1 = create_tween() # fade out for label
	#var tween2 = create_tween() # fade out for noti
	#tween1.tween_property(label, "modulate:a", 0.0, 1.5).set_delay(3.0)
	#tween2.tween_property(noti, "modulate:a", 0.0, 1.5).set_delay(3.0)
	#await tween1.finished
	#await tween2.finished

	anim_player.play("noti_end")
	await get_tree().create_timer(.3).timeout # Wait for .3 seconds

	label.visible = false
	noti.visible = false
	
