### level.gd
extends Node
class_name SceneMain

var group_name : String

func _ready() -> void:
	self._initialize_signals()

func _initialize_signals() -> void:
	Events.game_restarted.connect(self.on_game_restarted)

func on_game_restarted() -> void:
	get_tree().paused = false
	
	get_tree().reload_current_scene()
