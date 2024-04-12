class_name Enemy
extends CharacterBody2D

const SPEED: float = 100.0
const ACCEL: float = 20.0
var player: Node2D
var id: int
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D

func _ready():
	pass

func _physics_process(delta: float) -> void:
	#if not multiplayer.is_server():
		#return
		
	# find nearest player
	if get_tree().get_nodes_in_group("Player").is_empty():
		return
	player = get_tree().get_first_node_in_group("Player")
	var currdist = global_position.distance_to(player.global_position)
	for p in get_tree().get_nodes_in_group("Player"):
		var distance = global_position.distance_to(p.global_position)
		if distance < currdist:
			currdist = distance
			player = p
			
	if player == null:
		return
	
	nav_agent.target_position = player.global_position

	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = velocity.lerp(dir, ACCEL * delta)

	var collision = move_and_collide(velocity)
	if collision and collision.get_collider().has_method("player_hit"):
		collision.get_collider().player_hit()

func enemy_hit() -> void:
	GameManager.enemy_hit.rpc_id(1, id)
