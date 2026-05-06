extends Control

# Main Menu System for Hop n' Splat
# Designed for accessibility and ease of use for all ages

# Scene references
@export var game_scene: PackedScene = preload("res://scenes/Main.tscn")

# UI Enhancement Systems
var enhanced_ui_manager
var responsive_layout

# UI Node references
@onready var title_label = $VBoxContainer/TitleLabel
@onready var play_button = $VBoxContainer/ButtonContainer/PlayButton
@onready var shop_button = $VBoxContainer/ButtonContainer/ShopButton
@onready var achievements_button = $VBoxContainer/ButtonContainer/AchievementsButton
@onready var settings_button = $VBoxContainer/ButtonContainer/SettingsButton
@onready var quit_button = $VBoxContainer/ButtonContainer/QuitButton
@onready var high_score_label = $VBoxContainer/StatsPanel/VBoxContainer/HighScoreContainer/HighScoreLabel
@onready var currency_label = $VBoxContainer/StatsPanel/VBoxContainer/CurrencyContainer/CurrencyLabel
@onready var stats_panel = $VBoxContainer/StatsPanel

# Decorative elements
@onready var floating_star1 = $BackgroundDecoration/FloatingStar1
@onready var floating_star2 = $BackgroundDecoration/FloatingStar2
@onready var decorative_arrow = $BackgroundDecoration/DecorativeArrow

# Animation and effects
@onready var background_animation = $BackgroundDecoration
@onready var button_hover_sound = $ButtonHoverSound
@onready var button_click_sound = $ButtonClickSound

# Settings panel (optional)
@onready var settings_panel = null

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
	
	# Start background music
	AudioManager.play_background_music()
	
	print("Main Menu initialized")

func load_and_display_stats():
	"""Load and display high score and currency"""
	var save_data = load_game_data()
	
	if high_score_label:
		var high_score = save_data.get("highest_score", 0)
		# Use count-up animation for high score with prefix
		_count_up_with_prefix(high_score_label, "Best Score: ", 0, high_score, 0.8)
	
	if currency_label:
		var total_currency = save_data.get("total_currency", 0)
		# Use count-up animation for currency with prefix and bounce effect
		_count_up_with_prefix(currency_label, "Coins: ", 0, total_currency, 1.0)
		# Add bounce effect when currency increases
		if total_currency > 0:
			await get_tree().create_timer(0.5).timeout
			UIAnimationManager.bounce_in(currency_label, 0.2, 1.15)


func _count_up_with_prefix(label: Label, prefix: String, from: int, to: int, duration: float):
	"""Helper function to count up a label value while preserving a prefix"""
	var tween = create_tween()
	var counter = {"value": from}
	
	tween.tween_property(counter, "value", to, duration).set_ease(Tween.EASE_OUT)
	
	# Update label text during animation
	var update_interval = 0.05  # Update every 50ms
	var steps = int(duration / update_interval)
	for i in range(steps + 1):
		tween.tween_callback(func(): 
			var progress = float(i) / float(steps)
			var current_value = lerp(float(from), float(to), progress)
			label.text = prefix + str(int(current_value))
		).set_delay(update_interval * i)
	
	# Ensure final value is exact
	tween.tween_callback(func(): label.text = prefix + str(to))

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
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	
	if shop_button:
		shop_button.pressed.connect(_on_shop_pressed)
	
	if achievements_button:
		achievements_button.pressed.connect(_on_achievements_pressed)
	
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

func start_animations():
	"""Start background animations and effects"""
	# Animate decorative elements with floating motion
	animate_decorative_elements()
	
	# Animate buttons with staggered entrance (Task 5.4)
	animate_buttons_entrance_staggered()


func animate_decorative_elements():
	"""Animate floating stars and decorative arrow with subtle motion"""
	if floating_star1:
		# Use UIAnimationManager for floating animation
		var tween1 = create_tween()
		tween1.set_loops()
		var original_y1 = floating_star1.position.y
		tween1.tween_property(floating_star1, "position:y", original_y1 - 15, 2.5).set_ease(Tween.EASE_IN_OUT)
		tween1.tween_property(floating_star1, "position:y", original_y1 + 15, 2.5).set_ease(Tween.EASE_IN_OUT)
	
	if floating_star2:
		# Use UIAnimationManager for floating animation
		var tween2 = create_tween()
		tween2.set_loops()
		var original_y2 = floating_star2.position.y
		tween2.tween_property(floating_star2, "position:y", original_y2 - 20, 3.0).set_ease(Tween.EASE_IN_OUT)
		tween2.tween_property(floating_star2, "position:y", original_y2 + 20, 3.0).set_ease(Tween.EASE_IN_OUT)
	
	if decorative_arrow:
		# Use UIAnimationManager for gentle rotation
		var tween3 = create_tween()
		tween3.set_loops()
		var original_rotation = decorative_arrow.rotation_degrees
		tween3.tween_property(decorative_arrow, "rotation_degrees", original_rotation - 5, 1.5).set_ease(Tween.EASE_IN_OUT)
		tween3.tween_property(decorative_arrow, "rotation_degrees", original_rotation + 5, 1.5).set_ease(Tween.EASE_IN_OUT)


func animate_title():
	"""Animate the title with gentle floating motion"""
	if title_label:
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(title_label, "position:y", title_label.position.y - 10, 2.0)
		tween.tween_property(title_label, "position:y", title_label.position.y + 10, 2.0)


func animate_buttons_entrance_staggered():
	"""Animate buttons and UI elements appearing with staggered timing (Task 5.4)
	Timeline from design:
	- Background fade in (0.3s) - already visible
	- Title drop with bounce (0.4s, starts at 0.1s)
	- Stats panel slide in (0.3s, starts at 0.3s)
	- Stagger button appearances (0.2s each, starting at 0.6s with 0.1s delays)
	- Start PlayButton wobble loop after stagger complete
	"""
	# Title drop with bounce (starts at 0.1s)
	if title_label:
		title_label.position.y -= 50
		title_label.modulate.a = 0.0
		await get_tree().create_timer(0.1).timeout
		UIAnimationManager.fade_in(title_label, 0.2)
		UIAnimationManager.slide_in(title_label, Vector2.UP, 0.4, 50)
	
	# Stats panel slide in (starts at 0.3s)
	if stats_panel:
		stats_panel.modulate.a = 0.0
		await get_tree().create_timer(0.2).timeout  # 0.3s total from start
		UIAnimationManager.fade_in(stats_panel, 0.2)
		UIAnimationManager.slide_in(stats_panel, Vector2.LEFT, 0.3, 100)
	
	# Stagger button appearances (starting at 0.6s with 0.1s delays)
	var buttons = [play_button, shop_button, achievements_button, settings_button, quit_button]
	await get_tree().create_timer(0.3).timeout  # 0.6s total from start
	
	for button in buttons:
		if button:
			# Start invisible and scale down
			button.modulate.a = 0.0
			button.scale = Vector2(0.8, 0.8)
			
			# Animate in with bounce
			UIAnimationManager.fade_in(button, 0.2)
			UIAnimationManager.bounce_in(button, 0.2, 1.25)
			
			# Wait before next button
			await get_tree().create_timer(0.1).timeout
	
	# Start PlayButton wobble loop after all buttons appear
	await get_tree().create_timer(0.2).timeout
	if play_button and play_button.has_method("play_idle_wobble"):
		play_button.play_idle_wobble()


func animate_buttons_entrance():
	"""Legacy method - replaced by animate_buttons_entrance_staggered"""
	pass

func _on_button_hover():
	"""Play hover sound effect - now handled by KenneyButton component"""
	# This method is no longer needed as KenneyButton handles hover sounds
	pass

func _on_play_pressed():
	"""Handle play button press"""
	print("Play button pressed")
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

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
	# KenneyButton already plays click sound
	show_settings_panel()

func _on_quit_pressed():
	"""Quit the game"""
	print("Quit button pressed")
	# KenneyButton already plays click sound
	
	# Wait for animation then quit
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()

func animate_button_press(_button: Button):
	"""Animate button press with scale effect - now handled by KenneyButton"""
	# This method is no longer needed as KenneyButton handles press animations
	pass

func show_settings_panel():
	"""Show game settings menu"""
	# Try new comprehensive settings first
	var game_settings = $GameSettingsMenu
	if game_settings:
		game_settings.show_settings()
		print("Showing game settings from main menu")
		return
	
	# Fallback to audio settings
	var audio_settings = $AudioSettingsMenu
	if audio_settings:
		audio_settings.visible = true
		print("Showing audio settings from main menu")

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
