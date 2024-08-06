### asteroid.gd
extends RigidBody2D
class_name Asteroid

# Numbers for clarity (they're implied by engine)
enum Size {
	SMALL = 1,
	MEDIUM = 2,
	LARGE = 3 
}

@export var size : Size = Size.LARGE
@export var thrust := Vector2.ZERO
@export var rotate_thrust := 15000
@export var parts : int   = 4

signal broke(size : Size , vel: Vector2)

func _ready() -> void:
	self._initialize_signals()
	self._initialize()

func _initialize_signals() -> void:
	Events.game_paused.connect(on_game_paused)
	Events.game_over.connect(on_game_over)
	Events.game_restarted.connect(on_game_restarted)
	Events.game_resumed.connect(on_game_resumed)

func _initialize() -> void:	
	$Line2D.set_default_color(Global.line_color)
	$Line2D.set_width(Global.asteroid_line_weight / self.size)
	set_contact_monitor(true)
	
	self.resize()
	self.set_enabled(true)

func _integrate_forces(state : PhysicsDirectBodyState2D) -> void:
	Global.screen_wrap(self, state)

func set_velocity(base_vel : Vector2) -> void:
	var multiplier : int
	thrust = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	
	if base_vel == Vector2.ZERO:
		multiplier = randf_range(Global.base_speed.x, Global.base_speed.y)
	else:
		multiplier = randf_range(Global.split_speed.x, Global.split_speed.y)
	
	self.linear_velocity = base_vel + (thrust.normalized() * Global.speed_factor * multiplier)

func resize() -> void:
	$Line2D.set_scale(Vector2(size, size))
	$CollisionPolygon2D.set_scale(Vector2(size, size))

func die() -> void:
	self.set_enabled(false)
	self.queue_free()
	broke.emit(self.size, global_position, linear_velocity)

func on_game_paused() -> void:
	self.set_enabled(false)

func on_game_over() -> void:
	self.set_enabled(false)

func on_game_restarted() -> void:
	self.set_enabled(true)
	
func on_game_resumed() -> void:
	self.set_enabled(true)

func set_enabled(value: bool) -> void:
	if value:
		self.set_physics_process(true)
		$CollisionPolygon2D.set_deferred("disabled", false)
	else:
		self.set_physics_process(false)
		$CollisionPolygon2D.set_deferred("disabled", true)
