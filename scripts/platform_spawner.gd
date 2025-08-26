extends Node2D

@export var platform_scene: PackedScene
@export var moving_platform_scene: PackedScene = preload("res://scenes/moving_platform.tscn")
@export var splat_obstacle_scene: PackedScene = preload("res://scenes/splat_obstacle.tscn")
# Moving platform difficulty progression will be calculated dynamically
@export var obstacle_score_threshold: int = 70  # Score when obstacles start appearing
@export var max_obstacle_chance: float = 0.6  # Maximum obstacle chance at high scores
@export var vertical_spacing: float = 150  # Increased spacing between platforms
@export var horizontal_range: float = 200  # Increased horizontal variation
@export var initial_platform_count: int = 8
@export var camera_path: NodePath

var last_platform_y = 800.0  # Start spawning above initial player position
var camera: Node2D
var platforms := []
var obstacles := []  # Track splat obstacles

func _ready():
	if camera_path != null:
		camera = get_node(camera_path)
	else:
		push_error("Camera path not set in PlatformSpawner!")
	
	# Spawn initial platforms starting from above player position
	for i in range(initial_platform_count):
		spawn_platform(last_platform_y - (i * vertical_spacing))

func _process(_delta):
	if camera == null:
		return
	
	var buffer_distance = 1200  # distance ahead of camera to keep spawning
	# Continuously spawn platforms as camera moves up (going negative Y)
	while last_platform_y > camera.global_position.y - buffer_distance:
		last_platform_y -= vertical_spacing  # Move up (negative Y)
		spawn_platform(last_platform_y)

	# Remove platforms and obstacles way below camera (positive Y direction)
	var remove_distance = camera.global_position.y + 600  # Remove platforms below camera
	var platforms_to_remove = []
	var obstacles_to_remove = []
	
	for platform in platforms:
		if platform != null and is_instance_valid(platform):
			if platform.global_position.y > remove_distance:
				platforms_to_remove.append(platform)
	
	for obstacle in obstacles:
		if obstacle != null and is_instance_valid(obstacle):
			if obstacle.global_position.y > remove_distance:
				obstacles_to_remove.append(obstacle)
	
	# Remove old platforms and obstacles
	for platform in platforms_to_remove:
		platforms.erase(platform)
		if platform.get_parent():
			platform.queue_free()
	
	for obstacle in obstacles_to_remove:
		obstacles.erase(obstacle)
		if obstacle.get_parent():
			obstacle.queue_free()

func spawn_platform(y):
	if platform_scene == null:
		push_error("Platform scene not assigned!")
		return
	
	# Decide if this should be a moving platform based on progressive difficulty
	var platform
	var moving_chance = calculate_moving_platform_chance()
	print("DEBUG: Moving platform chance calculated: ", moving_chance)
	if randf() < moving_chance:
		platform = moving_platform_scene.instantiate()
	else:
		platform = platform_scene.instantiate()
	var screen_width = get_viewport_rect().size.x
	var margin = 80  # Increased margin for better gameplay

	# Better horizontal distribution with some randomness
	var x = randf_range(margin, screen_width - margin)
	
	# Ensure platforms aren't too close horizontally to previous ones
	if platforms.size() > 0:
		var last_platform = platforms[-1]
		if last_platform != null and is_instance_valid(last_platform):
			var last_x = last_platform.global_position.x
			# If too close horizontally, adjust position
			if abs(x - last_x) < 100:
				if x < screen_width / 2:
					x = min(last_x + 120, screen_width - margin)
				else:
					x = max(last_x - 120, margin)
	
	platform.position = Vector2(x, y)
	
	# Configure moving platform if it's a moving one
	if platform.has_method("set_movement_pattern"):
		# Get current score for dynamic parameters
		var main_game = get_node("/root/Main")
		var current_score = 0
		if main_game:
			current_score = main_game.current_score
		
		# Get progressive movement parameters
		var params = get_movement_params(current_score)
		var available_patterns = params.patterns
		
		# Select pattern and parameters based on score
		var direction = available_patterns[randi() % available_patterns.size()]
		var move_range = randf_range(params.range_min, params.range_max)
		var speed = randf_range(params.speed_min, params.speed_max)
		
		print("DEBUG: Moving platform - Score: ", current_score, " Speed: ", speed, " Range: ", move_range, " Pattern: ", direction)
		platform.set_movement_pattern(direction, move_range, speed)
	
	add_child(platform)
	platforms.append(platform)
	
	# Randomly spawn splat obstacles based on progressive difficulty
	var current_obstacle_chance = calculate_obstacle_chance()
	print("DEBUG: Obstacle chance calculated: ", current_obstacle_chance)
	if current_obstacle_chance > 0 and randf() < current_obstacle_chance:
		print("DEBUG: Spawning splat obstacle!")
		spawn_splat_obstacle(y)

func spawn_splat_obstacle(y):
	"""Spawn a splat obstacle at the given Y position"""
	if splat_obstacle_scene == null:
		push_error("Splat obstacle scene not assigned!")
		return
	
	var obstacle = splat_obstacle_scene.instantiate()
	var screen_width = get_viewport_rect().size.x
	var margin = 60
	
	# Random horizontal position
	var x = randf_range(margin, screen_width - margin)
	
	# Random obstacle type
	var obstacle_types = [0, 1, 2, 3]  # SPIKE, BOUNCER, ROTATOR, FALLING
	var random_type = obstacle_types[randi() % obstacle_types.size()]
	
	# Position the obstacle
	obstacle.position = Vector2(x, y - 50)  # Slightly above platform
	
	# Set the obstacle type
	obstacle.set_splat_type(random_type)
	
	add_child(obstacle)
	obstacles.append(obstacle)

func calculate_obstacle_chance() -> float:
	"""Calculate obstacle spawn chance based on current score"""
	# Get current score from main game
	var main_game = get_node("/root/Main")
	if not main_game:
		return 0.0
	
	var current_score = main_game.current_score
	print("DEBUG: Current score for obstacle calculation: ", current_score)
	
	# Progressive difficulty based on score ranges
	if current_score < 70:
		return 0.0  # 0% obstacles
	elif current_score < 110:
		return 0.09  # 9% obstacles
	elif current_score < 180:
		return 0.15  # 15% obstacles
	elif current_score < 250:
		return 0.24  # 24% obstacles
	elif current_score < 320:
		return 0.31  # 31% obstacles
	elif current_score < 390:
		return 0.40  # 40% obstacles
	elif current_score < 500:
		return 0.45  # 45% obstacles
	else:
		# 45-60% obstacles with gradual increase after 500
		var score_above_500 = current_score - 500
		var additional_chance = (score_above_500 / 1000.0) * 0.15  # +15% over 1000 points
		return min(0.45 + additional_chance, max_obstacle_chance)

func calculate_moving_platform_chance() -> float:
	"""Calculate moving platform spawn chance based on current score"""
	# Get current score from main game
	var main_game = get_node("/root/Main")
	if not main_game:
		return 0.15  # Default to 15% if no score available
	
	var current_score = main_game.current_score
	print("DEBUG: Current score for moving platform calculation: ", current_score)
	
	# Progressive difficulty based on score ranges
	if current_score < 100:
		# Learning Phase: 15-25%
		return lerp(0.15, 0.25, current_score / 100.0)
	elif current_score < 200:
		# Skill Building: 25-35%
		return lerp(0.25, 0.35, (current_score - 100) / 100.0)
	elif current_score < 350:
		# Challenge Introduction: 35-45%
		return lerp(0.35, 0.45, (current_score - 200) / 150.0)
	elif current_score < 500:
		# Expert Level: 45-55%
		return lerp(0.45, 0.55, (current_score - 350) / 150.0)
	else:
		# Master Level: 55-70% (gradual increase)
		var score_above_500 = current_score - 500
		var additional_chance = (score_above_500 / 1000.0) * 0.15  # +15% over 1000 points
		return min(0.55 + additional_chance, 0.70)

func get_movement_params(current_score: int) -> Dictionary:
	"""Get movement parameters based on current score"""
	# Base parameters that scale with score
	var speed_min = 30 + (current_score / 10.0)
	var speed_max = 45 + (current_score / 8.0)
	var range_min = 60 + (current_score / 12.0)
	var range_max = 80 + (current_score / 10.0)
	
	# Cap the values to prevent extreme difficulty
	speed_min = min(speed_min, 70)
	speed_max = min(speed_max, 100)
	range_min = min(range_min, 100)
	range_max = min(range_max, 150)
	
	return {
		"speed_min": speed_min,
		"speed_max": speed_max,
		"range_min": range_min,
		"range_max": range_max,
		"patterns": get_available_patterns(current_score)
	}

func get_available_patterns(current_score: int) -> Array:
	"""Get available movement patterns based on score"""
	var patterns = []
	
	# Always available: Horizontal movement
	patterns.append(Vector2(1, 0))
	
	# Available from score 101+: Vertical movement
	if current_score >= 101:
		patterns.append(Vector2(0, 1))
	
	# Available from score 201+: Diagonal movement
	if current_score >= 201:
		patterns.append(Vector2(1, 0.5).normalized())
		patterns.append(Vector2(-1, 0.5).normalized())
	
	# Available from score 351+: More complex patterns
	if current_score >= 351:
		patterns.append(Vector2(0.7, 0.7).normalized())  # Diagonal variations
		patterns.append(Vector2(-0.7, 0.7).normalized())
	
	return patterns
