extends Node2D

@export var platform_scene: PackedScene
@export var moving_platform_scene: PackedScene = preload("res://scenes/moving_platform.tscn")
@export var moving_platform_chance: float = 0.3  # 30% chance to spawn moving platform
@export var vertical_spacing: float = 150  # Increased spacing between platforms
@export var horizontal_range: float = 200  # Increased horizontal variation
@export var initial_platform_count: int = 8
@export var camera_path: NodePath

var last_platform_y = 800.0  # Start spawning above initial player position
var camera: Node2D
var platforms := []

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

	# Remove platforms way below camera (positive Y direction)
	var remove_distance = camera.global_position.y + 600  # Remove platforms below camera
	var platforms_to_remove = []
	
	for platform in platforms:
		if platform != null and is_instance_valid(platform):
			if platform.global_position.y > remove_distance:
				platforms_to_remove.append(platform)
	
	# Remove old platforms
	for platform in platforms_to_remove:
		platforms.erase(platform)
		if platform.get_parent():
			platform.queue_free()

func spawn_platform(y):
	if platform_scene == null:
		push_error("Platform scene not assigned!")
		return
	
	# Decide whether to spawn moving or static platform
	var use_moving_platform = randf() < moving_platform_chance
	var platform
	
	if use_moving_platform and moving_platform_scene != null:
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
		# Randomize movement patterns
		var movement_types = [
			Vector2(1, 0),  # Horizontal
			Vector2(0, 1),  # Vertical
			Vector2(1, 0.5).normalized()  # Diagonal
		]
		var direction = movement_types[randi() % movement_types.size()]
		var move_range = randf_range(80, 120)
		var speed = randf_range(40, 60)
		platform.set_movement_pattern(direction, move_range, speed)
	
	add_child(platform)
	platforms.append(platform)
