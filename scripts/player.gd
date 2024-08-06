### player.gd
extends RigidBody2D
class_name Player

@export var ship_thrust := 400
@export var boost_thrust := 800
@export var rotate_thrust := 18000
@export var friction := 0.05

@export_category("Shooting")
@export var rate_of_fire := 0.1
@export var max_bullets := 4
@export var bullet_scn : Resource  # how to get a PackedScene

@onready var collision_shape_2d = $CollisionPolygon2D

var aim_direction = 0
var is_boosting = false
var is_invincible = true
var can_shoot = true
var acceleration := Vector2.ZERO

func _ready() -> void:
	self._initialize_signals()
	self._initialize()

func _initialize_signals() -> void:
	Events.game_paused.connect(_on_game_paused)
	Events.game_resumed.connect(_on_game_resumed)

func _initialize() -> void:
	$Line2D.set_default_color(Global.line_color)
	$Line2D.set_width(Global.ship_line_weight)	
	$ShotTimer.set_wait_time(rate_of_fire)
	is_boosting = false
	
	await get_tree().create_timer(2.0).timeout
	is_invincible = false
	can_shoot = true
	
func _on_game_paused() -> void:
	self.set_enabled(false)
	get_tree().set_pause(true)

func _on_game_resumed() -> void:
	self.set_enabled(true)
	get_tree().set_pause(false)

# ---------------------- PROCESSES -----------------------------------------------
# Alternative to _physics_process for RigidBodies
func _integrate_forces(state : PhysicsDirectBodyState2D) -> void:
	_process_inputs()
	state.apply_force(acceleration * Global.speed_factor) # Move forward
	state.apply_torque(aim_direction * rotate_thrust * Global.speed_factor)  # Rotate
	
	Global.screen_wrap(self, state)

func _process_inputs() -> void:
	## Boosting
	if Input.is_action_just_pressed("boost"):
		is_boosting = true
	elif Input.is_action_just_released("boost"):
		is_boosting = false
	
	## Shooting
	if Input.is_action_pressed("fire"):
		if not get_tree().get_nodes_in_group("bullet").size() >= max_bullets \
		and can_shoot:
			shoot_bullet(transform.x)
	
	## Movement
	# Left & Right
	aim_direction = Input.get_axis("rotate_left", "rotate_right")
	
	# Forward thrust
	if Input.is_action_pressed("thrust") and not is_boosting:
		acceleration = transform.x * ship_thrust
	elif Input.is_action_pressed("thrust") and is_boosting:
		acceleration = transform.x * boost_thrust
	else:
		acceleration = Vector2.ZERO

func shoot_bullet(direction : Vector2) -> void:
	can_shoot = false
	$ShotTimer.start(rate_of_fire / Global.speed_factor)
	
	var bullet = bullet_scn.instantiate() as Bullet
	
	get_parent().call_deferred("add_child", bullet)
	bullet.global_position = self.global_position + (direction * 38)
	bullet.set_linear_velocity(direction * bullet.SPEED + self.linear_velocity)

func set_enabled(value: bool) -> void:
	if value:
		self.collision_shape_2d.set_deferred("disabled", false)
		self.set_process_unhandled_input(true)
		self.set_physics_process(true)
	else:
		self.collision_shape_2d.set_deferred("disabled", true)
		self.set_process_unhandled_input(false)
		self.set_physics_process(false)

func die() -> void:
	self.set_enabled(false)
	Events.emit_signal("player_died")
	
	self.queue_free()

func _on_shot_timer_timeout() -> void:
	can_shoot = true

func _on_body_entered(body : Node2D) -> void:
	if is_invincible:
		return
	
	if body.is_in_group("asteroid"):
		self.die()
