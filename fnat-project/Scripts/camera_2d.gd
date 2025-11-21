extends Camera2D

@export var max_pan_speed: float = 9000.0     # maximum speed at edge
@export var smoothness: float = 8.0          # easing factor
@export var max_offset: float = 800.0        # max horizontal offset
@export var edge_threshold: float = 0.15     # size of activation sides

@export var left_button: Button
@export var right_button: Button

var paused: bool = false

func _ready():
	GameManager.cams_opened.connect(Callable(self, "pause_camera"))
	GameManager.cams_closed.connect(Callable(self, "resume_camera"))


func pause_camera():
	paused = true
	left_button.disabled = true
	right_button.disabled = true


func resume_camera():
	paused = false
	left_button.disabled = false
	right_button.disabled = false


func _process(delta):
	if paused:
		return

	var screen_size = get_viewport_rect().size
	var mouse_x = get_viewport().get_mouse_position().x

	var velocity_x = _calculate_edge_velocity(mouse_x, screen_size.x)

	# clamp within max_offset
	var target_x = clamp(position.x + velocity_x * delta, -max_offset, max_offset)

	# smoothly move camera
	position.x = lerp(position.x, target_x, delta * smoothness)


# helper function for proportional velocity
func _calculate_edge_velocity(mouse_x: float, screen_width: float) -> float:
	var left_edge = screen_width * edge_threshold
	var right_edge = screen_width * (1.0 - edge_threshold)
	
	if mouse_x < left_edge:
		var t = (left_edge - mouse_x) / left_edge  # 0 at inner edge, 1 at far left
		return -t * max_pan_speed
	elif mouse_x > right_edge:
		var t = (mouse_x - right_edge) / (screen_width - right_edge)  # 0 at inner edge, 1 at far right
		return t * max_pan_speed
	else:
		return 0.0
