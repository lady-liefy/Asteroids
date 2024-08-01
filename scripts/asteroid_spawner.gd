### asteroidspawner.gd
extends Node
class_name AsteroidSpawner

@export var group_name: String
@export var speed: float

var asteroid_1_scn = preload("res://scenes/asteroid_1.tscn")
var asteroid_2_scn = preload("res://scenes/asteroid_2.tscn")
var asteroid_3_scn = preload("res://scenes/asteroid_3.tscn")

signal spawn(obstacle)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self._initialize_signals()
	self._initialize()

func _initialize_signals() -> void:
	Events.game_paused.connect(on_game_paused)
	Events.game_over.connect(on_game_over)
	Events.game_restarted.connect(on_game_restarted)
	Events.game_resumed.connect(on_game_resumed)
	Events.next_level.connect(on_next_level)

func _initialize() -> void:
	set_enabled(true)
	
	for i in 4:
		spawn_asteroid(Asteroid.Size.LARGE, Global._random_valid_vector2(), Vector2.ZERO)
		spawn_asteroid(Asteroid.Size.MEDIUM, Global._random_valid_vector2(), Vector2.ZERO)
		spawn_asteroid(Asteroid.Size.SMALL, Global._random_valid_vector2(), Vector2.ZERO)

func spawn_asteroid(size : Asteroid.Size, new_pos : Vector2, new_vel : Vector2) -> void:
	# Only runs in debug; confirms that size is one of the options
	assert(size == Asteroid.Size.SMALL or size == Asteroid.Size.MEDIUM or size == Asteroid.Size.LARGE)
	
	var asteroid : Asteroid
	match size:
		Asteroid.Size.LARGE:
			asteroid = asteroid_1_scn.instantiate()
		Asteroid.Size.MEDIUM:
			asteroid = asteroid_2_scn.instantiate()
		Asteroid.Size.SMALL:
			asteroid = asteroid_3_scn.instantiate()
	
	call_deferred("add_child", asteroid)
	asteroid.set_linear_velocity(new_vel)
	asteroid.global_position = new_pos
	
	var _d = asteroid.connect("broke", Callable(self, "_on_Asteroid_broke"))
	
	if group_name:
		asteroid.add_to_group(group_name)
	
	spawn.emit(asteroid)

func on_asteroid_broke(size, new_pos : Vector2, new_vel : Vector2) -> void:
	await get_tree().process_frame
	
	if size > Asteroid.Size.SMALL:
		spawn_asteroid(size - 1, new_pos, new_vel)
		spawn_asteroid(size - 1, new_pos, new_vel)
		if randi() % 3 == 1:
			spawn_asteroid(size - 1, new_pos, new_vel)

func on_next_level():
	for i in Global.asteroids_to_spawn:
		spawn_asteroid(Asteroid.Size.LARGE, Global._random_valid_vector2(), Vector2.ZERO)
		

func set_enabled(value: bool) -> void:
	if value:
		get_tree().paused = false
	else:
		get_tree().paused = true

func on_game_paused() -> void:
	self.set_enabled(false)

func on_game_over() -> void:
	self.set_enabled(false)

func on_game_restarted() -> void:
	self.set_enabled(true)

func on_game_resumed() -> void:
	self.set_enabled(true)
