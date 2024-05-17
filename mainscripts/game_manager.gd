extends Node

var Players = {}
var Enemies = {}

# Getters
func get_hp() -> float:
	return Players[multiplayer.get_unique_id()].hp

func get_points() -> float:
	return Players[multiplayer.get_unique_id()].points


# Setters
@rpc("authority", "call_local", "reliable")
func update_player_hp(id: int, hp: float):
	Players[id].hp = hp
	
@rpc("authority", "call_local", "reliable")
func update_player_points(id: int, points: float):
	Players[id].points = points
	

# Server functions
@rpc("any_peer", "call_local", "reliable")
func player_hit():
	if multiplayer.get_unique_id() != 1:
		return
		
	var foriegn_id = multiplayer.get_remote_sender_id()
	
	Players[foriegn_id].hp -= 1.0
	update_player_hp.rpc(foriegn_id, Players[foriegn_id].hp)
	#print("player_id:", id, " hp:", Players[p].hp)
	if Players[foriegn_id].hp <= 0:
		for player in get_tree().get_nodes_in_group("Player"):
			if player.name == str(foriegn_id):
				#TODO: make hide player and turn on spectate mode
				player.queue_free()

@rpc("any_peer", "call_local", "reliable")
func enemy_hit(id: int):
	if multiplayer.get_unique_id() != 1:
		return
	
	var foriegn_id = multiplayer.get_remote_sender_id()
	
	Enemies[id].hp -= 1
	#print("enemy_id:", id, " hp:", Enemies[id].hp)
	if Enemies[id].hp <= 0:
		for enemy in get_tree().get_nodes_in_group("Enemy"):
			if enemy.id == id:
				enemy.queue_free()
				
		Players[foriegn_id].points += 100
	Players[foriegn_id].points += 10
	update_player_points.rpc(foriegn_id, Players[foriegn_id].points)

@rpc("any_peer", "call_local", "reliable")
func weapon_buy(points: int):
	if multiplayer.get_unique_id() != 1:
		return
		
	var foriegn_id = multiplayer.get_remote_sender_id()
	if Players[foriegn_id].points >= points:
		Players[foriegn_id].points -= points
		update_player_points.rpc(foriegn_id, Players[foriegn_id].points)
