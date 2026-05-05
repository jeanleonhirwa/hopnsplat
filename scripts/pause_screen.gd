extends Control

# Pause screen UI controller
# Handles pause menu interactions and display

@onready var background = $Background
@onready var pause_panel = $PausePanel
@onready var title_label = $PausePanel/VBoxContainer/TitleLabel
@onready var divider1 = $PausePanel/VBoxContainer/Divider1
@onready var stats_container = $PausePanel/VBoxContainer/StatsContainer
@onready var divider2 = $PausePanel/VBoxContainer/Divider2
@onready var button_container = $PausePanel/VBoxContainer/ButtonContainer
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
	
	# Play entrance animation sequence
	_play_entrance_animation()

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


func _play_entrance_animation():
	"""Play the entrance animation sequence for the pause screen
	
	Animation sequence:
	1. Background fades in (0.2s)
	2. Panel zooms in with elastic easing (0.4s, scale from 0.5 to 1.0)
	3. Content elements fade in sequentially (0.15s each, 0.05s delay)
	
	Requirements: 7.3
	"""
	# Set initial states
	background.modulate.a = 0.0
	pause_panel.scale = Vector2(0.5, 0.5)
	title_label.modulate.a = 0.0
	divider1.modulate.a = 0.0
	stats_container.modulate.a = 0.0
	divider2.modulate.a = 0.0
	button_container.modulate.a = 0.0
	
	# 1. Background fades in (0.2s)
	# Note: UIAnimationManager.fade_in() doesn't support pause mode, so we create our own tween
	var background_tween = create_tween()
	background_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)  # Continue during pause
	UIAnimationManager.register_tween(background_tween)
	background_tween.tween_property(background, "modulate:a", 1.0, 0.2).set_ease(Tween.EASE_OUT)
	
	# 2. Panel zooms in with elastic easing (0.4s, scale from 0.5 to 1.0)
	var panel_tween = create_tween()
	panel_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)  # Continue during pause
	UIAnimationManager.register_tween(panel_tween)
	panel_tween.tween_property(pause_panel, "scale", Vector2(1.0, 1.0), 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	# 3. Content elements fade in sequentially (0.15s each, 0.05s delay)
	var content_elements = [
		title_label,
		divider1,
		stats_container,
		divider2,
		button_container
	]
	
	var delay = 0.0
	for element in content_elements:
		var fade_tween = create_tween()
		fade_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)  # Continue during pause
		UIAnimationManager.register_tween(fade_tween)
		fade_tween.tween_interval(delay)
		fade_tween.tween_property(element, "modulate:a", 1.0, 0.15).set_ease(Tween.EASE_OUT)
		delay += 0.05
