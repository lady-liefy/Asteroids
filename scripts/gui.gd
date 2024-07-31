extends Node

@export var score_counter : Label
@export var high_score_counter : Label

@onready var button_play_again = $CanvasLayer/MarginContainer/VBoxContainer/ButtonPlayAgain
@onready var button_resume = $CanvasLayer/MarginContainer/VBoxContainer/ButtonResume
@onready var button_exit = $CanvasLayer/MarginContainer/VBoxContainer/ButtonExit
@onready var button_quit_game = $CanvasLayer/MarginContainer/VBoxContainer/ButtonQuitGame
@onready var health_bar = $Health

@onready var scene_to_load = Preloads.scene_paths["Main_Menu"]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self._initialize_signals()
	self._initialize()

func _initialize_signals() -> void:
	ScoreManager.current_score_changed.connect(set_current_score)
	ScoreManager.high_score_changed.connect(set_high_score)
	Events.game_over.connect(_on_game_over)
	Events.game_paused.connect(_on_game_paused)
	Events.game_resumed.connect(_on_game_resumed)
	Events.health_changed.connect(set_health_bar)
	
func _initialize() -> void:
	set_current_score(0)
	set_high_score(ScoreManager.high_score)

func _physics_process(_delta : float) -> void:
	if Input.is_action_just_pressed("pause"):
		if not get_tree().is_paused():
			Events.game_paused.emit()
		else:
			Events.game_resumed.emit()

func set_current_score(value: int) -> void:
	self.score_counter.text = str(value)

func set_high_score(value: int) -> void:
	self.high_score_counter.text = str(value)

func set_health_bar(value) -> void:
	self.health_bar.set_value(value)

func _on_play_again_button_pressed() -> void:
	button_play_again.visible = false
	button_exit.visible = false
	Events.game_restarted.emit()

func _on_game_over() -> void:
	button_play_again.visible = true
	button_exit.visible = true
	button_quit_game.visible = true

func _on_game_paused() -> void:
	get_tree().paused = true
	button_resume.visible = true
	button_exit.visible = true
	button_quit_game.visible = true

func _on_game_resumed() -> void:
	get_tree().paused = false
	button_resume.visible = false
	button_exit.visible = false
	button_quit_game.visible = false

func _on_button_exit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_packed(scene_to_load)
	ScoreManager.set_current_score(0)

func _on_button_resume_pressed() -> void:
	Events.game_resumed.emit()

func _on_button_quit_game_pressed():
	get_tree().quit()
