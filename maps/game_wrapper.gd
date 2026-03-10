extends Node2D

@export var current_menu_state: int = 0 # 0: not paused, 1: pause menu, 2: settings menu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#for child in get_children():
		#child.scale = Vector2(1/PlayerSettings.game_zoom, 1/PlayerSettings.game_zoom)
	#$PauseMenu.scale = Vector2(1/PlayerSettings.game_zoom, 1/PlayerSettings.game_zoom)
	#$SettingsMenu.scale = Vector2(1/PlayerSettings.game_zoom, 1/PlayerSettings.game_zoom)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"): #pause
		print("esc")
		match current_menu_state:
			0: game_to_pause()
			1: pause_to_game()
			2: settings_to_pause()
			_: print_debug("Escape Pressed: Invalid Game Menu State")

func get_current_camera() -> Camera2D:
	for camera in get_tree().get_nodes_in_group("Camera"):
		if camera.enabled:
			return camera
	print("Invalid State: No camera found, using first camera")
	return get_tree().get_first_node_in_group("Camera")
	
func pause_controls() -> void:
	for player in get_tree().get_nodes_in_group("Player"):
		player.disable_controls = true
	
func unpause_controls() -> void:
	for player in get_tree().get_nodes_in_group("Player"):
		player.disable_controls = false
	
func game_to_pause() -> void:
	current_menu_state = 1
	$PauseMenu.visible = true
	$PauseMenu.global_position = get_current_camera().global_position
	pause_controls()

func pause_to_game() -> void:
	current_menu_state = 0;
	$PauseMenu.visible = false
	$SettingsMenu.visible = false
	unpause_controls()
	
	# NOT TESTED
	#for child in get_children():
		#if child.name == "Game":
			#child.visible = true;
		#else:
			#child.visible = false;
	

func pause_to_settings() -> void:
	current_menu_state = 2
	$PauseMenu.visible = false
	$SettingsMenu.global_position = get_current_camera().global_position
	$SettingsMenu.visible = true

func settings_to_pause() -> void:
	current_menu_state = 1
	$SettingsMenu.visible = false
	$PauseMenu.global_position = get_current_camera().global_position
	$PauseMenu.visible = true
