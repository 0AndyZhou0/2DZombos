class_name Player
extends CharacterBody2D

var speed: float = 300.0
const ACCEL: float = 20.0
@onready var shoot_timer: Timer = $"bullet cooldown"
@onready var invulnerable: Timer = $invulnerability

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

func _ready():
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		var camera = Camera2D.new()
		camera.zoom = Vector2(1.5, 1.5)
		add_child(camera)

func _physics_process(delta: float) -> void:
	if $MultiplayerSynchronizer.get_multiplayer_authority() != multiplayer.get_unique_id():
		return
	
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

func player_hit() -> void:
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id() and invulnerable.is_stopped():
		GameManager.player_hit.rpc_id(1)
		invulnerable.start()

# Shooting
func fire_bullet():
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


# Weapon Pickup
func set_weapon(new_weapon: Dictionary):
	weapons[currweapon] = new_weapon
	update_weapon()
	
func update_weapon():
	set_firerate(weapons[currweapon].firerate)
	set_movement_speed(weapons[currweapon].movement_speed)

func set_movement_speed(multiplier: float):
	speed = 300.0 * multiplier

func set_firerate(firerate: float):
	shoot_timer.wait_time = 1/firerate

# Getters
func get_hp() -> float:
	return GameManager.Players[multiplayer.get_unique_id()].hp

func get_points() -> float:
	return GameManager.Players[multiplayer.get_unique_id()].points
