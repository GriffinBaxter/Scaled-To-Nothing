extends Node

@onready var key: Area2D = $Node2D/Key


func _ready() -> void:
	while true:
		print(key.global_position)
		await get_tree().create_timer(2).timeout


func _process(_delta: float) -> void:
	pass
