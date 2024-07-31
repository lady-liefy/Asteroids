extends CharacterBody2D
class_name Obstacle

@export var speed : float = 400.0

func _ready() -> void:
	self._initialize_signals()
	self.set_enabled(true)

func _initialize_signals() -> void:
	Events.game_paused.connect(on_game_paused)
	Events.game_over.connect(on_game_over)
	Events.game_restarted.connect(on_game_restarted)
	Events.game_resumed.connect(on_game_resumed)


func _physics_process(delta : float) -> void:
	var collision = move_and_collide(Vector2.LEFT * speed * delta)
	if collision:
		var collider = collision.get_collider()
		if collider.has_method("take_damage"):
			collider.take_damage(20)
			die()


func take_damage(amount) -> void:
	die()

func die() -> void:
	self.set_enabled(false)
#	%Explosion.play()
	$CollisionShape2D.disabled = true
	visible = false
#	await %Explosion.finished
	queue_free()


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
	else:
		self.set_physics_process(false)
