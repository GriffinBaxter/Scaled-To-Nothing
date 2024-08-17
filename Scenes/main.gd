extends Node

const LEVEL_2_X_POS = -140

var level = 1
var level_1_items = []
var level_2_items = []

@onready var player: CharacterBody2D = $Node2D/Player

@onready var locked_door_connect: Area2D = $Node2D/LockedDoorConnect

# level 1 items
@onready var tile_map_layer_1: TileMapLayer = $Node2D/TileMapLayer1
@onready var key: Area2D = $Node2D/Key
@onready var plant: Area2D = $Node2D/Plant
@onready var label: Label = $UI/MarginContainer/Label

# level 2 items
@onready var tile_map_layer_2: TileMapLayer = $Node2D/TileMapLayer2


func _ready() -> void:
	level_1_items = [tile_map_layer_1, key, plant, label]
	level_2_items = [tile_map_layer_2]


func _process(_delta: float) -> void:
	if player.global_position.x >= LEVEL_2_X_POS:
		level = 1
	else:
		level = 2

	if level == 1:
		update_level(level_1_items, [level_2_items])
	elif level == 2:
		update_level(level_2_items, [level_1_items])


func update_level(visible_items, non_visible_items_array):
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


func _on_locked_door_connect_area_entered(area: Area2D) -> void:
	if area.name == "KeyConnect":
		unlock_door()
