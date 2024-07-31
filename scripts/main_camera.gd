### main_camera.gd
extends Camera2D
class_name MainCamera
 
# Target node the camera is following
@export var TargetNode : Node = null

func _process(_delta) -> void:
	if TargetNode is Player:
		set_position(TargetNode.character_body_2d.get_position())
	elif TargetNode is Node2D:
		set_position(TargetNode.get_position())

func set_target_node(new_target : Node) -> void:
	TargetNode = new_target
