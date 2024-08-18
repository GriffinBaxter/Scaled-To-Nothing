extends Node

const LEVEL_2_X_POS = -140

var l1_door_and_key_connected = false
var l2_door_and_key_connected = false

var level = 1
var completed_levels = []
var l1_items_to_hide = []
var l2_items_to_hide = []
var global_object_currently_scaling = null

@onready var player: CharacterBody2D = $Player

# level 1
@onready var level_1: Node2D = $Level1
@onready var l1_tile_map: TileMapLayer = $Level1/TileMapLayer1
@onready var l1_key: Area2D = $Level1/Key
@onready var l1_label: Label = $UI/MarginContainer/Label
@onready var l1_locked_door_connect: Area2D = $Level1/LockedDoorConnect

# level 2
@onready var level_2: Node2D = $Level2
@onready var l2_tile_map: TileMapLayer = $Level2/TileMapLayer2
@onready var l2_key: Area2D = $Level2/KeyFlipped
@onready var l2_locked_door_connect: Area2D = $Level2/LockedDoorConnect


func _ready() -> void:
	l1_items_to_hide = level_1.get_children()
	l1_items_to_hide.append(l1_label)
	l2_items_to_hide = level_2.get_children()


func _process(_delta: float) -> void:
	if not completed_levels.has(1):
		l1_complete_criteria()
	if not completed_levels.has(2):
		l2_complete_criteria()

	if player.global_position.x >= LEVEL_2_X_POS:
		update_level(1, l1_items_to_hide, [l2_items_to_hide])
	else:
		update_level(2, l2_items_to_hide, [l1_items_to_hide])


func set_sprite_outline_colour(sprite, colour):
	sprite.find_child("Sprite2D").material.set_shader_parameter("colour", colour)


func update_level(new_level, visible_items, non_visible_items_array):
	level = new_level
	for item in visible_items:
		if is_instance_valid(item):
			item.visible = true
	for items in non_visible_items_array:
		for item in items:
			if is_instance_valid(item):
				item.visible = false


func l1_complete_criteria():
	if l1_door_and_key_connected:
		set_sprite_outline_colour(l1_key, Color.BLACK)
		if 6 <= l1_key.scale.x and l1_key.scale.x <= 8:
			l1_unlock_door()
	else:
		set_sprite_outline_colour(l1_key, Color.WHITE)


func l1_unlock_door():
	var locked_door_tile_pos = l1_tile_map.to_local(l1_locked_door_connect.global_position)
	var locked_door_tile_map_pos = l1_tile_map.local_to_map(locked_door_tile_pos)

	var floor_tile_pos = l1_tile_map.to_local(l1_key.global_position)
	var floor_tile_map_pos = l1_tile_map.local_to_map(floor_tile_pos)

	var floor_tile = l1_tile_map.get_cell_source_id(floor_tile_map_pos)
	l1_tile_map.set_cell(locked_door_tile_map_pos, floor_tile, Vector2i(0, 0))

	l1_key.queue_free()
	completed_levels.append(1)


func l2_complete_criteria():
	if l2_door_and_key_connected:
		set_sprite_outline_colour(l2_key, Color.BLACK)
		if 6 <= l2_key.scale.x and l2_key.scale.x <= 8:
			l2_unlock_door()
	else:
		set_sprite_outline_colour(l2_key, Color.WHITE)


func l2_unlock_door():
	var locked_door_tile_pos = l2_tile_map.to_local(l2_locked_door_connect.global_position)
	var locked_door_tile_map_pos = l2_tile_map.local_to_map(locked_door_tile_pos)

	var floor_tile_pos = l2_tile_map.to_local(l2_key.global_position)
	var floor_tile_map_pos = l2_tile_map.local_to_map(floor_tile_pos)

	var floor_tile = l2_tile_map.get_cell_source_id(floor_tile_map_pos)
	l2_tile_map.set_cell(locked_door_tile_map_pos, floor_tile, Vector2i(0, 0))

	l2_key.queue_free()
	completed_levels.append(2)


func _on_object_currently_scaling(value: Variant) -> void:
	if global_object_currently_scaling == null or value == null:
		global_object_currently_scaling = value


func _l1_on_key_connect(area: Area2D) -> void:
	if area.name == "KeyConnect":
		l1_door_and_key_connected = true


func _l1_on_key_disconnect(area: Area2D) -> void:
	if area.name == "KeyConnect":
		l1_door_and_key_connected = false


func _l2_on_key_connect(area: Area2D) -> void:
	if area.name == "KeyConnect":
		l2_door_and_key_connected = true


func _l2_on_key_disconnect(area: Area2D) -> void:
	if area.name == "KeyConnect":
		l2_door_and_key_connected = false
