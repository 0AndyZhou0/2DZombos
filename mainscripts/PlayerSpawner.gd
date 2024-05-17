extends MultiplayerSpawner

@onready var index = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_function = _spawn_player
	if not multiplayer.is_server():
		return
	
	for player in GameManager.Players:
		spawn(player)

func _spawn_player(id: int) -> Node:
	var currentPlayer = load("res://player/player.tscn").instantiate()
	currentPlayer.name = str(id)
	currentPlayer.set_multiplayer_authority(id)
	for spawnpoint in get_tree().get_nodes_in_group("PlayerSpawnPoint"): 
		if spawnpoint.name == str(index):
			currentPlayer.global_position = spawnpoint.global_position
			break
	index += 1
	return currentPlayer

func spawn_player(id: int):
	spawn(id)

func kill_player(id: int):
	pass
