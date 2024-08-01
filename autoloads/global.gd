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

func _ready() -> void:
	_initialize_signals()

func _initialize_signals() -> void:
	Events.level_won.connect(on_level_won)
	Events.game_over.connect(on_game_over)

func _reset() -> void:
	ScoreManager.set_current_score(0)
	ScoreManager.set_current_lives(starting_lives)

func on_game_over() -> void:
	get_tree().paused = true
	_reset()

func on_level_won() -> void:
	current_level_id += 1

# Function to wrap objects around the screen (ship, bullets)
func screen_wrap(body : Node2D) -> void:
	if body.global_position.x < 0:
		body.global_position += Vector2(Global.game_window_size.x, 0)
	elif body.global_position.x > Global.game_window_size.x:
		body.global_position -= Vector2(Global.game_window_size.x, 0)
	if body.global_position.y < 0:
		body.global_position += Vector2(0, Global.game_window_size.y)
	elif body.global_position.y > Global.game_window_size.y:
		body.global_position -= Vector2(0, Global.game_window_size.y)

func _random_valid_vector2() -> Vector2:
	randomize()
	var vector = Vector2(randf_range(64, Global.game_window_size.x - 64), randf_range(64, Global.game_window_size.y - 64))
#	while !respawning and (vector - $Player.transform.origin).length() < 512:
#		vector = Vector2(randf_range(64, Global.game_window_size.x - 64), randf_range(64, Global.game_window_size.y - 64))
	
	return vector
