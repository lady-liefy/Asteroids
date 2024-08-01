extends Node2D
class_name MainMenu

@export var game_title : Label

@onready var scene_to_load : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	game_title.text = ProjectSettings.get("application/config/name")
	$MarginContainer/VBoxContainer/ButtonPlay.grab_focus()
	Global._reset()

func _on_button_quit_pressed():
	get_tree().quit()

func _on_button_play_pressed():
	get_tree().paused = false
	scene_to_load = load("res://scenes/world.tscn")
	get_tree().change_scene_to_packed(self.scene_to_load)
