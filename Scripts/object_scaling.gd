extends Area2D

enum CornerPos { NONE, TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT }

const SCALE_SPEED = 0.1
const POSITION_OFFSET = 3.25

var mouse_entered_object = false
var original_scale = Vector2(1, 1)
var selected_corner: CornerPos = CornerPos.NONE


func _ready() -> void:
	original_scale = scale


func _draw() -> void:
	const OFFSET = 3.
	const SQUARE_SIZE = Vector2(1.5, 1.5)
	const ACTIVE_COLOR = Color(1, 1, 1, 1)
	var color = Color(1, 1, 1, 0.5) if mouse_entered_object else Color(1, 1, 1, 0.1)
	draw_set_transform(Vector2(-position.x, -position.y))

	# top left
	var top_left_rect = Rect2(
		Vector2(
			global_position.x - OFFSET - SQUARE_SIZE.x, global_position.y - OFFSET - SQUARE_SIZE.y
		),
		SQUARE_SIZE
	)
	draw_rect(top_left_rect, ACTIVE_COLOR if selected_corner == CornerPos.TOP_LEFT else color)

	# top right
	var top_right_rect = Rect2(
		Vector2(global_position.x + OFFSET, global_position.y - OFFSET - SQUARE_SIZE.y), SQUARE_SIZE
	)
	draw_rect(top_right_rect, ACTIVE_COLOR if selected_corner == CornerPos.TOP_RIGHT else color)

	# bottom left
	var bottom_left_rect = Rect2(
		Vector2(global_position.x - OFFSET - SQUARE_SIZE.x, global_position.y + OFFSET), SQUARE_SIZE
	)
	draw_rect(bottom_left_rect, ACTIVE_COLOR if selected_corner == CornerPos.BOTTOM_LEFT else color)

	# bottom right
	var bottom_right_rect = Rect2(
		Vector2(global_position.x + OFFSET, global_position.y + OFFSET), SQUARE_SIZE
	)
	draw_rect(
		bottom_right_rect, ACTIVE_COLOR if selected_corner == CornerPos.BOTTOM_RIGHT else color
	)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and mouse_entered_object:
		var scale_amount = SCALE_SPEED
		var to_move_position = Vector2(0, 0)
		var global_mouse_position = get_global_mouse_position()

		# top left
		if (
			(global_mouse_position - global_position).x < 0
			and (global_mouse_position - global_position).y < 0
		):
			update_corner(CornerPos.TOP_LEFT)
			scale_amount *= -event.relative.x - event.relative.y
			to_move_position = Vector2(-POSITION_OFFSET, -POSITION_OFFSET)

		# top right
		elif (
			(global_mouse_position - global_position).x > 0
			and (global_mouse_position - global_position).y < 0
		):
			update_corner(CornerPos.TOP_RIGHT)
			scale_amount *= event.relative.x - event.relative.y
			to_move_position = Vector2(POSITION_OFFSET, -POSITION_OFFSET)

		# bottom left
		elif (
			(global_mouse_position - global_position).x < 0
			and (global_mouse_position - global_position).y > 0
		):
			update_corner(CornerPos.BOTTOM_LEFT)
			scale_amount *= -event.relative.x + event.relative.y
			to_move_position = Vector2(-POSITION_OFFSET, POSITION_OFFSET)

		# bottom right
		elif (
			(global_mouse_position - global_position).x > 0
			and (global_mouse_position - global_position).y > 0
		):
			update_corner(CornerPos.BOTTOM_RIGHT)
			scale_amount *= event.relative.x + event.relative.y
			to_move_position = Vector2(POSITION_OFFSET, POSITION_OFFSET)

		else:
			selected_corner = CornerPos.NONE
			scale_amount *= 0

		if Input.is_action_pressed("left_mouse"):
			var to_scale = Vector2(scale_amount, scale_amount)
			if scale + to_scale > original_scale * 2:
				scale = original_scale * 2
			elif scale + to_scale < original_scale * 0.5:
				scale = original_scale * 0.5
			else:
				scale += to_scale
				position += to_move_position * scale_amount


func update_corner(corner: CornerPos) -> void:
	if selected_corner != corner:
		selected_corner = corner
		queue_redraw()


func _on_mouse_entered() -> void:
	mouse_entered_object = true
	queue_redraw()


func _on_mouse_exited() -> void:
	mouse_entered_object = false
	update_corner(CornerPos.NONE)
