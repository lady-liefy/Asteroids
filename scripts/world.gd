### World.gd
extends Node

@onready var player : Player = $Player
@onready var current_level : Node2D = $Level

var player_prefab = preload("res://scenes/player.tscn")

func _ready() -> void:
	reset()
	_initialize_signals()

func _initialize_signals() -> void:
	Events.player_died.connect(on_player_died)
	Events.level_won.connect(on_level_won)

func reset() -> void:
	clear_level()
	
	await get_tree().process_frame
	if not get_tree().get_nodes_in_group("Player"):
		spawn_player()


func clear_level() -> void:
#	if current_level != null and is_instance_valid(current_level):
#		current_level.queue_free()
	if is_instance_valid(player):
		player.queue_free()
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if is_instance_valid(enemy):
			enemy.queue_free()
	for bullet in get_tree().get_nodes_in_group("bullet"):
		if is_instance_valid(bullet):
			bullet.queue_free()
	for asteroid in get_tree().get_nodes_in_group("asteroid"):
		if is_instance_valid(asteroid):
			asteroid.queue_free()

func spawn_player() -> void:
	Global.respawning = true
	player = player_prefab.instantiate() as Player
	call_deferred("add_child", player)
	
	if not player.is_in_group("player"):
		player.add_to_group("player")
		
	player.position = Global.game_window_size / 2
	
	await get_tree().process_frame
	Global.respawning = false
	Events.emit_signal("player_respawned")

func on_player_died() -> void:
	await get_tree().process_frame
	player = null
	
	if ScoreManager.current_lives > 0:
		spawn_player()
	else:
		Events.emit_signal("game_over")
		Global.current_level_id = 0
		reset()

func on_level_won() -> void:
	await get_tree().process_frame
#	player.queue_free()
	player = null
	
	await Events.next_level
	reset()
