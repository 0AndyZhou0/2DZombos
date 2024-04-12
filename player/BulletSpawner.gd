extends MultiplayerSpawner


# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_function = _spawn_bullet
	
func _spawn_bullet(things: Array) -> Node:
	var bullet = preload("res://player/projectiles/bullet.tscn").instantiate()
	var weapon = things[3]
	bullet.position = things[0]
	bullet.velocity = things[1].normalized() * weapon.bullet_speed
	bullet.parent_id = things[2]
	bullet.pierce = weapon.pierce
	return bullet

func fire(position: Vector2, dir: Vector2, id: int, weapon: Dictionary) -> void:
	#var bullet = preload("res://player/projectiles/bullet.tscn").instantiate()
	#bullet.position = position
	#bullet.velocity = dir.normalized() * weapon.bullet_speed
	#bullet.parent_id = id
	#bullet.pierce = weapon.pierce
	spawn([position, dir, id, weapon])
