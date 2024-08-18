extends Control

@onready var main_menu_sound: AudioStreamPlayer = $MainMenuSound


func _ready() -> void:
	main_menu_sound.play()


func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_fullscreen_pressed() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
