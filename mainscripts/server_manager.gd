extends Node

const DEFAULT_ADDRESS = "localhost"
@export var Port = 25565
var peer
var game_started = false
var player_name

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	multiplayer.server_disconnected.connect(server_disconnected)

# Server and client 
func peer_connected(id):
	print("Player Connected ", id)
	
func peer_disconnected(id):
	print("Player Disconnected ", id)
	if not multiplayer.is_server():
		return
	GameManager.Players.erase(id)
	for p in get_tree().get_nodes_in_group("Player"):
		if p.name == str(id):
			p.queue_free()

# Client only
func connected_to_server():
	print("Connected to Server")
	# remove old connects
	GameManager.Players.clear()
	# send player info
	send_player_info.rpc_id(1, player_name, multiplayer.get_unique_id())
	
func connection_failed():
	print("Connection Failed")
	
func server_disconnected():
	print("Server Disconnected")
	#GameManager.Players.clear()

@rpc("any_peer")
func send_player_info(p_name, id):
	if !GameManager.Players.has(id):
		GameManager.Players[id] = {
			"name": p_name,
			"id": id,
			"hp": 3.0,
			"points": 0
		}
	if multiplayer.is_server():
		print(GameManager.Players)
		for p_id in GameManager.Players:
			send_player_info.rpc(GameManager.Players[p_id].name, p_id)

func host_game():
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(Port, 32)
	if err != OK:
		print("Failed to create server: ", err)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players")

func join_game(address: String):
	if address.is_empty():
		address = DEFAULT_ADDRESS
	#print(address)
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(address, Port)
	if err != OK:
		print("Failed to create client: ", err)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)

@rpc("any_peer", "call_local", "reliable")
func start_game():
	if not game_started:
		game_started = true
		get_tree().change_scene_to_file("res://maps/game.tscn")
