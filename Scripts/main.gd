extends Node

const LEVEL_2_X_POS = -140
const LEVEL_3_Y_POS = -90
const LEVEL_4_X_POS = 180

var l1_door_and_key_connected = false
var l2_door_and_key_connected = false

var level = 1
var completed_levels = []
var l1_items_to_hide = []
var l2_items_to_hide = []
var l3_items_to_hide = []
var l4_items_to_hide = []
var global_object_currently_scaling = null

@onready var player: CharacterBody2D = $Player
@onready var player_area_2d_for_scaling: Area2D = $Player/Area2DForScaling
@onready var player_label: RichTextLabel = $Player/Sprite2D/PlayerLabel
@onready var press_button: AudioStreamPlayer = $PressButton
@onready var unlock: AudioStreamPlayer = $Unlock

# level 1
@onready var level_1: Node2D = $Level1
@onready var l1_tile_map: TileMapLayer = $Level1/TileMapLayer1
@onready var l1_key: Area2D = $Level1/Key
@onready var l1_label_1: Label = $UI/MarginContainer/Label
@onready var l1_label_2: Label = $UI/MarginContainer2/Label
@onready var l1_locked_door_connect: Area2D = $Level1/LockedDoorConnect

# level 2
@onready var level_2: Node2D = $Level2
@onready var l2_tile_map: TileMapLayer = $Level2/TileMapLayer2
@onready var l2_key: Area2D = $Level2/KeyFlipped
@onready var l2_label_1: Label = $UI/MarginContainer3/Label
@onready var l2_locked_door_connect: Area2D = $Level2/LockedDoorConnect

# level 3
@onready var level_3: Node2D = $Level3

# level 4
@onready var level_4: Node2D = $Level4


func _ready() -> void:
	l1_items_to_hide = level_1.get_children()
	l1_items_to_hide.append_array([l1_label_1, l1_label_2])
	l2_items_to_hide = level_2.get_children()
	l2_items_to_hide.append_array([l2_label_1])
	l3_items_to_hide = level_3.get_children()
	l4_items_to_hide = level_4.get_children()

	player_label.text = ""

	press_button.play()


func _process(_delta: float) -> void:
	if not completed_levels.has(1):
		complete_criteria(l1_door_and_key_connected, l1_key, l1_tile_map, l1_locked_door_connect)
	if not completed_levels.has(2):
		complete_criteria(l2_door_and_key_connected, l2_key, l2_tile_map, l2_locked_door_connect)

	if player.global_position.x > LEVEL_4_X_POS:
		update_level(4, l4_items_to_hide, [l1_items_to_hide, l2_items_to_hide, l3_items_to_hide])
	elif player.global_position.x >= LEVEL_2_X_POS and player.global_position.y >= LEVEL_3_Y_POS:
		update_level(1, l1_items_to_hide, [l2_items_to_hide, l3_items_to_hide, l4_items_to_hide])
	elif player.global_position.x < LEVEL_2_X_POS:
		update_level(2, l2_items_to_hide, [l1_items_to_hide, l3_items_to_hide, l4_items_to_hide])
	else:
		update_level(3, l3_items_to_hide, [l1_items_to_hide, l2_items_to_hide, l4_items_to_hide])


func set_sprite_outline_colour(sprite, colour):
	sprite.find_child("Sprite2D").material.set_shader_parameter("colour", colour)
	var current_level_key
	if level == 1:
		current_level_key = l1_key
	if level == 2:
		current_level_key = l2_key

	if is_instance_valid(current_level_key):
		if colour == Color.BLACK and sprite == current_level_key:
			player_label.text = "THE KEY'S SCALE ISN'T QUITE RIGHT..."
		elif colour == Color.WHITE and sprite == current_level_key:
			player_label.text = ""
	else:
		player_label.text = ""


func update_level(new_level, visible_items, non_visible_items_array):
	if level != new_level:
		unlock.play()

	level = new_level
	for item in visible_items:
		if is_instance_valid(item):
			item.visible = true
	for items in non_visible_items_array:
		for item in items:
			if is_instance_valid(item):
				item.visible = false

	player_area_2d_for_scaling.can_scale = level == 3


func complete_criteria(door_and_key_connected, key, tile_map, locked_door_connect):
	if door_and_key_connected:
		set_sprite_outline_colour(key, Color.BLACK)
		if 6 <= key.scale.x and key.scale.x <= 8:
			unlock_door(tile_map, locked_door_connect, key)
	else:
		set_sprite_outline_colour(key, Color.WHITE)


func unlock_door(tile_map, locked_door_connect, key):
	var locked_door_tile_pos = tile_map.to_local(locked_door_connect.global_position)
	var locked_door_tile_map_pos = tile_map.local_to_map(locked_door_tile_pos)

	var floor_tile_pos = tile_map.to_local(key.global_position)
	var floor_tile_map_pos = tile_map.local_to_map(floor_tile_pos)

	var floor_tile = tile_map.get_cell_source_id(floor_tile_map_pos)
	tile_map.set_cell(locked_door_tile_map_pos, floor_tile, Vector2i(0, 0))

	key.queue_free()
	completed_levels.append(level)

	if level == 2:
		player_label.visible = false


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
