extends Area2D

const SCALE_SPEED = 0.1
const POSITION_OFFSET = 3.25

var mouse_entered_object = false
var body_entered_object = false
var original_scale = Vector2(1, 1)


func _ready() -> void:
	original_scale = scale


func _input(event: InputEvent) -> void:
	if (
		event is InputEventMouseMotion
		and mouse_entered_object
		and Input.is_action_pressed("left_mouse")
	):
		var scale_amount = SCALE_SPEED
		var to_move_position = Vector2(0, 0)
		var global_mouse_position = get_global_mouse_position()

		# top left
		if (
			(global_mouse_position - global_position).x < 0
			and (global_mouse_position - global_position).y < 0
		):
			scale_amount *= -event.relative.x - event.relative.y
			to_move_position = Vector2(-POSITION_OFFSET, -POSITION_OFFSET)

		# top right
		elif (
			(global_mouse_position - global_position).x > 0
			and (global_mouse_position - global_position).y < 0
		):
			scale_amount *= event.relative.x - event.relative.y
			to_move_position = Vector2(POSITION_OFFSET, -POSITION_OFFSET)

		# bottom left
		elif (
			(global_mouse_position - global_position).x < 0
			and (global_mouse_position - global_position).y > 0
		):
			scale_amount *= -event.relative.x + event.relative.y
			to_move_position = Vector2(-POSITION_OFFSET, POSITION_OFFSET)

		# bottom right
		elif (
			(global_mouse_position - global_position).x > 0
			and (global_mouse_position - global_position).y > 0
		):
			scale_amount *= event.relative.x + event.relative.y
			to_move_position = Vector2(POSITION_OFFSET, POSITION_OFFSET)

		else:
			scale_amount *= 0

		var to_scale = Vector2(scale_amount, scale_amount)
		if scale + to_scale > original_scale * 2:
			scale = original_scale * 2
		elif scale + to_scale < original_scale * 0.5:
			scale = original_scale * 0.5
		elif scale_amount < 0 or (scale_amount >= 0 and not body_entered_object):
			scale += to_scale
			position += to_move_position * scale_amount


func _on_mouse_entered() -> void:
	mouse_entered_object = true


func _on_mouse_exited() -> void:
	mouse_entered_object = false


func _on_body_entered(_body: Node2D) -> void:
	body_entered_object = true


func _on_body_exited(_body: Node2D) -> void:
	body_entered_object = false
