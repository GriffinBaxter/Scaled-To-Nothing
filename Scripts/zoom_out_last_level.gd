extends Node2D

var scaled_down = false
var animation_complete = false

@onready var area_2d_for_scaling_room: Area2D = $Area2DForScalingRoom
@onready var camera_2d: Camera2D = $"../Player/Camera2D"
@onready var collision_shape_2d: CollisionShape2D = $Area2DForScalingRoom/CollisionShape2D
@onready var end_label: Label = $"../UI/EndMarginContainer/EndLabel"
@onready var player: CharacterBody2D = $"../Player"


func _process(delta: float) -> void:
	if not scaled_down and not animation_complete:
		camera_2d.zoom.x = area_2d_for_scaling_room.scale.x * 0.0625
		camera_2d.zoom.y = area_2d_for_scaling_room.scale.x * 0.0625
		collision_shape_2d.scale = area_2d_for_scaling_room.scale * 0.125

		if area_2d_for_scaling_room.scale.x <= 16:
			scaled_down = true

	if not animation_complete and area_2d_for_scaling_room.scale.x >= 0 and camera_2d.zoom.x >= 0:
		if camera_2d.zoom.x - 0.5 * delta <= 0:
			animation_complete = true
		else:
			camera_2d.zoom.x -= 0.5 * delta
			camera_2d.zoom.y -= 0.5 * delta

	if animation_complete:
		player.movable = false
		player.visible = false
		visible = false
		camera_2d.zoom.x = 2
		camera_2d.zoom.y = 2
		camera_2d.global_position = Vector2(304, -144)
		end_label.visible = true
