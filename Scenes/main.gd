extends Node

const LEVEL_2_X_POS = -140

var locked_door_and_key_connected = false

var level = 1
var completed_levels = []
var level_1_items = []
var level_2_items = []

@onready var player: CharacterBody2D = $Node2D/Player

# level 1 items (to hide)
@onready var tile_map_layer_1: TileMapLayer = $Node2D/TileMapLayer1
@onready var plant: Area2D = $Node2D/Plant
@onready var label: Label = $UI/MarginContainer/Label
# level 1 items
@onready var locked_door_connect: Area2D = $Node2D/LockedDoorConnect
@onready var key: Area2D = $Node2D/Key

# level 2 items
@onready var tile_map_layer_2: TileMapLayer = $Node2D/TileMapLayer2


func _ready() -> void:
	update_level(1, level_1_items, [level_2_items])

	level_1_items = [tile_map_layer_1, plant, label]
	level_2_items = [tile_map_layer_2]


func _process(_delta: float) -> void:
	if not completed_levels.has(1):
		level_1_complete_criteria()

	if player.global_position.x >= LEVEL_2_X_POS:
		update_level(1, level_1_items, [level_2_items])
	else:
		update_level(2, level_2_items, [level_1_items])


func level_1_complete_criteria():
	if locked_door_and_key_connected:
		set_sprite_outline_colour(key, Color.BLACK)
		if 6 <= key.scale.x and key.scale.x <= 8:
			unlock_door()
	else:
		set_sprite_outline_colour(key, Color.WHITE)


func set_sprite_outline_colour(sprite, colour):
	sprite.find_child("Sprite2D").material.set_shader_parameter("colour", colour)


func update_level(new_level, visible_items, non_visible_items_array):
	level = new_level
	for item in visible_items:
		item.visible = true
	for items in non_visible_items_array:
		for item in items:
			item.visible = false


func unlock_door():
	var locked_door_tile_pos = tile_map_layer_1.to_local(locked_door_connect.global_position)
	var locked_door_tile_map_pos = tile_map_layer_1.local_to_map(locked_door_tile_pos)

	var floor_tile_pos = tile_map_layer_1.to_local(key.global_position)
	var floor_tile_map_pos = tile_map_layer_1.local_to_map(floor_tile_pos)

	var floor_tile = tile_map_layer_1.get_cell_source_id(floor_tile_map_pos)
	tile_map_layer_1.set_cell(locked_door_tile_map_pos, floor_tile, Vector2i(0, 0))

	key.visible = false
	completed_levels.append(1)


func _on_locked_door_connect_area_entered(area: Area2D) -> void:
	if area.name == "KeyConnect":
		locked_door_and_key_connected = true


func _on_locked_door_connect_area_exited(area: Area2D) -> void:
	if area.name == "KeyConnect":
		locked_door_and_key_connected = false
