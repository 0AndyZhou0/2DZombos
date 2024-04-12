extends Node2D

@export var weapon = {
	"name": "example",
	"pierce": 2,
	"auto": true,
	"firerate": 100,
	"bullet_speed": 10,
	"accuracy": 0,
	"movement_speed": 1,
	"cost": 1000,
}

var player;
var player_on = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if player_on and Input.is_action_just_pressed("interact")\
	and GameManager.get_points() >= weapon.cost:
		GameManager.weapon_buy.rpc_id(1, weapon.cost)
		player.set_weapon(weapon)


func _on_body_entered(body):
	if body.name == str(multiplayer.get_unique_id()):
		player = body
		player_on = true


func _on_body_exited(body):
	if body.name == str(multiplayer.get_unique_id()):
		player_on = false
