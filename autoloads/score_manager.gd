### score_manager.gd
extends Node

@export var points_per_second = 10
@export var scroll_speed = 300

@export var points_comet_large = 250
@export var points_comet_medium = 100
@export var points_comet_small = 25
@export var points_comet_dead = 1000

@export var points_enemy_part = 150					# all 4 parts = 600 points
@export var points_life_left = 200

@export var points_for_new_life = 10000				# New life at 10,000 points

@onready var current_score : int = 0
@onready var high_score : int = 0
@onready var current_lives : int = Global.starting_lives

signal current_lives_changed(new_lives: int)
signal current_score_changed(new_score: int)
signal high_score_changed(new_high_score: int)
signal high_score_beaten

var was_high_score_beaten: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_initialize_signals()
	self.load_high_score()

func _initialize_signals() -> void:
	Events.game_over.connect(self.on_game_over)
	Events.game_restarted.connect(self.on_game_restarted)
	Events.player_died.connect(self.on_player_died)

func _physics_process(_delta) -> void:
	pass

func on_player_died() -> void:
	if current_lives >= 0:
		self.subtract_life()
	else:
		self.set_current_lives(0)

func on_game_over() -> void:
	self.save_high_score()

func on_game_restarted() -> void:
	self.set_current_score(0)
	was_high_score_beaten = false

func set_current_lives(value: int) -> void:
	self.current_lives = value
	self.emit_signal("current_lives_changed", self.current_lives)

func subtract_life() -> void:
	self.current_lives -= 1
	self.emit_signal("current_lives_changed", current_lives)

func set_current_score(value: int) -> void:
	self.current_score = value
	new_life_check()
	self.emit_signal("current_score_changed", current_score)

func add_to_current_score(value: int) -> void:
	self.current_score += value
	new_life_check()
	self.emit_signal("current_score_changed", current_score)

func set_high_score(value: int) -> void:
	self.high_score = value
	self.emit_signal("high_score_changed", self.high_score)

func new_life_check() -> void:
	# Gain a life at 20,000 points
	if current_score == points_for_new_life:
		set_current_lives(current_lives + 1)

## SAVE & LOAD -------------------------------------------------
var save_file_path: String = "user://save_game.bin"

func save_high_score():
	var _file = FileAccess.open(self.save_file_path, FileAccess.WRITE)
	_file.store_32(self.high_score)
	_file.close()

func load_high_score():
	if not FileAccess.file_exists(self.save_file_path):
		self.set_high_score(0)
		return
	
	var _file: FileAccess = FileAccess.open(self.save_file_path, FileAccess.READ)
	self.set_high_score( int(_file.get_32()) )
	_file.close()
