extends Node

var scene_to_load : PackedScene
var scene_paths = {
	"World": preload("res://scenes/world.tscn"),
	"Main_Menu": preload("res://scenes/main_menu.tscn")
}

func _init() -> void:
	pass
#	for scene in scene_paths:
#		var path = scene_paths[scene]
