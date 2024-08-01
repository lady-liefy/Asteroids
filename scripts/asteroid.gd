### asteroid.gd
extends RigidBody2D
class_name Asteroid

enum Size { SMALL, MEDIUM, LARGE }

@export var size : Size = Size.LARGE
@export var speed : float = 400.0
@export var parts : int   = 4

signal broke(size , vel: Vector2)

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
	$Line2D.set_width(Global.asteroid_line_weight)
	
	self.set_enabled(true)

func _physics_process(_delta : float) -> void:
	Global.screen_wrap(self)

func set_velocity(base_vel : Vector2) -> void:
	var multiplier : int
	var direction := Vector2(randf_range(-1, 1), randf_range(-1, 1))
	
	if base_vel == Vector2.ZERO:
		multiplier = randf_range(Global.base_speed.x, Global.base_speed.y)
	else:
		multiplier = randf_range(Global.split_speed.x, Global.split_speed.y)
	
	linear_velocity = base_vel + (direction.normalized() * Global.speed_factor * multiplier)

func die() -> void:
	self.set_enabled(false)
	self.queue_free()
	broke.emit(self.size, linear_velocity)

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
