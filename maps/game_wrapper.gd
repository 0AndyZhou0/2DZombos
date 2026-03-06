extends Node2D

@export var current_menu_state: int = 0 # 0: not paused, 1: pause menu, 2: settings menu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"): #pause
		print("esc")
		match current_menu_state:
			0: pause_game()
			1: continue_game()
			2: settings_to_pause()
			_: print_debug("Escape Pressed: Invalid Game Menu State")

func pause_game() -> void:
	current_menu_state = 1
	$PauseMenu.visible = true
	for player in get_tree().get_nodes_in_group("Player"):
		player.disable_controls = true

func continue_game() -> void:
	current_menu_state = 0;
	$PauseMenu.visible = false
	$SettingsMenu.visible = false
	for player in get_tree().get_nodes_in_group("Player"):
		player.disable_controls = false
	
	# NOT TESTED
	#for child in get_children():
		#if child.name == "Game":
			#child.visible = true;
		#else:
			#child.visible = false;
	

func pause_to_settings() -> void:
	current_menu_state = 2
	$PauseMenu.visible = false
	$SettingsMenu.visible = true

func settings_to_pause() -> void:
	current_menu_state = 1
	$PauseMenu.visible = true
	$SettingsMenu.visible = false
