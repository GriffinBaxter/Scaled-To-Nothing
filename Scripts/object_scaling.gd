extends CollisionObject2D

signal object_currently_scaling(value)

enum CornerPos { NONE, TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT, MIDDLE }

const SCALE_SPEED = 1.25
const POSITION_OFFSET = 3.25
const CORNER_SELECT_OFFSET = 12.0

@export var can_position = true
@export var can_scale = true

@export var scale_position_area: Area2D
@export var main: Node

@export_range(0.1, 1., 0.1) var min_scale = 0.5
@export_range(1., 3., 0.1) var max_scale = 2.

var mouse_entered_object = false
var original_scale = Vector2(1, 1)
var selected_corner: CornerPos = CornerPos.NONE
var current_scale_amount = 0
var currently_scaling_or_positioning = false
var near_player = false
var sound_playing = false

@onready var move_or_scale: AudioStreamPlayer = %MoveOrScale


func _ready() -> void:
	original_scale = scale


func _draw() -> void:
	if near_player:
		const OFFSET = 3.
		const SQUARE_SIZE = Vector2(1.5, 1.5)
		const ACTIVE_COLOR = Color(1, 1, 1, 1)
		const INACTIVE_COLOR = Color(1, 1, 1, 0.25)
		draw_set_transform(Vector2(-global_position.x, -global_position.y))

		if can_position:
			# middle
			var middle_rect = Rect2(
				Vector2(
					global_position.x - SQUARE_SIZE.x / 2, global_position.y - SQUARE_SIZE.y / 2
				),
				SQUARE_SIZE
			)
			draw_rect(
				middle_rect, ACTIVE_COLOR if selected_corner == CornerPos.MIDDLE else INACTIVE_COLOR
			)

		if can_scale:
			# top left
			var top_left_rect = Rect2(
				Vector2(
					global_position.x - OFFSET - SQUARE_SIZE.x,
					global_position.y - OFFSET - SQUARE_SIZE.y
				),
				SQUARE_SIZE
			)
			draw_rect(
				top_left_rect,
				ACTIVE_COLOR if selected_corner == CornerPos.TOP_LEFT else INACTIVE_COLOR
			)

			# top right
			var top_right_rect = Rect2(
				Vector2(global_position.x + OFFSET, global_position.y - OFFSET - SQUARE_SIZE.y),
				SQUARE_SIZE
			)
			draw_rect(
				top_right_rect,
				ACTIVE_COLOR if selected_corner == CornerPos.TOP_RIGHT else INACTIVE_COLOR
			)

			# bottom left
			var bottom_left_rect = Rect2(
				Vector2(global_position.x - OFFSET - SQUARE_SIZE.x, global_position.y + OFFSET),
				SQUARE_SIZE
			)
			draw_rect(
				bottom_left_rect,
				ACTIVE_COLOR if selected_corner == CornerPos.BOTTOM_LEFT else INACTIVE_COLOR
			)

			# bottom right
			var bottom_right_rect = Rect2(
				Vector2(global_position.x + OFFSET, global_position.y + OFFSET), SQUARE_SIZE
			)
			draw_rect(
				bottom_right_rect,
				ACTIVE_COLOR if selected_corner == CornerPos.BOTTOM_RIGHT else INACTIVE_COLOR
			)


func _input(event: InputEvent) -> void:
	if (
		event is InputEventMouseMotion
		and (mouse_entered_object or currently_scaling_or_positioning)
	):
		var scale_amount = SCALE_SPEED * global_scale.x
		var global_mouse_position = get_global_mouse_position()

		# middle
		if (
			(currently_scaling_or_positioning and selected_corner == CornerPos.MIDDLE)
			or (
				can_position
				and -CORNER_SELECT_OFFSET <= (global_mouse_position - global_position).x
				and (global_mouse_position - global_position).x <= CORNER_SELECT_OFFSET
				and -CORNER_SELECT_OFFSET <= (global_mouse_position - global_position).y
				and (global_mouse_position - global_position).y <= CORNER_SELECT_OFFSET
			)
		):
			if not currently_scaling_or_positioning:
				update_corner(CornerPos.MIDDLE)

		# top left
		elif (
			(currently_scaling_or_positioning and selected_corner == CornerPos.TOP_LEFT)
			or (
				can_scale
				and (global_mouse_position - global_position).x < -CORNER_SELECT_OFFSET
				and (global_mouse_position - global_position).y < -CORNER_SELECT_OFFSET
			)
		):
			if not currently_scaling_or_positioning:
				update_corner(CornerPos.TOP_LEFT)
			current_scale_amount = scale_amount * (-event.relative.x - event.relative.y)

		# top right
		elif (
			(currently_scaling_or_positioning and selected_corner == CornerPos.TOP_RIGHT)
			or (
				can_scale
				and (global_mouse_position - global_position).x > CORNER_SELECT_OFFSET
				and (global_mouse_position - global_position).y < -CORNER_SELECT_OFFSET
			)
		):
			if not currently_scaling_or_positioning:
				update_corner(CornerPos.TOP_RIGHT)
			current_scale_amount = scale_amount * (event.relative.x - event.relative.y)

		# bottom left
		elif (
			(currently_scaling_or_positioning and selected_corner == CornerPos.BOTTOM_LEFT)
			or (
				can_scale
				and (global_mouse_position - global_position).x < -CORNER_SELECT_OFFSET
				and (global_mouse_position - global_position).y > CORNER_SELECT_OFFSET
			)
		):
			if not currently_scaling_or_positioning:
				update_corner(CornerPos.BOTTOM_LEFT)
			current_scale_amount = scale_amount * (-event.relative.x + event.relative.y)

		# bottom right
		elif (
			(currently_scaling_or_positioning and selected_corner == CornerPos.BOTTOM_RIGHT)
			or (
				can_scale
				and (global_mouse_position - global_position).x > CORNER_SELECT_OFFSET
				and (global_mouse_position - global_position).y > CORNER_SELECT_OFFSET
			)
		):
			if not currently_scaling_or_positioning:
				update_corner(CornerPos.BOTTOM_RIGHT)
			current_scale_amount = scale_amount * (event.relative.x + event.relative.y)

		else:
			update_corner(CornerPos.NONE)
			current_scale_amount = 0


func _process(delta: float) -> void:
	if can_scale:
		var new_is_near_player = scale_position_area.overlaps_area(self)
		if new_is_near_player != near_player:
			near_player = scale_position_area.overlaps_area(self)
			queue_redraw()

		if Input.is_action_just_released("left_mouse"):
			currently_scaling_or_positioning = false
			object_currently_scaling.emit(null)
			move_or_scale.stop()
			sound_playing = false

		elif (
			near_player
			and Input.is_action_pressed("left_mouse")
			and (mouse_entered_object or currently_scaling_or_positioning)
		):
			object_currently_scaling.emit(self)
			if main.global_object_currently_scaling == self:
				if not sound_playing:
					move_or_scale.play()
					sound_playing = true
				currently_scaling_or_positioning = true
				var global_mouse_position = get_global_mouse_position()
				var to_scale = Vector2(current_scale_amount * delta, current_scale_amount * delta)
				if selected_corner == CornerPos.MIDDLE:
					# This makes it so you can't move objects outside the player boundary
					# (avoids objects getting stuck)
					var distance = (
						(global_mouse_position.abs() - scale_position_area.global_position.abs())
						. abs()
					)
					if distance.x < 65 and distance.y < 65:
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
