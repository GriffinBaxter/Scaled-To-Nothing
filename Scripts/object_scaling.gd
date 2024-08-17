extends Area2D


const SCALE_SPEED = 0.1

var mouse_entered_object = false
var original_scale = Vector2(1, 1)


func _ready() -> void:
	original_scale = scale


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and mouse_entered_object and Input.is_action_pressed("left_mouse"):
		var scale_amount = SCALE_SPEED
		var global_mouse_position = get_global_mouse_position()

		# top left
		if (global_mouse_position - global_position).x < 0 and (global_mouse_position - global_position).y < 0:
			scale_amount *= -event.relative.x - event.relative.y
		# top right
		elif (global_mouse_position - global_position).x > 0 and (global_mouse_position - global_position).y < 0:
			scale_amount *= event.relative.x - event.relative.y
		# bottom left
		elif (global_mouse_position - global_position).x < 0 and (global_mouse_position - global_position).y > 0:
			scale_amount *= -event.relative.x + event.relative.y
		# bottom right
		elif (global_mouse_position - global_position).x > 0 and (global_mouse_position - global_position).y > 0:
			scale_amount *= event.relative.x + event.relative.y
		else:
			scale_amount *= 0

		var to_scale = Vector2(scale_amount, scale_amount)
		if scale + to_scale > original_scale * 2:
			scale = original_scale * 2
		elif scale + to_scale < original_scale * 0.5:
			scale = original_scale * 0.5
		else:
			scale += to_scale


func _on_mouse_entered() -> void:
	mouse_entered_object = true


func _on_mouse_exited() -> void:
	mouse_entered_object = false
