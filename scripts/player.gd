extends CharacterBody2D

signal platform_landed(platform_y)

@export var move_speed := 100
@export var jump_force := -750
@export var gravity := 500

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
# Audio nodes (optional - will be null if not present in scene)
var jump_sound: AudioStreamPlayer
var danger_sound: AudioStreamPlayer

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

func _ready() -> void:
	set_process_unhandled_input(true)
	
	# Try to get audio nodes (optional)
	jump_sound = get_node_or_null("JumpSound")
	danger_sound = get_node_or_null("DangerSound")
	
	# Load sound effects if nodes exist
	if jump_sound:
		jump_sound.stream = preload("res://audio/jump.mp3")
	if danger_sound:
		danger_sound.stream = preload("res://audio/danger-crushing.mp3")
	
	# Initialize touch target to current position
	target_x_position = global_position.x
	



func _physics_process(delta):
	# Check if player just landed on a platform
	var current_on_floor = is_on_floor()
	if current_on_floor and not was_on_floor:
		# Player just landed - emit signal with platform Y position
		emit_signal("platform_landed", global_position.y)
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
	"""Perform jump action with sound effect"""
	if is_on_floor() and Time.get_unix_time_from_system() - last_jump_time > jump_cooldown:
		velocity.y = jump_force
		last_jump_time = Time.get_unix_time_from_system()
		if jump_sound:
			jump_sound.play()

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

func _on_splat_obstacle_hit(_obstacle):
	"""Handle collision with splat obstacle"""
	if danger_sound:
		danger_sound.play()
	# Trigger game over or damage logic here
	get_node("/root/Main").trigger_game_over()
