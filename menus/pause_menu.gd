extends Control

var current_state: int = 0; # 0: not paused, 1: pause menu, 2: settings menu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_settings_pressed() -> void:
	get_parent().pause_to_settings()


func _on_continue_pressed() -> void:
	get_parent().continue_game()
