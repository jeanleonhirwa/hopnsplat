extends Control

# Main Menu System for Hop n' Splat
# Designed for accessibility and ease of use for all ages

# Scene references
@export var game_scene: PackedScene = preload("res://scenes/Main.tscn")

# UI Node references
@onready var title_label = $VBoxContainer/TitleLabel
@onready var shop_button = $VBoxContainer/ButtonContainer/ShopButton
@onready var achievements_button = $VBoxContainer/ButtonContainer/AchievementsButton
@onready var settings_button = $VBoxContainer/ButtonContainer/SettingsButton
@onready var quit_button = $VBoxContainer/ButtonContainer/QuitButton
@onready var high_score_label = $VBoxContainer/HighScoreLabel
@onready var currency_label = $VBoxContainer/CurrencyLabel

# Animation and effects
@onready var background_animation = $BackgroundAnimation
@onready var button_hover_sound = $ButtonHoverSound
@onready var button_click_sound = $ButtonClickSound

# Settings panel (optional)
@onready var settings_panel = $SettingsPanel

func _ready():
	"""Initialize main menu"""
	# Load and display saved data
	load_and_display_stats()
	
	# Connect button signals
	connect_buttons()
	
	# Start background animations
	start_animations()
	
	# Set initial focus for keyboard/controller navigation
	shop_button.grab_focus()
	
	print("Main Menu initialized")

func load_and_display_stats():
	"""Load and display high score and currency"""
	var save_data = load_game_data()
	
	if high_score_label:
		var high_score = save_data.get("highest_score", 0)
		high_score_label.text = "🏆 Best Score: " + str(high_score)
	
	if currency_label:
		var total_currency = save_data.get("total_currency", 0)
		currency_label.text = "💰 Coins: " + str(total_currency)

func load_game_data() -> Dictionary:
	"""Load game data from save file"""
	var save_file = FileAccess.open("user://hopnsplat_save.dat", FileAccess.READ)
	if save_file:
		var save_data_text = save_file.get_as_text()
		save_file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(save_data_text)
		if parse_result == OK:
			return json.data
	
	return {"highest_score": 0, "total_currency": 0}

func connect_buttons():
	"""Connect all button signals"""
	if shop_button:
		shop_button.pressed.connect(_on_shop_pressed)
		shop_button.mouse_entered.connect(_on_button_hover)
	
	if achievements_button:
		achievements_button.pressed.connect(_on_achievements_pressed)
		achievements_button.mouse_entered.connect(_on_button_hover)
	
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
		settings_button.mouse_entered.connect(_on_button_hover)
	
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
		quit_button.mouse_entered.connect(_on_button_hover)

func start_animations():
	"""Start background animations and effects"""
	if background_animation:
		# Create floating animation for title
		animate_title()
		
	# Animate buttons with staggered entrance
	animate_buttons_entrance()

func animate_title():
	"""Animate the title with gentle floating motion"""
	if title_label:
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(title_label, "position:y", title_label.position.y - 10, 2.0)
		tween.tween_property(title_label, "position:y", title_label.position.y + 10, 2.0)

func animate_buttons_entrance():
	"""Animate buttons appearing with staggered timing"""
	var buttons = [shop_button, achievements_button, settings_button, quit_button]
	var delay = 0.0
	
	for button in buttons:
		if button:
			# Start invisible and scale down
			button.modulate.a = 0.0
			button.scale = Vector2(0.8, 0.8)
			
			# Animate in with delay
			await get_tree().create_timer(delay).timeout
			var tween = create_tween()
			tween.tween_property(button, "modulate:a", 1.0, 0.3)
			tween.parallel().tween_property(button, "scale", Vector2(1.0, 1.0), 0.3)
			
			delay += 0.1

func _on_button_hover():
	"""Play hover sound effect"""
	if button_hover_sound:
		button_hover_sound.play()

func _on_shop_pressed():
	"""Handle shop button press"""
	print("Shop button pressed")
	get_tree().change_scene_to_file("res://scenes/Shop.tscn")

func _on_achievements_pressed():
	"""Handle achievements button press"""
	print("Achievements button pressed")
	get_tree().change_scene_to_file("res://scenes/Achievements.tscn")

func _on_settings_pressed():
	"""Open settings panel"""
	print("Settings button pressed")
	if button_click_sound:
		button_click_sound.play()
	
	animate_button_press(settings_button)
	show_settings_panel()

func _on_quit_pressed():
	"""Quit the game"""
	print("Quit button pressed")
	if button_click_sound:
		button_click_sound.play()
	
	animate_button_press(quit_button)
	
	# Wait for animation then quit
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()

func animate_button_press(button: Button):
	"""Animate button press with scale effect"""
	if button:
		var tween = create_tween()
		tween.tween_property(button, "scale", Vector2(0.95, 0.95), 0.1)
		tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)

func show_settings_panel():
	"""Show settings panel (placeholder for now)"""
	if settings_panel:
		settings_panel.visible = true
		
		# Simple fade in animation
		settings_panel.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(settings_panel, "modulate:a", 1.0, 0.3)
	else:
		# Placeholder - just show a simple dialog
		print("Settings panel not implemented yet")

func hide_settings_panel():
	"""Hide settings panel"""
	if settings_panel and settings_panel.visible:
		var tween = create_tween()
		tween.tween_property(settings_panel, "modulate:a", 0.0, 0.3)
		tween.tween_callback(func(): settings_panel.visible = false)

func refresh_stats():
	"""Refresh displayed stats (called when returning from game)"""
	load_and_display_stats()

# Handle input for accessibility
func _input(event):
	"""Handle keyboard input for accessibility"""
	if event.is_action_pressed("ui_accept"):
		# Enter key pressed - activate focused button
		var focused_control = get_viewport().gui_get_focus_owner()
		if focused_control is Button:
			focused_control.pressed.emit()
	
	elif event.is_action_pressed("ui_cancel"):
		# Escape key - hide settings if open
		if settings_panel and settings_panel.visible:
			hide_settings_panel()
