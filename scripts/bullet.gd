extends CharacterBody2D
class_name Bullet

signal hit_obstacle(points)

const SPEED = 250.0

func _physics_process(delta) -> void:
	# Check for collision while moving
	var collision = move_and_collide(velocity * SPEED * delta)
	
	if collision:
		var collider = collision.get_collider()
		var is_obstacle = collider.is_in_group("obstacles")
		
		# If obstacle is hit by the bullet, deal it damage and delete bullet
		if is_obstacle:
			collider.take_damage(4)
			
			hit_obstacle.emit(100)
			self.queue_free()
