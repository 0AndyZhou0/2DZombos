extends MultiplayerSpawner

@export var enemy_scene: PackedScene
var index: int

# Called when the node enters the scene tree for the first time.
func _ready():
	if multiplayer.is_server():
		index = 1
		$Timer.start()
	spawn_function = _spawn_mob


func _spawn_mob(id: int) -> Node:
	var enemy = enemy_scene.instantiate()
	enemy.id = id
	var spawns = get_tree().get_nodes_in_group("EnemySpawnPoint")
	enemy.global_position = spawns[id%spawns.size()].global_position
	GameManager.Enemies[id] = {
		"id": id,
		"hp": 3
	}
	index += 1
	return enemy

func _on_timer_timeout():
	spawn(index)
