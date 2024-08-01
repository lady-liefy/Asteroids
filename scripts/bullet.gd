### bullet.gd
extends RigidBody2D
class_name Bullet

const SPEED := 200

func _ready() -> void:
	$Line2D.width = Global.asteroid_line_weight
	$Line2D.default_color = Global.line_color

func _physics_process(_delta : float) -> void:
	Global.screen_wrap(self)

func delete() -> void:
	self.queue_free()

func _on_timer_timeout():
	delete()
