extends Node

@onready var key: Area2D = $Node2D/Key
@onready var tile_map_layer: TileMapLayer = $Node2D/TileMapLayer

@onready var locked_door_connect: Area2D = $Node2D/LockedDoorConnect


func unlock_door():
	var locked_door_tile_pos = tile_map_layer.to_local(locked_door_connect.global_position)
	var locked_door_tile_map_pos = tile_map_layer.local_to_map(locked_door_tile_pos)

	var floor_tile_pos = tile_map_layer.to_local(key.global_position)
	var floor_tile_map_pos = tile_map_layer.local_to_map(floor_tile_pos)

	var floor_tile = tile_map_layer.get_cell_source_id(floor_tile_map_pos)
	tile_map_layer.set_cell(locked_door_tile_map_pos, floor_tile, Vector2i(0, 0))


func _on_locked_door_connect_area_entered(area: Area2D) -> void:
	if area.name == "KeyConnect":
		unlock_door()
