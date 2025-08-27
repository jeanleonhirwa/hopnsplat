extends Node2D

# Game Management System
signal score_changed(new_score)
signal currency_changed(new_currency)
signal successful_jump
signal game_over

# Score and Currency System
var current_score: int = 0
var total_currency: int = 0  # Persistent currency for purchases
var session_currency: int = 0  # Currency earned this session

# Scoring Configuration
@export var points_per_jump: int = 5
@export var currency_per_jump: int = 1
@export var bonus_multiplier_threshold: int = 10  # Bonus every 10 jumps
@export var bonus_points: int = 25
@export var bonus_currency: int = 5

# Game State
enum GameState { PLAYING, GAME_OVER, PAUSED }
var current_game_state: GameState = GameState.PLAYING
var consecutive_jumps: int = 0
var highest_platform_reached: float = 0.0
var game_started: bool = false
var fall_threshold: float = 500.0  # Distance below camera to trigger game over

# Node References
@onready var player = $Player
@onready var camera = $Camera2D
@onready var ui_layer = $UILayer
@onready var score_label = $UILayer/ScoreLabel
@onready var currency_label = $UILayer/CurrencyLabel
@onready var combo_label = $UILayer/ComboLabel
# Audio node (optional - will be null if not present in scene)
var falling_sound: AudioStreamPlayer

# Game Over Scene
@export var game_over_scene: PackedScene = preload("res://scenes/GameOver.tscn")
var game_over_instance: Control = null

func _ready() -> void:
	# Load saved currency from file
	load_game_data()
	
	# Try to get audio node (optional)
	falling_sound = get_node_or_null("FallingSound")
	
	# Load falling sound effect if node exists
	if falling_sound:
		falling_sound.stream = preload("res://audio/falling.mp3")
	
	# Connect to player signals
	if player:
		player.connect("platform_landed", _on_player_platform_landed)
	
	# Game over scene will be instantiated when needed
	
	# Initialize UI
	update_ui()
	
	print("Game Manager initialized - Currency: ", total_currency, " Score: ", current_score)

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
		add_score_and_currency()

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
	
	# Update totals
	current_score += score_earned
	session_currency += currency_earned
	total_currency += currency_earned
	
	# Emit signals
	emit_signal("score_changed", current_score)
	emit_signal("currency_changed", total_currency)
	emit_signal("successful_jump")
	
	# Update UI
	update_ui()
	show_jump_feedback(score_earned, currency_earned)
	
	# Save progress periodically
	if consecutive_jumps % 5 == 0:
		save_game_data()

func update_ui():
	if score_label:
		score_label.text = "Score: " + str(current_score)
	if currency_label:
		currency_label.text = "Coins: " + str(session_currency)

func reset_session():
	current_score = 0
	session_currency = 0
	consecutive_jumps = 0
	highest_platform_reached = 0.0
	game_started = false
	update_ui()

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
		game_over_instance.connect("menu_requested", _on_menu_requested)
	
	# Calculate stats
	var high_score = get_highest_score()
	var is_new_high_score = current_score > high_score
	
	# Show the game over screen with stats
	game_over_instance.show_game_over(
		current_score,
		session_currency,
		consecutive_jumps,
		high_score,
		is_new_high_score
	)

func restart_game():
	print("Restart game called!")
	
	# Reset game state
	current_game_state = GameState.PLAYING
	reset_session()
	
	# Reset player
	if player:
		player.global_position = Vector2(272, 871)  # Reset to starting position
		player.velocity = Vector2.ZERO
		player.set_physics_process(true)
		print("Player reset to starting position")
	
	# Reset camera
	if camera:
		camera.global_position = Vector2(271, 479)
		camera.target_y = player.global_position.y  # Reset camera target to player position
		print("Camera reset to starting position")
	
	# Reset platform spawner
	var platform_spawner = get_node("PlatformSpawner")
	if platform_spawner:
		# Clear existing platforms
		for platform in platform_spawner.platforms:
			if platform and is_instance_valid(platform):
				platform.queue_free()
		platform_spawner.platforms.clear()
		platform_spawner.last_platform_y = 800.0
		print("Platform spawner reset")
	
	# Hide game over screen
	if game_over_instance:
		game_over_instance.hide_game_over()
		print("Game over screen hidden")
	
	# Update UI
	update_ui()
	
	print("Game restarted successfully!")

func _on_restart_requested():
	"""Handle restart request from game over screen"""
	print("Restart requested from GameOver scene")
	restart_game()

func _on_menu_requested():
	"""Handle menu request from game over screen"""
	print("Menu requested from GameOver scene")
	# For now, just restart the game
	# In the future, this could load a main menu scene
	restart_game()
