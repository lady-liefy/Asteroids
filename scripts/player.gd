### player_movement.gd
extends CharacterBody2D
class_name Player

@export var jump_force = -320.0
@export var speed = 400.0
@export var rate_of_fire = 8
@export var points_per_bullet = 5

@onready var collision_shape_2d = $CollisionShape2D

var health = 100.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var bullet_scn = preload("res://scenes/bullet.tscn")

func _ready() -> void:
	self.velocity = Vector2.ZERO
	self._initialize_signals()

func _initialize_signals() -> void:
	Events.game_paused.connect(_on_game_paused)
	Events.game_resumed.connect(_on_game_resumed)

func _on_game_paused() -> void:
	self.set_enabled(false)
	get_tree().paused = true

func _on_game_resumed() -> void:
	self.set_enabled(true)
	get_tree().paused = false

var reload = 0

# ---------------------- PROCESSES -----------------------------------------------
func _physics_process(delta : float) -> void:
	if reload > 0:
		reload = (reload + 1) % rate_of_fire
	
	# Fall continuously because gravity
	if not is_on_floor():
		self.velocity.y += gravity * delta
	
	print(str(reload))
	# Handle input
	if Input.is_action_pressed("jump"):
		self.velocity.y = jump()
		self.velocity.y = min(self.velocity.y, speed)
	
	# Check for collision while moving
	var collision = move_and_collide(self.velocity * delta)
	
	if collision:
		var collider = collision.get_collider()
		if collider.get_name() == "Ceiling":
			move_and_collide(self.velocity * delta)
		else:
			self.die()
	else:
		move_and_collide(self.velocity * delta)

func _process(_delta : float) -> void:
	if health <= 0:
		self.die()

func take_damage(amount) -> void:
	health -= amount
	Events.emit_signal("health_changed", health)
#	if not %Pain.playing:
#		%Pain.play()

func jump() -> float:
	if reload == 0:
#		%MachineGun.play()
		shoot_bullet(Vector2(0, 5))
		shoot_bullet(Vector2(1,4))
		shoot_bullet(Vector2(-1,4))
		reload = (reload +1) % rate_of_fire
		
	return jump_force

func shoot_bullet(vector : Vector2) -> void:
	var bullet = bullet_scn.instantiate()
	bullet.velocity = vector
	bullet.position = Vector2(position.x - 14, position.y + 50)
	bullet.hit_obstacle.connect(on_score)
	get_parent().add_child(bullet)

func set_enabled(value: bool) -> void:
	if value:
		self.collision_shape_2d.set_deferred("disabled", false) # dis/enable collision
		self.set_process_unhandled_input(true) # idk what this does <3
		self.set_physics_process(true) # turn on/off _physics_process
		
	else:
		self.collision_shape_2d.set_deferred("disabled", true)
		self.set_process_unhandled_input(false)
		self.set_physics_process(false)

func on_score():
	ScoreManager.emit_signal("current_score_added")

func die() -> void:
	self.set_enabled(false)
	Events.emit_signal("game_over")
	get_tree().paused = true
#	self.animation_player.play("die")
#	self.death_sound.play()
