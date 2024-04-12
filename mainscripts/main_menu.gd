class_name MainMenu
extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_start_game_button_down():
	GameManager.Players = {
			multiplayer.get_unique_id() : {"name": "Single Player",
			"id": multiplayer.get_unique_id(),
			"score": 0}
		}
	print(1, get_tree_string())
	var start_level = preload("res://main.tscn")
	get_tree().change_scene_to_packed(start_level)

func _on_quit_game_button_down():
	get_tree().quit()
