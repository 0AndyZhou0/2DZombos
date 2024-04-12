class_name Bullet
extends CharacterBody2D

var parent_id: int
var pierce: int = 0

func _physics_process(_delta):
	# Check for collision
	var collision = move_and_collide(velocity)
	# wall
	if collision and parent_id == multiplayer.get_unique_id():
		## Destroy bullet
		queue_free()


func _on_area_2d_body_entered(body):
	if body is Enemy and parent_id == multiplayer.get_unique_id():
		body.enemy_hit()
		pierce -= 1
		if pierce <= 0:
			queue_free()


func _on_area_2d_body_exited(body):
	pass # Replace with function body.
