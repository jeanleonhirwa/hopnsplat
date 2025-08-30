extends CharacterBody2D

# Enhanced Player with Power-Up Support
class_name EnhancedPlayer

signal platform_landed(platform_y: float)
signal player_died
signal power_up_ability_used(ability: String)

# Movement constants
const JUMP_VELOCITY = -400.0
const GRAVITY = 980.0
const HORIZONTAL_SPEED = 200.0

# Power-up abilities
var double_jump_enabled: bool = false
var double_jumps_remaining: int = 0
var wall_jump_enabled: bool = false
var teleport_dash_enabled: bool = false
var ghost_mode_enabled: bool = false
var platform_magnet_enabled: bool = false
var time_control_enabled: bool = false
var platform_creation_enabled: bool = false
var dimension_shift_enabled: bool = false
var phoenix_revival_available: bool = false

# Enhanced movement states
var is_wall_sliding: bool = false
var can_teleport_dash: bool = true
var teleport_dash_cooldown: float = 1.0
var teleport_dash_timer: float = 0.0

# Environmental effects
var wind_force: Vector2 = Vector2.ZERO
var gravity_multiplier: float = 1.0
var is_gravity_flipped: bool = false

# Position history for time rewind
var position_history: Array[Vector2] = []
var max_history_length: int = 180  # 3 seconds at 60 FPS
var rewind_speed: float = 3.0

# Platform interaction
var sticky_platform_contact: bool = false
var bounce_multiplier: float = 1.0
var magnet_range: float = 150.0

# Visual effects
var ghost_alpha: float = 1.0
var dimension_shift_phase: float = 0.0

# Input handling
var input_buffer_time: float = 0.1
var jump_buffer_timer: float = 0.0
var coyote_time: float = 0.15
var coyote_timer: float = 0.0

func _ready():
	# Initialize position history
	position_history.clear()
	
	# Set up collision layers for power-ups
	collision_layer = 1  # Player layer
	collision_mask = 2 | 4  # Platforms and power-ups

func _physics_process(delta):
	# Update timers
	update_timers(delta)
	
	# Record position for time rewind
	record_position()
	
	# Handle input buffering
	handle_input_buffer(delta)
	
	# Apply environmental effects
	apply_environmental_effects(delta)
	
	# Handle movement
	handle_movement(delta)
	
	# Handle power-up abilities
	handle_power_up_abilities(delta)
	
	# Apply physics
	move_and_slide()
	
	# Check platform interactions
	check_platform_interactions()
	
	# Update visual effects
	update_visual_effects(delta)

func update_timers(delta):
	"""Update various timers"""
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	
	if coyote_timer > 0:
		coyote_timer -= delta
	
	if teleport_dash_timer > 0:
		teleport_dash_timer -= delta
		if teleport_dash_timer <= 0:
			can_teleport_dash = true

func record_position():
	"""Record position for time rewind ability"""
	position_history.append(global_position)
	if position_history.size() > max_history_length:
		position_history.pop_front()

func handle_input_buffer(delta):
	"""Handle input buffering for better responsiveness"""
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("jump"):
		jump_buffer_timer = input_buffer_time

func apply_environmental_effects(delta):
	"""Apply wind, gravity, and other environmental effects"""
	# Apply wind force
	velocity += wind_force * delta
	
	# Apply gravity with multiplier and flip
	var gravity_force = GRAVITY * gravity_multiplier
	if is_gravity_flipped:
		gravity_force = -gravity_force
	
	if not is_on_floor():
		velocity.y += gravity_force * delta

func handle_movement(delta):
	"""Handle basic movement and jumping"""
	# Horizontal movement
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * HORIZONTAL_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, HORIZONTAL_SPEED * 2 * delta)
	
	# Coyote time
	if is_on_floor():
		coyote_timer = coyote_time
		double_jumps_remaining = 1 if double_jump_enabled else 0
	
	# Jumping
	if jump_buffer_timer > 0 and (coyote_timer > 0 or double_jumps_remaining > 0):
		perform_jump()
		jump_buffer_timer = 0

func perform_jump():
	"""Perform jump with power-up considerations"""
	var jump_force = JUMP_VELOCITY
	
	# Apply bounce multiplier from bouncy platforms
	jump_force *= bounce_multiplier
	
	# Handle double jump
	if not is_on_floor() and double_jumps_remaining > 0:
		double_jumps_remaining -= 1
		emit_signal("power_up_ability_used", "double_jump")
		create_double_jump_effect()
	
	# Apply gravity flip
	if is_gravity_flipped:
		jump_force = -jump_force
	
	velocity.y = jump_force
	coyote_timer = 0

func handle_power_up_abilities(delta):
	"""Handle special power-up abilities"""
	# Wall jump
	if wall_jump_enabled:
		handle_wall_jump()
	
	# Teleport dash
	if teleport_dash_enabled and Input.is_action_just_pressed("dash") and can_teleport_dash:
		perform_teleport_dash()
	
	# Platform magnet
	if platform_magnet_enabled:
		apply_platform_magnet()
	
	# Time control
	if time_control_enabled:
		handle_time_control()
	
	# Platform creation
	if platform_creation_enabled and Input.is_action_just_pressed("create_platform"):
		create_platform_at_cursor()

func handle_wall_jump():
	"""Handle wall jumping mechanics"""
	# Check for wall contact
	var wall_normal = Vector2.ZERO
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if abs(collision.get_normal().x) > 0.7:  # Vertical wall
			wall_normal = collision.get_normal()
			break
	
	if wall_normal != Vector2.ZERO and not is_on_floor():
		is_wall_sliding = true
		# Reduce fall speed when wall sliding
		velocity.y = min(velocity.y, 100)
		
		# Wall jump
		if Input.is_action_just_pressed("ui_accept") and wall_normal.x != 0:
			velocity.x = wall_normal.x * HORIZONTAL_SPEED * 1.2
			velocity.y = JUMP_VELOCITY * 0.8
			emit_signal("power_up_ability_used", "wall_jump")
			create_wall_jump_effect()
	else:
		is_wall_sliding = false

func perform_teleport_dash():
	"""Perform teleport dash ability"""
	if not can_teleport_dash:
		return
	
	var dash_direction = Vector2.ZERO
	
	# Get input direction
	if Input.is_action_pressed("ui_left"):
		dash_direction.x = -1
	elif Input.is_action_pressed("ui_right"):
		dash_direction.x = 1
	
	if Input.is_action_pressed("ui_up"):
		dash_direction.y = -1
	elif Input.is_action_pressed("ui_down"):
		dash_direction.y = 1
	
	# Default to forward if no input
	if dash_direction == Vector2.ZERO:
		dash_direction = Vector2(1 if velocity.x >= 0 else -1, 0)
	
	dash_direction = dash_direction.normalized()
	
	# Perform dash
	var dash_distance = 200.0
	global_position += dash_direction * dash_distance
	
	# Set cooldown
	can_teleport_dash = false
	teleport_dash_timer = teleport_dash_cooldown
	
	emit_signal("power_up_ability_used", "teleport_dash")
	create_teleport_dash_effect()

func apply_platform_magnet():
	"""Apply magnetic force to nearby platforms"""
	var platforms = get_tree().get_nodes_in_group("platforms")
	for platform in platforms:
		var distance = global_position.distance_to(platform.global_position)
		if distance < magnet_range:
			var direction = (global_position - platform.global_position).normalized()
			var force = (magnet_range - distance) / magnet_range * 50.0
			
			# Move platform towards player
			if platform.has_method("apply_magnetic_force"):
				platform.apply_magnetic_force(direction * force)

func handle_time_control():
	"""Handle time control abilities"""
	if Input.is_action_just_pressed("slow_time"):
		Engine.time_scale = 0.3
		emit_signal("power_up_ability_used", "slow_time")
	elif Input.is_action_just_released("slow_time"):
		Engine.time_scale = 1.0
	
	if Input.is_action_just_pressed("rewind_time"):
		rewind_position(rewind_speed)
		emit_signal("power_up_ability_used", "time_rewind")

func create_platform_at_cursor():
	"""Create platform at cursor/touch position"""
	var cursor_pos = get_global_mouse_position()
	
	# Create temporary platform
	var platform_scene = preload("res://scenes/TempPlatform.tscn")
	if platform_scene:
		var platform = platform_scene.instantiate()
		platform.global_position = cursor_pos
		get_parent().add_child(platform)
		
		emit_signal("power_up_ability_used", "platform_creation")
		create_platform_creation_effect(cursor_pos)

func check_platform_interactions():
	"""Check for special platform interactions"""
	if is_on_floor():
		var platform = get_floor_collision()
		if platform:
			# Handle sticky platforms
			if sticky_platform_contact and platform.has_method("is_sticky"):
				if platform.is_sticky():
					velocity.x *= 0.5  # Reduce horizontal movement
			
			# Emit platform landed signal
			emit_signal("platform_landed", global_position.y)

func get_floor_collision() -> Node:
	"""Get the platform we're standing on"""
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_normal().y < -0.7:  # Floor collision
			return collision.get_collider()
	return null

func update_visual_effects(delta):
	"""Update visual effects for power-ups"""
	# Ghost mode transparency
	if ghost_mode_enabled:
		ghost_alpha = 0.5 + sin(Time.get_time_dict_from_system().second * 5) * 0.2
		modulate.a = ghost_alpha
	else:
		modulate.a = 1.0
	
	# Dimension shift effect
	if dimension_shift_enabled:
		dimension_shift_phase += delta * 3.0
		var shift_offset = sin(dimension_shift_phase) * 5.0
		position.x += shift_offset

# Power-up activation methods
func enable_double_jump():
	"""Enable double jump ability"""
	double_jump_enabled = true
	double_jumps_remaining = 1

func disable_double_jump():
	"""Disable double jump ability"""
	double_jump_enabled = false
	double_jumps_remaining = 0

func enable_wall_jump():
	"""Enable wall jump ability"""
	wall_jump_enabled = true

func disable_wall_jump():
	"""Disable wall jump ability"""
	wall_jump_enabled = false
	is_wall_sliding = false

func enable_teleport_dash():
	"""Enable teleport dash ability"""
	teleport_dash_enabled = true
	can_teleport_dash = true

func disable_teleport_dash():
	"""Disable teleport dash ability"""
	teleport_dash_enabled = false

func enable_ghost_mode():
	"""Enable ghost mode (phase through platforms)"""
	ghost_mode_enabled = true
	collision_mask &= ~2  # Remove platform collision

func disable_ghost_mode():
	"""Disable ghost mode"""
	ghost_mode_enabled = false
	collision_mask |= 2  # Restore platform collision

func enable_platform_magnet():
	"""Enable platform magnet ability"""
	platform_magnet_enabled = true

func disable_platform_magnet():
	"""Disable platform magnet ability"""
	platform_magnet_enabled = false

func enable_time_control():
	"""Enable time control abilities"""
	time_control_enabled = true

func enable_platform_creation():
	"""Enable platform creation ability"""
	platform_creation_enabled = true

func enable_advanced_platform_creation():
	"""Enable advanced platform creation"""
	platform_creation_enabled = true

func enable_dimension_shift():
	"""Enable dimension shift ability"""
	dimension_shift_enabled = true

func grant_revival():
	"""Grant phoenix revival ability"""
	phoenix_revival_available = true

func apply_wind_force(force: Vector2):
	"""Apply wind force"""
	wind_force = force

func remove_wind_force():
	"""Remove wind force"""
	wind_force = Vector2.ZERO

func rewind_position(seconds: float):
	"""Rewind position by specified seconds"""
	var frames_to_rewind = int(seconds * 60)  # Assuming 60 FPS
	frames_to_rewind = min(frames_to_rewind, position_history.size() - 1)
	
	if frames_to_rewind > 0:
		var rewind_index = position_history.size() - 1 - frames_to_rewind
		global_position = position_history[rewind_index]
		velocity = Vector2.ZERO

# Visual effect creation methods
func create_double_jump_effect():
	"""Create double jump visual effect"""
	pass  # Implement particle effect

func create_wall_jump_effect():
	"""Create wall jump visual effect"""
	pass

func create_teleport_dash_effect():
	"""Create teleport dash visual effect"""
	pass

func create_platform_creation_effect(pos: Vector2):
	"""Create platform creation visual effect"""
	pass

# Death handling with phoenix revival
func die():
	"""Handle player death with revival check"""
	if phoenix_revival_available:
		phoenix_revival_available = false
		# Revive at safe position
		var safe_position = global_position + Vector2(0, -200)
		global_position = safe_position
		velocity = Vector2.ZERO
		
		# Create revival effect
		create_phoenix_revival_effect()
		emit_signal("power_up_ability_used", "phoenix_revival")
	else:
		emit_signal("player_died")

func create_phoenix_revival_effect():
	"""Create phoenix revival visual effect"""
	pass
