class_name Player
extends CharacterBody2D

var speed: float = 300.0
const ACCEL: float = 20.0
@onready var shoot_timer: Timer = $"bullet cooldown"
@onready var invulnerable: Timer = $invulnerability
var camera: Node

var downed: bool = false
var spectating: int = 0

var maxweapons = 2
var currweapon = 0
var weapons = [{
	"name": "pistol",
	"pierce": 1,
	"auto": false,
	"firerate": 10,
	"bullet_speed": 10,
	"accuracy": 0,
	"movement_speed": 1,
	"cost": 1000,
}]

var perks = []

func _ready() -> void:
	camera = Camera2D.new()
	disable_camera()
	camera.zoom = Vector2(1.5, 1.5)
	camera.add_to_group("Camera")
	add_child(camera)
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		enable_camera()
		
func _input(event):
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id()\
	and camera.enabled == false and event is InputEventMouseButton\
	and event.pressed and event.is_action_pressed("shoot"):
		spectate_next()
	pass

func _physics_process(delta: float) -> void:
	if $MultiplayerSynchronizer.get_multiplayer_authority() != multiplayer.get_unique_id():
		return
		
	# Change Weapon
	if Input.is_action_just_pressed("1"):
		change_weapon(1)
	elif Input.is_action_just_pressed("2"):
		change_weapon(2)
	elif Input.is_action_just_pressed("3"):
		change_weapon(3)
	
	# Shoot
	# TODO: add input buffer 
	# if we are allowed to shoot and if we are able to shoot
	if Input.is_action_pressed("shoot") and shoot_timer.is_stopped()\
	and (Input.is_action_just_pressed("shoot") or weapons[currweapon].auto):
		fire_bullet()

		# Fire raycast
		#fire_raycast()
	
	# Movement
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var angle: float = abs(direction.angle_to(velocity))
	velocity.x = move_toward(velocity.x, direction.x*speed, delta * 60 * (ACCEL + angle * 10))
	velocity.y = move_toward(velocity.y, direction.y*speed, delta * 60 * (ACCEL + angle * 10))
	velocity = velocity.limit_length(speed)

	move_and_slide()
	
# Camera
func disable_camera() -> void:
	camera.enabled = false

func enable_player_camera() -> void:
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		print("fixing camera")
		for player in get_tree().get_nodes_in_group("Player"):
			player.disable_camera()
		camera.enabled = true
		
func enable_camera() -> void:
	camera.enabled = true
	
func spectate_next() -> void:
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() <= 0:
		return
	spectating = (spectating + 1) % players.size()
	for player in players:
		player.disable_camera()
	players[spectating].enable_camera()
	

# Player Enemy Damage Interactions 
func player_hit() -> void:
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id() and invulnerable.is_stopped():
		GameManager.player_hit.rpc_id(1)
		invulnerable.start()

func player_die():
	queue_free()

# Shooting
func fire_bullet() -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var dir: Vector2 = mouse_pos - position
	$BulletSpawner.spawn([global_position, dir, multiplayer.get_unique_id(), weapons[currweapon]])
	shoot_timer.start()

func fire_raycast() -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()

	# Create raycast
	var raycast = $RayCast2D
	raycast.target_position = mouse_pos - position

	# Shoot
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.has_method("enemy_hit"):
			collider.enemy_hit.rpc()

# Change Weapon
func change_weapon(slot: int) -> bool:
	if weapons.size() >= slot:
		currweapon = slot-1
		update_weapon()
		return true
	return false

# Weapon Pickup
func pickup_weapon(new_weapon: Dictionary) -> bool:
	var picked_up = false
	if weapons.size() < maxweapons:
		weapons.append(new_weapon)
		currweapon = weapons.size()-1
		# Probably add animation here 
		picked_up = true
	else:
		weapons[currweapon] = new_weapon
	update_weapon()
	return picked_up
	
func update_weapon() -> void:
	set_firerate(weapons[currweapon].firerate)
	set_movement_speed(weapons[currweapon].movement_speed)

func set_movement_speed(multiplier: float) -> void:
	speed = 300.0 * multiplier

func set_firerate(firerate: float) -> void:
	shoot_timer.wait_time = 1/firerate

# Getters
func get_hp() -> float:
	return GameManager.Players[multiplayer.get_unique_id()].hp

func get_points() -> float:
	return GameManager.Players[multiplayer.get_unique_id()].points
