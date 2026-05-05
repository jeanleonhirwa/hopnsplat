extends Control

# Pause screen UI controller
# Handles pause menu interactions and display

@onready var score_label = $PausePanel/VBoxContainer/StatsContainer/ScorePanel/HBoxContainer/ScoreLabel
@onready var coins_label = $PausePanel/VBoxContainer/StatsContainer/CoinsPanel/HBoxContainer/CoinsLabel
@onready var resume_button = $PausePanel/VBoxContainer/ButtonContainer/ResumeButton
@onready var settings_button = $PausePanel/VBoxContainer/ButtonContainer/SettingsButton
@onready var restart_button = $PausePanel/VBoxContainer/ButtonContainer/RestartButton
@onready var menu_button = $PausePanel/VBoxContainer/ButtonContainer/MenuButton

signal resume_game
signal restart_game
signal return_to_menu
signal open_settings

func _ready():
	# Hide pause screen initially
	visible = false

func show_pause_screen(current_score: int, current_coins: int):
	"""Display pause screen with current game stats"""
	score_label.text = "Score: " + str(current_score)
	coins_label.text = "Coins: " + str(current_coins)
	visible = true
	
	# Pause the game tree
	get_tree().paused = true

func hide_pause_screen():
	"""Hide pause screen and resume game"""
	visible = false
	get_tree().paused = false

func _on_resume_pressed():
	"""Resume button pressed"""
	hide_pause_screen()
	resume_game.emit()

func _on_settings_pressed():
	"""Settings button pressed"""
	open_settings.emit()

func _on_restart_pressed():
	"""Restart button pressed"""
	hide_pause_screen()
	restart_game.emit()

func _on_menu_pressed():
	"""Menu button pressed"""
	hide_pause_screen()
	return_to_menu.emit()

func _input(event):
	"""Handle input events"""
	if event.is_action_pressed("ui_cancel") and visible:
		_on_resume_pressed()
