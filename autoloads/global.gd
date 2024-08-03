### global.gd
extends Node

var scene_paths = {
	"World": preload("res://scenes/world.tscn"),
	"Main_Menu": preload("res://scenes/main_menu.tscn")
}
var scene_to_load : PackedScene
var current_level_id : int = 0
var game_window_size := DisplayServer.window_get_size()

var line_color: Color = Color.WHITE
var asteroid_line_weight: float = 4.0
var ship_line_weight: float = 2.0

var split_speed := Vector2.ONE
var base_speed := Vector2.ONE
var speed_factor := 1.0

var starting_lives : int = 3
var asteroids_to_spawn : int = 3
var respawning := false

func _ready() -> void:
	_initialize_signals()

func _initialize_signals() -> void:
	Events.level_won.connect(on_level_won)
	Events.game_over.connect(on_game_over)

func _reset() -> void:
	ScoreManager.set_current_score(0)
	ScoreManager.set_current_lives(starting_lives)
	respawning = false

func on_game_over() -> void:
	get_tree().paused = true
	_reset()

func on_level_won() -> void:
	current_level_id += 1

# Function to wrap objects around the screen (ship, bullets)
func screen_wrap(body : RigidBody2D, state : PhysicsDirectBodyState2D) -> void:
	if body.global_position.x < 0:
		state.transform.origin.x = game_window_size.x
	elif body.global_position.x > game_window_size.x:
		state.transform.origin.x = 0
	if body.global_position.y < 0:
		state.transform.origin.y = game_window_size.y
	elif body.global_position.y > game_window_size.y:
		state.transform.origin.y = 0
