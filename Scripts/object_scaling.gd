extends Area2D

enum CornerPos { NONE, TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT, MIDDLE }

const SCALE_SPEED = 0.01
const POSITION_OFFSET = 3.25
const CORNER_SELECT_OFFSET = 12.0

@export var can_position = true

@export_range(0.1, 1., 0.1) var min_scale = 0.5
@export_range(1., 3., 0.1) var max_scale = 2.

var mouse_entered_object = false
var original_scale = Vector2(1, 1)
var selected_corner: CornerPos = CornerPos.NONE
var current_scale_amount = 0


func _ready() -> void:
	original_scale = scale


func _draw() -> void:
	const OFFSET = 3.
	const SQUARE_SIZE = Vector2(1.5, 1.5)
	const ACTIVE_COLOR = Color(1, 1, 1, 1)
	var color = Color(1, 1, 1, 0.5) if mouse_entered_object else Color(1, 1, 1, 0.1)
	draw_set_transform(Vector2(-position.x, -position.y))

	# middle
	if can_position:
		var middle_rect = Rect2(
			Vector2(global_position.x - SQUARE_SIZE.x / 2, global_position.y - SQUARE_SIZE.y / 2),
			SQUARE_SIZE
		)
		draw_rect(middle_rect, ACTIVE_COLOR if selected_corner == CornerPos.MIDDLE else color)

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
		var scale_amount = SCALE_SPEED * global_scale.x
		var global_mouse_position = get_global_mouse_position()

		# middle
		if (
			can_position
			and -CORNER_SELECT_OFFSET <= (global_mouse_position - global_position).x
			and (global_mouse_position - global_position).x <= CORNER_SELECT_OFFSET
			and -CORNER_SELECT_OFFSET <= (global_mouse_position - global_position).y
			and (global_mouse_position - global_position).y <= CORNER_SELECT_OFFSET
		):
			update_corner(CornerPos.MIDDLE)

		# top left
		elif (
			(global_mouse_position - global_position).x < -CORNER_SELECT_OFFSET
			and (global_mouse_position - global_position).y < -CORNER_SELECT_OFFSET
		):
			update_corner(CornerPos.TOP_LEFT)
			current_scale_amount = scale_amount * (-event.relative.x - event.relative.y)

		# top right
		elif (
			(global_mouse_position - global_position).x > CORNER_SELECT_OFFSET
			and (global_mouse_position - global_position).y < -CORNER_SELECT_OFFSET
		):
			update_corner(CornerPos.TOP_RIGHT)
			current_scale_amount = scale_amount * (event.relative.x - event.relative.y)

		# bottom left
		elif (
			(global_mouse_position - global_position).x < -CORNER_SELECT_OFFSET
			and (global_mouse_position - global_position).y > CORNER_SELECT_OFFSET
		):
			update_corner(CornerPos.BOTTOM_LEFT)
			current_scale_amount = scale_amount * (-event.relative.x + event.relative.y)

		# bottom right
		elif (
			(global_mouse_position - global_position).x > CORNER_SELECT_OFFSET
			and (global_mouse_position - global_position).y > CORNER_SELECT_OFFSET
		):
			update_corner(CornerPos.BOTTOM_RIGHT)
			current_scale_amount = scale_amount * (event.relative.x + event.relative.y)

		else:
			selected_corner = CornerPos.NONE
			current_scale_amount = 0


func _process(_delta: float) -> void:
	if mouse_entered_object and Input.is_action_pressed("left_mouse"):
		var global_mouse_position = get_global_mouse_position()
		var to_scale = Vector2(current_scale_amount, current_scale_amount)
		if selected_corner == CornerPos.MIDDLE:
			position = global_mouse_position
		elif scale + to_scale > original_scale * max_scale:
			scale = original_scale * max_scale
		elif scale + to_scale < original_scale * min_scale:
			scale = original_scale * min_scale
		else:
			scale += to_scale


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
