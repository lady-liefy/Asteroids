### player.gd
extends CharacterBody2D
class_name Player

@export var speed := 250
@export var boost_speed := 300
@export var rotation_speed := 2.5
@export var friction := 0.1

@export var rate_of_fire = 0.1
@export var max_bullets = 4

@export var bullet_scn : Resource

@onready var collision_shape_2d = $CollisionPolygon2D

var aim_direction = 0

var is_boosting = false
var is_invincible = true
var can_shoot = true
var vel := Vector2.ZERO

func _ready() -> void:
	self._initialize()
	self._initialize_signals()

func _initialize_signals() -> void:
	Events.game_paused.connect(_on_game_paused)
	Events.game_resumed.connect(_on_game_resumed)

func _initialize() -> void:
	self.set_velocity(Vector2.ZERO)
	vel = Vector2.ZERO
	
	$Line2D.set_default_color(Global.line_color)
	$Line2D.set_width(Global.ship_line_weight)
	
	$ShotTimer.set_wait_time(rate_of_fire)
	await get_tree().create_timer(2.0).timeout
	is_invincible = false
	is_boosting = false
	can_shoot = true

func _on_game_paused() -> void:
	self.set_enabled(false)
	get_tree().set_pause(true)

func _on_game_resumed() -> void:
	self.set_enabled(true)
	get_tree().set_pause(false)

# ---------------------- PROCESSES -----------------------------------------------
func _physics_process(delta : float) -> void:
	# Movement
	self.rotation += aim_direction * rotation_speed * delta
	
	# Transform is vector pointing Forward; handy!
	set_velocity(vel * (1 - friction) + _process_inputs())
	Global.screen_wrap(self)
	
	# Check for collision while moving
	var collision = move_and_collide(self.velocity * delta)
	if collision:
		self.die()

func _process_inputs() -> Vector2:
	# Left & Right
	aim_direction = Input.get_axis("rotate_left", "rotate_right")
	
	# Forward thrust
	var new_vel = Vector2.ZERO
	if Input.is_action_pressed("thrust"):
		new_vel += transform.x * speed * Global.speed_factor
		if not is_boosting:
			is_boosting = true
#			$ThrustAnimation.play("Thrust")
#			$ThrustSound.stream_paused = false
	elif is_boosting:
		is_boosting = false
#		$ThrustAnimation.play("Idle")
#		$ThrustSound.stream_paused = true
	return new_vel
	
	if Input.is_action_just_pressed("boost"):
		boost()
	
	if Input.is_action_pressed("fire"):
		if not get_tree().get_nodes_in_group("bullet").size() >= max_bullets \
		and can_shoot:
			shoot_bullet(transform.x)

func boost() -> void:
	print("boost!")
	pass

func shoot_bullet(direction : Vector2) -> void:
	can_shoot = false
	$ShotTimer.start(rate_of_fire / Global.speed_factor)
	
	var bullet = bullet_scn.instantiate() as Bullet
	get_parent().call_deferred("add_child", bullet)
	bullet.linear_velocity = direction * bullet.SPEED + velocity 
	bullet.global_position = self.global_position + (direction * 38)

func set_enabled(value: bool) -> void:
	if value:
		self.collision_shape_2d.set_deferred("disabled", false)
		self.set_process_unhandled_input(true)
		self.set_physics_process(true)
		
	else:
		self.collision_shape_2d.set_deferred("disabled", true)
		self.set_process_unhandled_input(false)
		self.set_physics_process(false)

func on_score():
	ScoreManager.emit_signal("current_score_added")

func die() -> void:
	self.set_enabled(false)
	
	await get_tree().create_timer(0.7).timeout
	Events.emit_signal("player_died")
	
	self.queue_free()

func _on_shot_timer_timeout():
	can_shoot = true
