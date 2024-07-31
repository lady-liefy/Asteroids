extends Area2D

var group_name : String = "obstacles"

func _on_body_entered(body):
	if body.is_in_group(group_name):
		body.queue_free()
