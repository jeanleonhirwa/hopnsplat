extends Control

# Pause screen UI controller
# Handles pause menu interactions and display

@onready var score_label = $PausePanel/VBoxContainer/ScoreContainer/ScoreLabel
@onready var coins_label = $PausePanel/VBoxContainer/ScoreContainer/CoinsLabel
@onready var resume_button = $PausePanel/VBoxContainer/ButtonContainer/ResumeButton
@onready var restart_button = $PausePanel/VBoxContainer/ButtonContainer/RestartButton
@onready var menu_button = $PausePanel/VBoxContainer/ButtonContainer/MenuButton

signal resume_game
signal restart_game
signal return_to_menu

func _ready():
	# Hide pause screen initially
	visible = false
	
	# Style the buttons
	style_buttons()

func style_buttons():
	"""Apply modern styling to buttons"""
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = Color(0.2, 0.4, 0.8, 1.0)
	button_style.corner_radius_top_left = 10
	button_style.corner_radius_top_right = 10
	button_style.corner_radius_bottom_left = 10
	button_style.corner_radius_bottom_right = 10
	button_style.border_width_left = 2
	button_style.border_width_right = 2
	button_style.border_width_top = 2
	button_style.border_width_bottom = 2
	button_style.border_color = Color(0.1, 0.2, 0.4, 1.0)
	
	var button_hover_style = StyleBoxFlat.new()
	button_hover_style.bg_color = Color(0.3, 0.5, 0.9, 1.0)
	button_hover_style.corner_radius_top_left = 10
	button_hover_style.corner_radius_top_right = 10
	button_hover_style.corner_radius_bottom_left = 10
	button_hover_style.corner_radius_bottom_right = 10
	button_hover_style.border_width_left = 2
	button_hover_style.border_width_right = 2
	button_hover_style.border_width_top = 2
	button_hover_style.border_width_bottom = 2
	button_hover_style.border_color = Color(0.2, 0.3, 0.5, 1.0)
	
	# Apply styles to all buttons
	for button in [resume_button, restart_button, menu_button]:
		button.add_theme_stylebox_override("normal", button_style)
		button.add_theme_stylebox_override("hover", button_hover_style)
		button.add_theme_color_override("font_color", Color.WHITE)
		button.add_theme_font_size_override("font_size", 18)

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
