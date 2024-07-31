extends Node

@export var points_per_second = 10
@export var scroll_speed = 300

@onready var current_score : int = 0
@onready var high_score : int = 0

signal current_score_added(score_addition: int)
signal current_score_changed(new_score: int)
signal high_score_changed(new_high_score: int)
signal high_score_beaten

var was_high_score_beaten: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_initialize_signals()
	self.load_high_score()

func _initialize_signals() -> void:
#	Events.obstacle_zone_passed.connect(self.on_obstacle_zone_passed)
	Events.game_over.connect(self.on_game_over)
	Events.game_restarted.connect(self.on_game_restarted)
	current_score_added.connect(self.add_to_current_score)

func _physics_process(_delta) -> void:
	on_time_passed()

func on_game_over() -> void:
	self.save_high_score()

func on_game_restarted() -> void:
	self.set_current_score(0)
	was_high_score_beaten = false

func on_time_passed() -> void:
	self.current_score += 1
	self.emit_signal("current_score_changed", current_score)
	
	if self.current_score > self.high_score:
		self.set_high_score(self.current_score)
		
		if not was_high_score_beaten:
			self.high_score_beaten.emit()
		was_high_score_beaten = true

func set_current_score(value: int) -> void:
	self.current_score = value
	
func add_to_current_score(value: int) -> void:
	self.current_score += value

func set_high_score(value: int) -> void:
	self.high_score = value
	self.emit_signal("high_score_changed", self.high_score)


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
