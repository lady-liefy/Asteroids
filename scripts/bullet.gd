### bullet.gd
extends RigidBody2D
class_name Bullet

const ROTATE_THRUST := 15000
const SPEED         := 500

var spin_speed := Vector2(10, 20)

func _ready() -> void:
	$Line2D.width = Global.asteroid_line_weight
	$Line2D.default_color = Global.line_color
	
	# Random number gen; half will spin left, half spin right, by random amounts
	if randf_range(0, 1) < 0.5:
		set_angular_velocity(randf_range(spin_speed.x, spin_speed.y))
	else:
		set_angular_velocity(-randf_range(spin_speed.x, spin_speed.y))

func _integrate_forces(state : PhysicsDirectBodyState2D) -> void:
	Global.screen_wrap(self, state)

func delete() -> void:
	self.queue_free()

func _on_timer_timeout():
	delete()

func _on_body_entered(body):
	if body.is_in_group("asteroid"):
		await get_tree().process_frame
		body.die()
	self.delete()
