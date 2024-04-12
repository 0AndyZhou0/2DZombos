extends Control

const DEFAULT_ADDRESS = "localhost"
@export var Port = 25565

# Called when the node enters the scene tree for the first time.
func _ready():
	if "--server" in OS.get_cmdline_args():
		ServerManager.host_game()

# Buttons
func _on_host_button_down():
	ServerManager.host_game()
	ServerManager.player_name = $Name.text
	# unique_id should be 1
	ServerManager.send_player_info($Name.text, multiplayer.get_unique_id())


func _on_join_button_down():
	var address = $IP.text
	ServerManager.player_name = $Name.text
	ServerManager.join_game(address)


func _on_start_button_down():
	ServerManager.start_game.rpc()

