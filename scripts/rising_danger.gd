extends Area2D

# Rising Danger System for Hop n' Splat
# Creates urgency by having lava rise from bottom, forcing player to keep climbing

# Rising danger properties
var rise_speed: float = 12.0  # Base speed (pixels per second) - reduced
var current_speed: float = 12.0
var max_speed: float = 45.0  # Reduced max speed
var acceleration: float = 1.5  # Slower acceleration
var start_delay: float = 5.0  # Longer delay before danger starts rising

# Game state
var is_rising: bool = false
var game_started: bool = false
var start_timer: float = 0.0

# Visual effects
@onready var lava_sprite = $LavaSprite
@onready var lava_particles = $LavaParticles
@onready var bubble_particles = $BubbleParticles
@onready var collision_shape = $CollisionShape2D
@onready var warning_zone = $WarningZone

# Audio
@onready var lava_sound = $LavaSound
@onready var warning_sound = $WarningSound

# Screen shake reference
var camera: Camera2D
var player: CharacterBody2D

func _ready():
	"""Initialize rising danger system"""
	# Connect collision signal
	body_entered.connect(_on_body_entered)
	
	# Find camera and player references
	camera = get_viewport().get_camera_2d()
	player = get_node("../Player")
	
	# Setup initial position (start well below screen)
	global_position.y = 1400
	
	# Setup visual effects
	setup_visual_effects()
	
	print("Rising danger system initialized")

func _process(delta):
	"""Update rising danger each frame"""
	if not game_started:
		return
	
	# Handle start delay
	if not is_rising:
		start_timer += delta
		if start_timer >= start_delay:
			start_rising()
		return
	
	# Update rising speed (progressive difficulty)
	current_speed = min(current_speed + acceleration * delta, max_speed)
	
	# Move danger upward
	global_position.y -= current_speed * delta
	
	# Update visual effects
	update_visual_effects()
	
	# Check warning distance
	check_warning_distance()

func start_game():
	"""Called when game starts"""
	game_started = true
	start_timer = 0.0
	print("Rising danger: Game started, beginning countdown")

func start_rising():
	"""Begin the rising danger"""
	is_rising = true
	if lava_sound:
		lava_sound.play()
	
	# Start particle effects
	if lava_particles:
		lava_particles.emitting = true
	if bubble_particles:
		bubble_particles.emitting = true
	
	print("Rising danger: Lava is now rising!")

func setup_visual_effects():
	"""Setup lava visual effects"""
	# Setup lava sprite (ColorRect for now, can be replaced with texture)
	if lava_sprite:
		lava_sprite.size = Vector2(600, 200)  # Wide enough to cover screen
		lava_sprite.color = Color(1, 0.3, 0, 0.9)  # Orange-red lava color
		lava_sprite.position = Vector2(-50, -100)  # Center and offset
	
	# Setup lava particles
	if lava_particles:
		lava_particles.emitting = false
		lava_particles.amount = 40
		lava_particles.lifetime = 2.0
		lava_particles.emission_shape = 2  # BOX
		lava_particles.emission_rect_extents = Vector2(300, 20)
		lava_particles.direction = Vector2(0, -1)
		lava_particles.spread = 30.0
		lava_particles.initial_velocity_min = 30.0
		lava_particles.initial_velocity_max = 80.0
		lava_particles.gravity = Vector2(0, 20)
		lava_particles.scale_amount_min = 0.3
		lava_particles.scale_amount_max = 1.2
		lava_particles.color = Color(1, 0.5, 0, 1)
	
	# Setup bubble particles
	if bubble_particles:
		bubble_particles.emitting = false
		bubble_particles.amount = 25
		bubble_particles.lifetime = 1.5
		bubble_particles.emission_shape = 2  # BOX
		bubble_particles.emission_rect_extents = Vector2(280, 15)
		bubble_particles.direction = Vector2(0, -1)
		bubble_particles.spread = 20.0
		bubble_particles.initial_velocity_min = 20.0
		bubble_particles.initial_velocity_max = 50.0
		bubble_particles.gravity = Vector2(0, -30)
		bubble_particles.scale_amount_min = 0.2
		bubble_particles.scale_amount_max = 0.8
		bubble_particles.color = Color(1, 0.8, 0.2, 0.7)

func update_visual_effects():
	"""Update visual effects based on speed"""
	if not is_rising:
		return
	
	# Increase particle intensity with speed
	var intensity_factor = current_speed / max_speed
	
	if lava_particles:
		lava_particles.amount = int(40 + (intensity_factor * 20))
		lava_particles.initial_velocity_max = 80 + (intensity_factor * 40)
	
	if bubble_particles:
		bubble_particles.amount = int(25 + (intensity_factor * 15))

func check_warning_distance():
	"""Check if player is getting close to danger"""
	if not player or not is_rising:
		return
	
	var distance_to_player = player.global_position.y - global_position.y
	var warning_distance = 400.0
	var critical_distance = 50.0  # Only shake when very close
	
	# Show warning when danger gets close
	if distance_to_player < warning_distance:
		show_warning()
		
		# Extremely subtle screen shake only when almost touching
		if distance_to_player < critical_distance and distance_to_player > 0:
			var shake_intensity = (critical_distance - distance_to_player) / critical_distance
			if camera and shake_intensity > 0.8:  # Higher threshold
				shake_screen(shake_intensity * 0.1)  # Much more subtle

func show_warning():
	"""Show visual warning that danger is close"""
	if warning_zone:
		warning_zone.visible = true
		# Gentler pulsing effect
		var pulse_time = Time.get_time_dict_from_system()["second"] * 3.0
		warning_zone.modulate.a = 0.3 + sin(pulse_time) * 0.2
	
	# Play warning sound less frequently
	if warning_sound and not warning_sound.playing:
		if randf() < 0.005:  # Reduced from 2% to 0.5% chance per frame
			warning_sound.play()

func shake_screen(_intensity: float):
	"""Apply very subtle screen shake effect"""
	# Disabled for now - no screen shake from rising danger
	pass

func _on_body_entered(body):
	"""Handle collision with player"""
	if body.name == "Player":
		print("Rising danger: Player caught by lava!")
		trigger_game_over()

func trigger_game_over():
	"""Trigger game over when player touches danger"""
	# Stop rising
	is_rising = false
	
	# No screen shake for game over - keep it smooth
	
	# Trigger game over using the correct method name
	var main_scene = get_node("../")
	if main_scene and main_scene.has_method("trigger_game_over"):
		main_scene.trigger_game_over()
	else:
		print("Warning: Could not find main scene or trigger_game_over method")

func pause_rising(duration: float):
	"""Temporarily pause rising (for boost items)"""
	if not is_rising:
		return
	
	var original_speed = current_speed
	current_speed = 0.0
	
	await get_tree().create_timer(duration).timeout
	current_speed = original_speed
	
	print("Rising danger: Resumed after pause")

func get_danger_height() -> float:
	"""Get current danger height for UI display"""
	return global_position.y

func reset():
	"""Reset danger system for new game"""
	is_rising = false
	game_started = false
	start_timer = 0.0
	current_speed = rise_speed
	global_position.y = 1400  # Move further down to ensure player is safe
	
	# Stop effects
	if lava_particles:
		lava_particles.emitting = false
	if bubble_particles:
		bubble_particles.emitting = false
	if warning_zone:
		warning_zone.visible = false
	if lava_sound:
		lava_sound.stop()
	
	print("Rising danger reset to position: ", global_position.y)
