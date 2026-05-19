extends CharacterBody2D

signal platform_landed(platform_y)

@export var move_speed := 100.0
@export var jump_force := -750.0
@export var gravity := 500.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
# Audio nodes (optional - will be null if not present in scene)
var jump_sound: AudioStreamPlayer
var danger_sound: AudioStreamPlayer

# Visual effects
var particle_effects: Node2D
var screen_shake: Node2D

# Touch control variables
var is_touching := false
var touch_start_position := Vector2.ZERO
var touch_current_position := Vector2.ZERO
var swipe_threshold := 50.0  # Minimum distance for swipe detection
var tap_max_duration := 0.3  # Maximum time for tap (vs hold)
var touch_start_time := 0.0
var last_jump_time := 0.0
var jump_cooldown := 0.2  # Prevent accidental double jumps

# Movement variables
var touch_direction := 0
var was_on_floor := false
var platform_velocity := Vector2.ZERO
var last_platform_position := Vector2.ZERO
var current_platform: Node2D = null
var target_x_position := 0.0
var movement_smoothing := 8.0  # How smoothly player follows touch

# Boost system variables
var active_boosts := {}
var original_jump_force: float
var original_move_speed: float
var shield_uses: int = 0
var coin_magnet_radius: float = 0.0
var score_multiplier: float = 1.0

func _ready() -> void:
	set_process_unhandled_input(true)
	
	# Try to get audio nodes (optional)
	jump_sound = get_node_or_null("JumpSound")
	danger_sound = get_node_or_null("DangerSound")
	
	# Initialize visual effects
	setup_visual_effects()
	
	# Debug audio node detection
	print("DEBUG: Jump sound node found: ", jump_sound != null)
	print("DEBUG: Danger sound node found: ", danger_sound != null)
	
	# Load sound effects if nodes exist
	if jump_sound:
		jump_sound.stream = preload("res://audio/jump.mp3")
		print("DEBUG: Jump sound loaded successfully")
	else:
		print("DEBUG: Jump sound node not found!")
	if danger_sound:
		danger_sound.stream = preload("res://audio/danger-crushing.mp3")
		print("DEBUG: Danger sound loaded successfully")
	else:
		print("DEBUG: Danger sound node not found!")
	
	# Initialize touch target to current position
	target_x_position = global_position.x
	
	# Store original values for boost system
	original_jump_force = jump_force
	original_move_speed = move_speed

func setup_visual_effects():
	"""Initialize particle effects and screen shake"""
	# Create particle effects system
	var ParticleEffectsScript = preload("res://scripts/particle_effects.gd")
	particle_effects = ParticleEffectsScript.new()
	add_child(particle_effects)
	
	# Get screen shake from main scene
	var main_scene = get_tree().get_first_node_in_group("main_game")
	if main_scene:
		screen_shake = main_scene.get_node_or_null("ScreenShake")
		if not screen_shake:
			# Create screen shake if it doesn't exist
			var ScreenShakeScript = preload("res://scripts/screen_shake.gd")
			screen_shake = ScreenShakeScript.new()
			main_scene.add_child(screen_shake)
			var camera = get_viewport().get_camera_2d()
			if camera:
				screen_shake.initialize(camera)
	



func _physics_process(delta):
	# Check if player just landed on a platform
	var current_on_floor = is_on_floor()
	if current_on_floor and not was_on_floor:
		# Player just landed - emit signal with platform Y position
		emit_signal("platform_landed", global_position.y)
		
		# Trigger landing effects
		if particle_effects and particle_effects.has_method("play_landing_effect"):
			particle_effects.play_landing_effect(global_position)
		if screen_shake and screen_shake.has_method("landing_shake"):
			screen_shake.landing_shake()
		
	was_on_floor = current_on_floor
	
	# Handle platform physics
	handle_platform_movement()
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Move player
	move_and_slide()

	# Handle touch-based jumping (more responsive than input actions)
	handle_touch_jump(delta)
	
	# Fallback keyboard controls for testing
	if Input.is_action_just_pressed("jump_up") and is_on_floor():
		perform_jump()
	
	
	# Animate based on state
	if is_on_floor():
		sprite.play("idle")
	elif velocity.y < 0:
		sprite.play("jump")
	elif velocity.y > 0:
		sprite.play("fly")  # falling or flying up

	# Update active boosts
	update_boosts(delta)
	
	# Handle coin magnet effect
	if coin_magnet_radius > 0:
		attract_nearby_coins()
	
	# Handle touch-based horizontal movement
	handle_touch_movement(delta)
	
	# Fallback keyboard controls for testing
	var direction := 0
	if Input.is_action_pressed("ui_left"):
		direction -= 1
	if Input.is_action_pressed("ui_right"):
		direction += 1
	
	# Apply movement (touch takes priority over keyboard)
	if not is_touching:
		if is_on_floor() and current_platform:
			velocity.x = (direction * move_speed) + platform_velocity.x
		else:
			velocity.x = direction * move_speed

	# Get screen width (works on all phones)
	var screen_size = get_viewport_rect().size
	# Clamp X position inside screen
	position.x = clamp(position.x, 0, screen_size.x)
	

	




func handle_platform_movement():
	"""Handle realistic physics interaction with moving platforms"""
	var new_platform_velocity = Vector2.ZERO
	var found_platform = null
	
	if is_on_floor():
		# Check what we're standing on
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			# Check if this is a moving platform by looking for MovingPlatform script
			if collider and collider.get_script() and "moving_platform" in str(collider.get_script().get_path()):
				found_platform = collider
				
				# Calculate platform velocity by tracking position changes
				if current_platform == collider and last_platform_position != Vector2.ZERO:
					new_platform_velocity = (collider.global_position - last_platform_position) / get_physics_process_delta_time()
					# Smooth the velocity to avoid jitter
					new_platform_velocity = platform_velocity.lerp(new_platform_velocity, 0.3)
				
				last_platform_position = collider.global_position
				break
	
	# Update platform tracking
	current_platform = found_platform
	if current_platform:
		platform_velocity = new_platform_velocity
	else:
		# Gradually reduce platform velocity when not on platform
		platform_velocity = platform_velocity.lerp(Vector2.ZERO, 0.1)
		last_platform_position = Vector2.ZERO

func _unhandled_input(event):
	"""Handle all touch input events for mobile controls"""
	if event is InputEventScreenTouch:
		if event.pressed:
			# Touch started
			is_touching = true
			touch_start_position = event.position
			touch_current_position = event.position
			touch_start_time = Time.get_unix_time_from_system()
		else:
			# Touch ended
			is_touching = false
			# Handle tap-to-jump logic in handle_touch_jump()
			
	elif event is InputEventScreenDrag:
		# Touch moved - update current position for movement
		if is_touching:
			touch_current_position = event.position

func perform_jump():
	"""Perform jump action with sound effect and particles"""
	if is_on_floor() and Time.get_unix_time_from_system() - last_jump_time > jump_cooldown:
		velocity.y = jump_force
		last_jump_time = Time.get_unix_time_from_system()
		
		# Play jump sound
		print("DEBUG: Jump performed, attempting to play sound...")
		if jump_sound:
			jump_sound.play()
			print("DEBUG: Jump sound play() called")
		else:
			print("DEBUG: No jump sound available to play")
		
		# Trigger jump effects
		if particle_effects and particle_effects.has_method("play_jump_effect"):
			particle_effects.play_jump_effect(global_position)
		if screen_shake and screen_shake.has_method("light_shake"):
			screen_shake.light_shake()

func handle_touch_jump(_delta):
	"""Handle touch-based jumping with tap detection"""
	# Check for quick tap to jump
	if not is_touching and touch_start_time > 0:
		var touch_duration = Time.get_unix_time_from_system() - touch_start_time
		if touch_duration <= tap_max_duration:
			# This was a tap - perform jump
			perform_jump()
		touch_start_time = 0.0

func handle_touch_movement(delta):
	"""Handle smooth touch-based horizontal movement"""
	if is_touching:
		# Convert touch position to world coordinates
		var screen_size = get_viewport_rect().size
		target_x_position = touch_current_position.x
		
		# Clamp target position to screen bounds with margins
		var margin = 50
		target_x_position = clamp(target_x_position, margin, screen_size.x - margin)
		
		# Smooth movement towards touch position
		var distance_to_target = target_x_position - global_position.x
		var movement_speed = move_speed * movement_smoothing
		
		# Apply movement with platform consideration
		if is_on_floor() and current_platform:
			velocity.x = (distance_to_target * movement_speed * delta) + platform_velocity.x
		else:
			velocity.x = distance_to_target * movement_speed * delta
		
		# Limit maximum velocity for better control
		velocity.x = clamp(velocity.x, -move_speed * 2, move_speed * 2)

func apply_boost(boost_type: int):
	"""Apply boost effect to player"""
	match boost_type:
		0:  # JUMP_BOOST
			activate_jump_boost()
		1:  # SPEED_BOOST
			activate_speed_boost()
		2:  # SHIELD
			activate_shield()
		3:  # COIN_MAGNET
			activate_coin_magnet()
		4:  # DOUBLE_POINTS
			activate_double_points()

func activate_jump_boost():
	"""Activate jump boost effect"""
	var duration = 8.0
	# Check for upgrade
	if get("jump_boost_upgraded"):
		duration = 16.0  # Double duration
		print("Jump Boost+ activated (upgraded duration)!")
	
	var boost_info = {"duration": duration, "start_time": Time.get_unix_time_from_system()}
	active_boosts["jump"] = boost_info
	jump_force = original_jump_force * 1.5
	notify_boost_ui(0, boost_info.duration)
	print("Jump Boost activated!")

func activate_speed_boost():
	"""Activate speed boost effect"""
	var duration = 6.0
	# Check for upgrade
	if get("speed_boost_upgraded"):
		duration = 12.0  # Double duration
		print("Speed Boost+ activated (upgraded duration)!")
	
	var boost_info = {"duration": duration, "start_time": Time.get_unix_time_from_system()}
	active_boosts["speed"] = boost_info
	move_speed = original_move_speed * 2.0
	notify_boost_ui(1, boost_info.duration)
	print("Speed Boost activated!")

func activate_shield():
	"""Activate shield effect"""
	shield_uses = 1
	# Check for upgrade
	if get("shield_upgraded"):
		shield_uses = 2  # Double shield hits
		print("Double Shield activated (upgraded protection)!")
	
	notify_boost_ui(2, 999.0)  # Shield doesn't expire by time
	print("Shield activated!")

func activate_coin_magnet():
	"""Activate coin magnet effect"""
	var boost_info = {"duration": 10.0, "start_time": Time.get_unix_time_from_system()}
	active_boosts["magnet"] = boost_info
	coin_magnet_radius = 150.0
	
	# Check for upgrade
	if get("magnet_upgraded"):
		coin_magnet_radius = 300.0  # Double range
		print("Super Magnet activated (upgraded range)!")
	
	notify_boost_ui(3, boost_info.duration)
	print("Coin Magnet activated!")

func activate_double_points():
	"""Activate double points effect"""
	var boost_info = {"duration": 12.0, "start_time": Time.get_unix_time_from_system()}
	active_boosts["double_points"] = boost_info
	score_multiplier = 2.0
	# Notify main game of score multiplier change
	var main_game = get_node("/root/Main")
	if main_game and main_game.has_method("set_score_multiplier"):
		main_game.set_score_multiplier(score_multiplier)
	notify_boost_ui(4, boost_info.duration)
	print("Double Points activated!")

func notify_boost_ui(boost_type: int, duration: float):
	"""Notify boost UI to show boost"""
	var main_game = get_node("/root/Main")
	if main_game and main_game.has_method("show_boost_ui"):
		main_game.show_boost_ui(boost_type, duration)

func notify_boost_ui_hide(boost_type: int):
	"""Notify boost UI to hide boost"""
	var main_game = get_node("/root/Main")
	if main_game and main_game.has_method("hide_boost_ui"):
		main_game.hide_boost_ui(boost_type)

func update_boosts(_delta):
	"""Update and expire active boosts"""
	var current_time = Time.get_unix_time_from_system()
	var boosts_to_remove = []
	
	for boost_name in active_boosts:
		var boost = active_boosts[boost_name]
		var elapsed_time = current_time - boost.start_time
		
		if elapsed_time >= boost.duration:
			boosts_to_remove.append(boost_name)
	
	# Remove expired boosts
	for boost_name in boosts_to_remove:
		deactivate_boost(boost_name)

func deactivate_boost(boost_name: String):
	"""Deactivate a specific boost"""
	match boost_name:
		"jump":
			jump_force = original_jump_force
			notify_boost_ui_hide(0)
			print("Jump Boost expired")
		"speed":
			move_speed = original_move_speed
			notify_boost_ui_hide(1)
			print("Speed Boost expired")
		"magnet":
			coin_magnet_radius = 0.0
			notify_boost_ui_hide(3)
			print("Coin Magnet expired")
		"double_points":
			score_multiplier = 1.0
			var main_game = get_node("/root/Main")
			if main_game and main_game.has_method("set_score_multiplier"):
				main_game.set_score_multiplier(score_multiplier)
			notify_boost_ui_hide(4)
			print("Double Points expired")
	
	active_boosts.erase(boost_name)

func attract_nearby_coins():
	"""Attract nearby coins when magnet is active"""
	# This would need to be implemented based on how coins are handled in the game
	# For now, just a placeholder
	pass

func trigger_screen_shake(intensity: float, duration: float):
	"""Trigger screen shake effect via camera"""
	var camera = get_node("/root/Main/Camera2D")
	if camera and camera.has_method("shake"):
		camera.shake(intensity, duration)
	else:
		print("DEBUG: Camera shake not available")

func _on_splat_obstacle_hit(_obstacle):
	"""Handle collision with splat obstacle"""
	print("DEBUG: Splat obstacle hit detected!")
	# Check if shield is active
	if shield_uses > 0:
		shield_uses -= 1
		print("Shield absorbed obstacle hit!")
		if shield_uses <= 0:
			notify_boost_ui_hide(2)  # Hide shield UI when depleted
		if danger_sound:
			danger_sound.play()
			print("DEBUG: Danger sound played (shield)")
		else:
			print("DEBUG: No danger sound available (shield)")
		return
	
	# Splat armor check
	if get("splat_armor_upgraded") and randf() < 0.5:
		print("Splat Armor deflected the hit!")
		if screen_shake and screen_shake.has_method("light_shake"):
			screen_shake.light_shake()
		return
	
	# No shield or armor - normal damage
	print("DEBUG: Playing danger sound for obstacle hit...")
	if danger_sound:
		danger_sound.play()
		print("DEBUG: Danger sound played (normal hit)")
	else:
		print("DEBUG: No danger sound available (normal hit)")
	
	# Add intense screen shake for game over
	trigger_screen_shake(8.0, 0.5)
	
	# Trigger game over or damage logic here
	get_node("/root/Main").trigger_game_over()
