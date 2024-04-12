extends Node2D

@export var enemy_scene: PackedScene
@onready var mob_timer = $MobTimer as Timer

var count: int
var id: int

func _ready():
	mob_timer.start()
	mob_timer.timeout.connect(_on_mob_timer_timeout)
	if multiplayer.is_server():
		count = 0
		id = 1

func _on_mob_timer_timeout():
	if multiplayer.is_server():
		if count < 10:
			spawn_mob(id)
			count += 1
			id += 1
	
@rpc("any_peer", "call_local")
func spawn_mob(id: int) -> void:
	var enemy = enemy_scene.instantiate()
	enemy.id = id
	add_child(enemy)
	GameManager.Enemies[id] = {
		"id": id,
		"hp": 3
	}
