extends Node
class_name ObstacleManager

@export var group_name: String
@export var speed: float
@export_range(0.1, 10.0) var min_spawn: float
@export_range(0.1, 10.0) var max_spawn: float
@export var spawn_height: Callable
@export var spawn_rate: Callable

@onready var spawn_timer = $SpawnTimer

var obstacle_scn = preload("res://scenes/obstacle.tscn")

signal spawn(obstacle)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_timer.autostart = true
	self._initialize_signals()
	set_enabled(true)

func _initialize_signals() -> void:
	spawn_timer.timeout.connect(spawn_obstacle)
	
	Events.game_paused.connect(on_game_paused)
	Events.game_over.connect(on_game_over)
	Events.game_restarted.connect(on_game_restarted)
	Events.game_resumed.connect(on_game_resumed)

func spawn_obstacle() -> void:
	var obstacle = obstacle_scn.instantiate()
	var viewport_rect = get_viewport().get_camera_2d().get_viewport_rect()
	obstacle.position.x = viewport_rect.end.x
	
	randomize()
	obstacle.position.y = randf_range(viewport_rect.size.y / 2, viewport_rect.size.y * 0.65)
	
	obstacle.add_to_group("obstacles")
	if group_name:
		obstacle.add_to_group(group_name)
	add_child(obstacle)
	spawn.emit(obstacle)

func set_enabled(value: bool) -> void:
	if value:
		if not spawn_timer.autostart or spawn_timer.is_stopped():
			spawn_timer.start()
		if spawn_timer.paused:
			spawn_timer.paused = false
	else:
		spawn_timer.paused = true

func on_game_paused() -> void:
	self.set_enabled(false)

func on_game_over() -> void:
	self.set_enabled(false)

func on_game_restarted() -> void:
	self.set_enabled(true)

func on_game_resumed() -> void:
	self.set_enabled(true)
