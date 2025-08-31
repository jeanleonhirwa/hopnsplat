extends Node2D

# Game Management System
signal score_changed(new_score)
signal currency_changed(new_currency)
signal successful_jump
signal game_over

# Node references
@onready var player = $Player
@onready var camera = $Camera2D
@onready var platform_spawner = $PlatformSpawner
@onready var rising_danger = $RisingDanger

# UI elements and systems (will be initialized in _ready)
var ui_layer: CanvasLayer
var score_label: Label
var currency_label: Label
var combo_label: Label
var pause_button: Button
var pause_screen: Control
var audio_settings_menu: Control

# Power-up system references (optional - may not exist)
var power_up_spawner: Node2D
var advanced_power_ups: Node
var power_up_ui: Control

# Visual effects systems
var visual_feedback: Node2D
var platform_animations: Node2D
var ui_animations: Node2D
var power_up_effects: Node2D

# Advanced power-up systems
var boost_ui: Control

# Score and Currency System
var current_score: int = 0
var total_currency: int = 0  # Persistent currency for purchases
var session_currency: int = 0  # Currency earned this session

# Scoring Configuration
@export var points_per_jump: int = 5
@export var currency_per_jump: int = 1
@export var bonus_multiplier_threshold: int = 10  # Bonus every 10 jumps
@export var bonus_points: int = 25
@export var bonus_currency: int = 3

# Game State
enum GameState { PLAYING, GAME_OVER, PAUSED }
var current_game_state: GameState = GameState.PLAYING
var consecutive_jumps: int = 0
var highest_platform_reached: float = 0.0
var game_started: bool = false
var fall_threshold: float = 500.0  # Distance below camera to trigger game over
var is_game_over: bool = false
var is_paused: bool = false

# Additional systems
var achievement_system: Node
var shop_system: Node
var save_manager: Node
var falling_sound: AudioStreamPlayer
var score_multiplier: float = 1.0

# Game Over Scene
@export var game_over_scene: PackedScene = preload("res://scenes/GameOver.tscn")
var game_over_instance: Control = null

# Continue system
var continues_used: int = 0
var max_continues: int = 2

func _ready() -> void:
	# Get references to UI elements and systems first
	ui_layer = get_node_or_null("UILayer")
	score_label = get_node_or_null("UILayer/ScoreLabel")
	currency_label = get_node_or_null("UILayer/CurrencyLabel")
	combo_label = get_node_or_null("UILayer/ComboLabel")
	pause_button = get_node_or_null("UILayer/PauseButton")
	pause_screen = get_node_or_null("UILayer/PauseScreen")
	audio_settings_menu = get_node_or_null("UILayer/AudioSettingsMenu")
	
	# Get power-up system references (optional - may not exist)
	power_up_spawner = get_node_or_null("PowerUpSpawner")
	advanced_power_ups = get_node_or_null("AdvancedPowerUps")
	power_up_ui = get_node_or_null("UILayer/PowerUpUI")
	
	# Add to main game group for achievement system
	add_to_group("main_game")
	
	# Initialize visual effects
	setup_visual_effects()
	
	# Load saved currency from file
	load_game_data()
	
	# Apply purchased items effects
	apply_purchased_items()
	
	# Try to get audio node (optional)
	falling_sound = get_node_or_null("FallingSound")
	
	# Load falling sound effect if node exists
	if falling_sound:
		falling_sound.stream = preload("res://audio/falling.mp3")
	
	# Connect to player signals
	if player:
		player.connect("platform_landed", _on_player_platform_landed)
	
	# Connect power-up system signals (only if nodes exist)
	if power_up_spawner:
		power_up_spawner.connect("power_up_collected", _on_power_up_collected)
	
	if advanced_power_ups:
		advanced_power_ups.connect("power_up_activated", _on_power_up_activated)
		advanced_power_ups.connect("power_up_expired", _on_power_up_expired)
	
	# Start rising danger system
	if rising_danger:
		rising_danger.start_game()
	
	# Style pause button for mobile
	if pause_button:
		style_pause_button()
	
	# Connect pause screen signals - using direct method calls since it's built into scene
	# No need to connect signals for embedded pause screen
	
	# Game over scene will be instantiated when needed
	
	# Initialize boost UI
	setup_boost_ui()
	
	# Initialize UI
	update_ui()
	
	# Start background music
	AudioManager.play_background_music()
	
	print("Game Manager initialized - Currency: ", total_currency, " Score: ", current_score)

func setup_visual_effects():
	"""Initialize visual feedback systems"""
	# Create visual feedback system
	var VisualFeedbackScript = preload("res://scripts/visual_feedback.gd")
	visual_feedback = VisualFeedbackScript.new()
	add_child(visual_feedback)
	
	# Create platform animations system
	var PlatformAnimationsScript = preload("res://scripts/platform_animations.gd")
	platform_animations = PlatformAnimationsScript.new()
	add_child(platform_animations)
	
	# Create UI animations system
	var UIAnimationsScript = preload("res://scripts/ui_animations.gd")
	ui_animations = UIAnimationsScript.new()
	add_child(ui_animations)
	
	# Create power-up effects system
	var PowerUpEffectsScript = preload("res://scripts/power_up_effects.gd")
	power_up_effects = PowerUpEffectsScript.new()
	add_child(power_up_effects)
	
	# Create advanced power-ups system
	var AdvancedPowerUpsScript = preload("res://scripts/advanced_power_ups.gd")
	advanced_power_ups = AdvancedPowerUpsScript.new()
	add_child(advanced_power_ups)
	
	# Create power-up spawner
	var PowerUpSpawnerScript = preload("res://scripts/power_up_spawner.gd")
	power_up_spawner = PowerUpSpawnerScript.new()
	add_child(power_up_spawner)
	
	# Create power-up UI
	var PowerUpUIScript = preload("res://scripts/power_up_ui.gd")
	power_up_ui = PowerUpUIScript.new()
	ui_layer.add_child(power_up_ui)

func _input(event):
	"""Handle input events including pause"""
	if event.is_action_pressed("ui_cancel") and current_game_state == GameState.PLAYING:
		toggle_pause()

func toggle_pause():
	"""Toggle pause state"""
	if current_game_state == GameState.PLAYING:
		pause_game()
	elif current_game_state == GameState.PAUSED:
		resume_game()

func pause_game():
	"""Pause the game"""
	current_game_state = GameState.PAUSED
	is_paused = true
	if pause_screen:
		show_pause_screen()
	# Pause background music
	AudioManager.pause_background_music()

func resume_game():
	"""Resume the game"""
	current_game_state = GameState.PLAYING
	is_paused = false
	hide_pause_screen()
	# Resume background music
	AudioManager.resume_background_music()

func _on_resume_game():
	"""Handle resume button from pause screen"""
	resume_game()

func _on_restart_game():
	"""Handle restart button from pause screen"""
	reset_game()

func _on_return_to_menu():
	"""Handle menu button from pause screen"""
	# Save current progress
	save_game_data()
	# Return to main menu
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func style_pause_button():
	"""Style the pause button for mobile interface"""
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	button_style.corner_radius_top_left = 15
	button_style.corner_radius_top_right = 15
	button_style.corner_radius_bottom_left = 15
	button_style.corner_radius_bottom_right = 15
	button_style.border_width_left = 3
	button_style.border_width_right = 3
	button_style.border_width_top = 3
	button_style.border_width_bottom = 3
	button_style.border_color = Color(0.4, 0.4, 0.4, 1.0)
	
	var button_hover_style = StyleBoxFlat.new()
	button_hover_style.bg_color = Color(0.3, 0.3, 0.3, 0.9)
	button_hover_style.corner_radius_top_left = 15
	button_hover_style.corner_radius_top_right = 15
	button_hover_style.corner_radius_bottom_left = 15
	button_hover_style.corner_radius_bottom_right = 15
	button_hover_style.border_width_left = 3
	button_hover_style.border_width_right = 3
	button_hover_style.border_width_top = 3
	button_hover_style.border_width_bottom = 3
	button_hover_style.border_color = Color(0.6, 0.6, 0.6, 1.0)
	
	pause_button.add_theme_stylebox_override("normal", button_style)
	pause_button.add_theme_stylebox_override("hover", button_hover_style)
	pause_button.add_theme_color_override("font_color", Color.WHITE)
	pause_button.add_theme_font_size_override("font_size", 24)

func _on_pause_button_pressed():
	"""Handle pause button press"""
	pause_game()

func show_pause_screen():
	"""Show the pause screen with current stats"""
	var pause_score_label = pause_screen.get_node("PausePanel/VBoxContainer/ScoreContainer/ScoreLabel")
	var pause_coins_label = pause_screen.get_node("PausePanel/VBoxContainer/ScoreContainer/CoinsLabel")
	
	if pause_score_label:
		pause_score_label.text = "Score: " + str(current_score)
	if pause_coins_label:
		pause_coins_label.text = "Coins: " + str(total_currency + session_currency)
	
	pause_screen.visible = true
	get_tree().paused = true

func _on_resume_pressed():
	"""Handle resume button from pause screen"""
	resume_game()

func _on_restart_pressed():
	"""Handle restart button from pause screen"""
	hide_pause_screen()
	restart_game()

func _on_settings_pressed():
	"""Handle settings button from pause screen"""
	var simple_audio_settings = $UILayer/SimpleAudioSettings
	if simple_audio_settings:
		simple_audio_settings.visible = true
		print("Showing simple audio settings")

func _on_menu_pressed():
	"""Handle menu button from pause screen"""
	hide_pause_screen()
	_on_return_to_menu()

func hide_pause_screen():
	"""Hide pause screen and resume game"""
	if pause_screen:
		pause_screen.visible = false
	get_tree().paused = false

func _process(_delta: float) -> void:
	if current_game_state == GameState.PLAYING:
		check_player_fall()

func check_player_fall():
	if player and camera:
		var distance_below_camera = player.global_position.y - camera.global_position.y
		if distance_below_camera > fall_threshold:
			trigger_game_over()

func trigger_game_over():
	current_game_state = GameState.GAME_OVER
	emit_signal("game_over")
	
	# Play falling sound effect
	if falling_sound:
		falling_sound.play()
	
	# Stop player movement
	if player:
		player.set_physics_process(false)
	
	# Show game over screen
	show_game_over_screen()
	
	# Save final score and currency
	save_game_data()
	print("Game Over! Final Score: ", current_score, " Currency Earned: ", session_currency)

func _on_player_platform_landed(platform_y: float):
	# Only count upward progress
	if platform_y < highest_platform_reached:
		highest_platform_reached = platform_y
		
		# Animate platform bounce
		var platforms = get_tree().get_nodes_in_group("platforms")
		for platform in platforms:
			if abs(platform.global_position.y - platform_y) < 20:  # Find the platform player landed on
				if platform_animations and platform_animations.has_method("animate_platform_bounce"):
					platform_animations.animate_platform_bounce(platform)
				break
		
		# Trigger power-up spawning (only if power-up system exists)
		if power_up_spawner and power_up_spawner.has_method("try_spawn_power_up"):
			power_up_spawner.try_spawn_power_up(Vector2(0, platform_y))
		
		add_score_and_currency()

func _on_power_up_collected(power_up_type: int, rarity: String):
	"""Handle power-up collection"""
	if advanced_power_ups:
		advanced_power_ups.activate_power_up(power_up_type)
	
	# Add collection feedback
	if visual_feedback and visual_feedback.has_method("create_power_up_collection_effect"):
		visual_feedback.create_power_up_collection_effect(player.global_position, rarity)

func _on_power_up_activated(power_up_type: int, power_up_name: String):
	"""Handle power-up activation"""
	if power_up_ui:
		power_up_ui.show_activation_notification(power_up_name)
	
	# Apply power-up effects to player if using enhanced player
	if player and player.has_method("apply_power_up_effect"):
		player.apply_power_up_effect(power_up_type)

func _on_power_up_expired(power_up_type: int, _power_up_name: String):
	"""Handle power-up expiration"""
	if power_up_ui:
		power_up_ui.remove_power_up_icon(power_up_type)
	
	# Remove power-up effects from player if using enhanced player
	if player and player.has_method("remove_power_up_effect"):
		player.remove_power_up_effect(power_up_type)

func add_score_and_currency():
	consecutive_jumps += 1
	
	# Base rewards
	var score_earned = points_per_jump
	var currency_earned = currency_per_jump
	
	# Bonus rewards for consecutive jumps
	if consecutive_jumps % bonus_multiplier_threshold == 0:
		score_earned += bonus_points
		currency_earned += bonus_currency
		show_combo_bonus()
	
	# Apply score multiplier from boosts
	score_earned = int(score_earned * score_multiplier)
	
	# Update totals
	current_score += score_earned
	session_currency += currency_earned
	total_currency += currency_earned
	
	# Track achievements
	_track_achievements()
	
	# Emit signals
	emit_signal("score_changed", current_score)
	emit_signal("currency_changed", total_currency)
	emit_signal("successful_jump")
	
	# Update UI
	update_ui()
	show_jump_feedback(score_earned, currency_earned)
	
	# Create visual feedback for score/coins
	if visual_feedback and visual_feedback.has_method("create_score_popup"):
		visual_feedback.create_score_popup(player.global_position + Vector2(0, -30), score_earned, currency_earned, ui_layer)
	
	# Show combo effect for bonus jumps
	if consecutive_jumps % bonus_multiplier_threshold == 0 and visual_feedback and visual_feedback.has_method("create_combo_effect"):
		visual_feedback.create_combo_effect(player.global_position + Vector2(0, -50), consecutive_jumps, ui_layer)
	
	# Save progress periodically
	if consecutive_jumps % 5 == 0:
		save_game_data()

func update_ui():
	if score_label:
		score_label.text = "Score: " + str(current_score)
		# Animate score update
		if ui_animations and ui_animations.has_method("animate_score_update"):
			ui_animations.animate_score_update(score_label, current_score)
	
	if currency_label:
		currency_label.text = "Coins: " + str(session_currency)
		# Animate currency update
		if ui_animations and ui_animations.has_method("animate_currency_update"):
			ui_animations.animate_currency_update(currency_label, session_currency)

func reset_session():
	current_score = 0
	session_currency = 0
	consecutive_jumps = 0
	highest_platform_reached = 0.0
	game_started = false
	
	# Apply starting power-ups
	apply_starting_power_ups()
	
	# Reset game over instance continues for new game
	if game_over_instance:
		game_over_instance.reset_continues()
	
	update_ui()

func apply_starting_power_ups():
	"""Apply power-ups that activate at game start"""
	var save_data = load_save_data()
	var purchased_items = save_data.get("purchased_items", {})
	
	if not player:
		return
	
	# Start with jump boost
	if purchased_items.has("powerups_start_jump"):
		player.activate_jump_boost()
		print("Started game with jump boost")
	
	# Start with shield
	if purchased_items.has("powerups_start_shield"):
		player.activate_shield()
		print("Started game with shield")

func spend_currency(amount: int) -> bool:
	if total_currency >= amount:
		total_currency -= amount
		emit_signal("currency_changed", total_currency)
		update_ui()
		save_game_data()
		return true
	return false

func save_game_data():
	var save_file = FileAccess.open("user://hopnsplat_save.dat", FileAccess.WRITE)
	if save_file:
		var save_data = {
			"total_currency": total_currency,
			"highest_score": current_score if current_score > get_highest_score() else get_highest_score()
		}
		save_file.store_string(JSON.stringify(save_data))
		save_file.close()

func load_game_data():
	var save_file = FileAccess.open("user://hopnsplat_save.dat", FileAccess.READ)
	if save_file:
		var save_data_text = save_file.get_as_text()
		save_file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(save_data_text)
		if parse_result == OK:
			var save_data = json.data
			total_currency = save_data.get("total_currency", 0)
			print("Loaded currency: ", total_currency)

func get_highest_score() -> int:
	var save_file = FileAccess.open("user://hopnsplat_save.dat", FileAccess.READ)
	if save_file:
		var save_data_text = save_file.get_as_text()
		save_file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(save_data_text)
		if parse_result == OK:
			var save_data = json.data
			return save_data.get("highest_score", 0)
	return 0

func show_combo_bonus():
	if combo_label:
		combo_label.text = "BONUS! x" + str(consecutive_jumps)
		combo_label.modulate = Color.YELLOW
		
		# Create a tween to animate the bonus text
		var tween = create_tween()
		tween.tween_property(combo_label, "modulate:a", 0.0, 2.0)
		tween.tween_callback(func(): combo_label.text = "")

func show_jump_feedback(score_earned: int, currency_earned: int):
	# Show brief feedback for regular jumps
	if consecutive_jumps % bonus_multiplier_threshold != 0 and combo_label:
		combo_label.text = "+" + str(score_earned) + " pts, +" + str(currency_earned) + " coins"
		combo_label.modulate = Color.WHITE
		
		var tween = create_tween()
		tween.tween_property(combo_label, "modulate:a", 0.0, 1.0)
		tween.tween_callback(func(): combo_label.text = "")

func show_game_over_screen():
	"""Create and show the game over screen with current stats"""
	if game_over_instance == null:
		game_over_instance = game_over_scene.instantiate()
		ui_layer.add_child(game_over_instance)
		
		# Connect signals from game over screen
		game_over_instance.connect("restart_requested", _on_restart_requested)
		game_over_instance.connect("continue_requested", _on_continue_requested)
		game_over_instance.connect("menu_requested", _on_menu_requested)
	
	# Calculate stats
	var high_score = get_highest_score()
	var is_new_high_score = current_score > high_score
	
	# Show the game over screen with stats and continue count
	game_over_instance.show_game_over(
		current_score,
		session_currency,
		consecutive_jumps,
		high_score,
		is_new_high_score,
		continues_used
	)

func reset_game():
	"""Reset game state for new game"""
	current_game_state = GameState.PLAYING
	current_score = 0
	session_currency = 0
	consecutive_jumps = 0
	highest_platform_reached = 0.0
	game_started = false
	score_multiplier = 1.0
	
	# Reset player position
	if player:
		player.global_position = Vector2(270, 800)
		player.velocity = Vector2.ZERO
	
	# Reset camera
	if camera:
		camera.global_position = Vector2(271, 479)
		camera.offset = Vector2.ZERO
	
	# Clear platforms
	if platform_spawner:
		platform_spawner.clear_platforms()
	
	# Reset rising danger
	if rising_danger:
		rising_danger.reset()
		rising_danger.start_game()
	
	# Update UI
	update_ui()
	
	print("Game reset complete")

func restart_game():
	print("Restart game called!")
	
	# Reset game state
	current_game_state = GameState.PLAYING
	# Reset continues for new game
	continues_used = 0
	
	# Reset session-based achievements
	var achievement_sys = get_node("/root/AchievementSystem")
	if achievement_sys:
		achievement_sys.reset_session_progress()
	
	reset_session()
	
	# Reset rising danger FIRST to ensure it's at bottom
	if rising_danger:
		rising_danger.reset()
		print("Rising danger reset to bottom position")
	
	# Reset player to safe starting position
	if player:
		player.global_position = Vector2(270, 800)  # Use consistent starting position
		player.velocity = Vector2.ZERO
		player.set_physics_process(true)
		print("Player reset to starting position: ", player.global_position)
	
	# Reset camera
	if camera:
		camera.global_position = Vector2(271, 479)
		camera.target_y = player.global_position.y  # Reset camera target to player position
		print("Camera reset to starting position")
	
	# Reset platform spawner and spawn initial platforms
	if platform_spawner:
		# Clear existing platforms
		for platform in platform_spawner.platforms:
			if platform and is_instance_valid(platform):
				platform.queue_free()
		platform_spawner.platforms.clear()
		platform_spawner.last_platform_y = 800.0
		
		# Spawn initial platforms immediately
		for i in range(platform_spawner.initial_platform_count):
			platform_spawner.spawn_platform(platform_spawner.last_platform_y - (i * platform_spawner.vertical_spacing))
		print("Platform spawner reset and initial platforms spawned")
	
	# Start rising danger after everything is reset
	if rising_danger:
		rising_danger.start_game()
		print("Rising danger started")
	
	# Hide game over screen
	if game_over_instance:
		game_over_instance.hide_game_over()
		print("Game over screen hidden")
	
	# Update UI
	update_ui()
	
	print("Game restarted successfully!")

func setup_boost_ui():
	"""Initialize the boost UI system"""
	# Create boost UI instance
	var boost_ui_script = preload("res://scripts/boost_ui.gd")
	boost_ui = Control.new()
	boost_ui.set_script(boost_ui_script)
	ui_layer.add_child(boost_ui)

func show_boost_ui(boost_type: int, duration: float):
	"""Show boost indicator in UI"""
	if boost_ui and boost_ui.has_method("show_boost"):
		boost_ui.show_boost(boost_type, duration)

func hide_boost_ui(boost_type: int):
	"""Hide boost indicator in UI"""
	if boost_ui and boost_ui.has_method("hide_boost"):
		boost_ui.hide_boost(boost_type)

func set_score_multiplier(multiplier: float):
	"""Set score multiplier for double points boost"""
	score_multiplier = multiplier

func apply_purchased_items():
	"""Apply effects of purchased items from shop"""
	var save_data = load_save_data()
	var purchased_items = save_data.get("purchased_items", {})
	
	# Apply player skin
	apply_player_skin(purchased_items)
	
	# Apply boost upgrades
	apply_boost_upgrades(purchased_items)
	
	# Apply power-ups
	apply_power_ups(purchased_items)

func load_save_data() -> Dictionary:
	"""Load save data from file"""
	var save_file = FileAccess.open("user://hopnsplat_save.dat", FileAccess.READ)
	if save_file:
		var save_data_text = save_file.get_as_text()
		save_file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(save_data_text)
		if parse_result == OK:
			return json.data
	
	return {}

func apply_player_skin(purchased_items: Dictionary):
	"""Apply purchased player skin"""
	if not player:
		return
	
	var sprite = player.get_node("AnimatedSprite2D")
	if not sprite:
		return
	
	# Check for purchased skins in priority order (most expensive first)
	if purchased_items.has("skins_alien_gold"):
		sprite.modulate = Color.GOLD
		print("Applied Golden Alien skin")
	elif purchased_items.has("skins_alien_red"):
		sprite.modulate = Color.RED
		print("Applied Red Alien skin")
	elif purchased_items.has("skins_alien_green"):
		sprite.modulate = Color.GREEN
		print("Applied Green Alien skin")
	elif purchased_items.has("skins_alien_blue"):
		sprite.modulate = Color.CYAN
		print("Applied Blue Alien skin")

func apply_boost_upgrades(purchased_items: Dictionary):
	"""Apply purchased boost upgrades to player"""
	if not player:
		return
	
	# Store upgrade flags in player for boost system to use
	if purchased_items.has("upgrades_jump_duration"):
		player.set("jump_boost_upgraded", true)
		print("Jump boost upgrade applied")
	
	if purchased_items.has("upgrades_speed_duration"):
		player.set("speed_boost_upgraded", true)
		print("Speed boost upgrade applied")
	
	if purchased_items.has("upgrades_shield_extra"):
		player.set("shield_upgraded", true)
		print("Shield upgrade applied")
	
	if purchased_items.has("upgrades_magnet_range"):
		player.set("magnet_upgraded", true)
		print("Magnet upgrade applied")

func apply_power_ups(purchased_items: Dictionary):
	"""Apply purchased power-ups"""
	# Coin multiplier
	if purchased_items.has("powerups_coin_multiplier"):
		currency_per_jump = 2  # Double coin earning
		print("Coin multiplier power-up applied")
	
	# Starting boosts will be handled in reset_session()
	if purchased_items.has("powerups_start_jump"):
		print("Jump start power-up available")
	
	if purchased_items.has("powerups_start_shield"):
		print("Shield start power-up available")

func _on_restart_requested():
	"""Handle restart request from game over screen"""
	print("Restart requested from GameOver scene")
	restart_game()

func _on_continue_requested():
	"""Handle continue request from game over screen - resume game after ad"""
	print("Continue requested from GameOver scene")
	# Resume game state
	current_game_state = GameState.PLAYING
	
	# Reset player to safe position above rising danger
	if player and rising_danger:
		var safe_y = rising_danger.global_position.y - 200  # 200 pixels above danger
		player.global_position = Vector2(270, safe_y)
		player.velocity = Vector2.ZERO
		player.set_physics_process(true)
		print("Player repositioned for continue at: ", player.global_position)
		
		# Update camera to follow player
		if camera:
			camera.global_position.y = safe_y - 200  # Position camera above player
			camera.target_y = player.global_position.y
	
	# Give brief invincibility
	if player and player.has_method("activate_shield"):
		player.activate_shield()
		print("Temporary shield activated for continue")
	
	# Hide game over screen
	if game_over_instance:
		game_over_instance.hide_game_over()
	
	# Reset game over instance for next time
	if game_over_instance:
		game_over_instance.reset_continues()
	
	print("Game continued successfully! Continues used: ", continues_used)


func _track_achievements():
	"""Track achievement progress"""
	var achievement_sys = get_node("/root/AchievementSystem")
	if achievement_sys:
		# Track score achievements
		achievement_sys.track_score(current_score)
		# Track jump achievements
		achievement_sys.track_jumps(consecutive_jumps)
		# Track coin achievements
		achievement_sys.track_coins(total_currency)
		# Track combo achievements
		achievement_sys.track_combo(consecutive_jumps)

func add_achievement_coins(coins: int):
	"""Add coins from achievement rewards"""
	total_currency += coins
	emit_signal("currency_changed", total_currency)
	update_ui()
	save_game_data()
	print("Added ", coins, " achievement reward coins")

func _on_menu_requested():
	"""Handle menu request from game over screen"""
	print("Menu requested from GameOver scene")
	# Go to main menu
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
