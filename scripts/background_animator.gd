extends Node2D

# Background animation system for Hop n' Splat
# Handles animated background elements and effects

# Cloud animation variables
var clouds: Array = []
var cloud_speed: float = 20.0
var cloud_spawn_timer: float = 0.0
var cloud_spawn_interval: float = 8.0
var max_clouds: int = 6
var cloud_texture: Texture2D

# Particle systems
@onready var ambient_particles = $AmbientParticles

func _ready():
	# Load cloud texture
	cloud_texture = preload("res://assets/items/cloud.png")
	print("Cloud texture loaded: ", cloud_texture != null)
	if cloud_texture:
		print("Texture size: ", cloud_texture.get_size())
	
	# Wait a frame before setting up clouds to ensure scene is ready
	await get_tree().process_frame
	
	# Initialize cloud system
	setup_clouds()
	setup_ambient_particles()
	
	print("Background animator initialized")

func setup_clouds():
	"""Initialize cloud system with PNG texture"""
	var parallax_bg = get_node("../ParallaxBackground")
	if parallax_bg:
		var cloud_layer = parallax_bg.get_node("CloudLayer")
		if cloud_layer:
			print("Cloud layer found, creating clouds...")
			# Create initial clouds with texture - safe on screen positions
			spawn_cloud_at_position(cloud_layer, Vector2(50, 150))
			spawn_cloud_at_position(cloud_layer, Vector2(200, 200))
			spawn_cloud_at_position(cloud_layer, Vector2(100, 250))
			print("Created ", clouds.size(), " clouds")
		else:
			print("CloudLayer not found!")
	else:
		print("ParallaxBackground not found!")

func spawn_cloud_at_position(parent: Node, pos: Vector2):
	"""Create a new cloud using the PNG texture"""
	if not cloud_texture:
		print("Cloud texture not loaded!")
		return
		
	var cloud = TextureRect.new()
	cloud.texture = cloud_texture
	cloud.position = pos
	
	# Set appropriate size to fit on screen
	var texture_size = cloud_texture.get_size()
	cloud.size = texture_size * 0.18  # Even smaller size
	cloud.modulate = Color(1, 1, 1, 0.7)  # Semi-transparent
	
	# Add random variation
	var scale_factor = randf_range(0.8, 1.2)
	cloud.size *= scale_factor
	
	# Ensure visibility - try different settings
	cloud.visible = true
	cloud.z_index = 10  # Much higher z-index
	cloud.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't block mouse
	
	# Debug texture info
	print("Texture size: ", texture_size, " Final cloud size: ", cloud.size)
	
	parent.add_child(cloud)
	clouds.append(cloud)
	print("Spawned cloud at position: ", pos, " with size: ", cloud.size, " visible: ", cloud.visible)

func setup_ambient_particles():
	"""Setup ambient particle effects"""
	if ambient_particles:
		ambient_particles.emitting = true
		ambient_particles.amount = 30
		ambient_particles.lifetime = 8.0
		ambient_particles.emission_shape = 2  # BOX shape
		ambient_particles.emission_rect_extents = Vector2(300, 500)
		ambient_particles.direction = Vector2(0, 1)
		ambient_particles.spread = 15.0
		ambient_particles.initial_velocity_min = 10.0
		ambient_particles.initial_velocity_max = 30.0
		ambient_particles.gravity = Vector2(0, -20)
		ambient_particles.scale_amount_min = 0.2
		ambient_particles.scale_amount_max = 0.8
		ambient_particles.color = Color(1, 1, 1, 0.3)

func _process(delta):
	# Animate clouds
	animate_clouds(delta)
	
	# Update cloud spawning
	update_cloud_spawning(delta)
	
	# Disable background positioning - causing issues
	# update_background_position()

func animate_clouds(delta):
	"""Animate cloud movement with parallax effect"""
	var camera = get_viewport().get_camera_2d()
	var camera_y = 0
	if camera:
		camera_y = camera.global_position.y
	
	for cloud in clouds:
		if cloud and is_instance_valid(cloud):
			# Move clouds horizontally
			cloud.position.x += cloud_speed * delta
			
			# Create illusion of player jumping higher by moving clouds down slightly
			# as player goes up (opposite parallax effect)
			cloud.position.y += 5.0 * delta  # Slow downward drift
			
			# Wrap around screen horizontally
			if cloud.position.x > 540:  # Use actual screen width
				# Calculate safe spawn position accounting for cloud size
				var cloud_width = cloud.size.x if cloud.size.x > 0 else 100
				cloud.position.x = -cloud_width  # Start completely off-screen left
				# Respawn at camera level with some variation
				cloud.position.y = camera_y + randf_range(-200, 50)
			
			# Remove clouds that are too far below camera
			if cloud.position.y > camera_y + 500:
				cloud.queue_free()
				clouds.erase(cloud)

func update_cloud_spawning(delta):
	"""Spawn new clouds periodically with limit"""
	cloud_spawn_timer += delta
	
	# Clean up invalid clouds first
	clouds = clouds.filter(func(cloud): return cloud != null and is_instance_valid(cloud))
	
	if cloud_spawn_timer >= cloud_spawn_interval and clouds.size() < max_clouds:
		cloud_spawn_timer = 0.0
		spawn_new_cloud()

func spawn_new_cloud():
	"""Create and spawn a new cloud using PNG texture"""
	var parallax_bg = get_node("../ParallaxBackground")
	if parallax_bg:
		var cloud_layer = parallax_bg.get_node("CloudLayer")
		if cloud_layer:
			# Get camera position to spawn clouds relative to player height
			var camera = get_viewport().get_camera_2d()
			var camera_y = 0
			if camera:
				camera_y = camera.global_position.y
			
			# Calculate cloud size to ensure proper boundaries
			var texture_size = cloud_texture.get_size()
			var base_cloud_size = texture_size * 0.18
			var scale_factor = randf_range(0.8, 1.2)
			var cloud_size = base_cloud_size * scale_factor
			
			# Spawn cloud across full screen width accounting for cloud size
			var max_x = max(0, 540 - cloud_size.x)  # Ensure we don't get negative range
			var spawn_pos = Vector2(
				randf_range(0, max_x),  # Distribute across entire screen width
				camera_y + randf_range(-300, 100)  # Spawn above and around camera
			)
			spawn_cloud_at_position(cloud_layer, spawn_pos)

func spawn_dynamic_cloud():
	"""Spawn a new dynamic cloud"""
	var parallax_bg = get_node("../ParallaxBackground")
	if not parallax_bg:
		return
		
	var cloud_layer = parallax_bg.get_node("CloudLayer")
	if not cloud_layer:
		return
	
	# Create new cloud
	var new_cloud = ColorRect.new()
	new_cloud.size = Vector2(randf_range(80, 150), randf_range(30, 60))
	new_cloud.position = Vector2(-100, randf_range(50, 500))
	new_cloud.color = Color(1, 1, 1, randf_range(0.4, 0.8))
	new_cloud.name = "DynamicCloud" + str(randi())
	
	cloud_layer.add_child(new_cloud)
	clouds.append(new_cloud)
	
	# Remove old clouds to prevent memory buildup
	if clouds.size() > 10:
		var old_cloud = clouds.pop_front()
		if old_cloud and is_instance_valid(old_cloud):
			old_cloud.queue_free()

func add_boost_particles(boost_position: Vector2):
	"""Add special particle effect for boost collection"""
	var boost_particles = CPUParticles2D.new()
	add_child(boost_particles)
	
	boost_particles.global_position = boost_position
	boost_particles.emitting = true
	boost_particles.amount = 25
	boost_particles.lifetime = 1.5
	boost_particles.emission_shape = 1  # SPHERE shape
	boost_particles.emission_sphere_radius = 30.0
	boost_particles.direction = Vector2(0, -1)
	boost_particles.spread = 60.0
	boost_particles.initial_velocity_min = 40.0
	boost_particles.initial_velocity_max = 100.0
	boost_particles.gravity = Vector2(0, 50)
	boost_particles.scale_amount_min = 0.5
	boost_particles.scale_amount_max = 1.5
	boost_particles.color = Color(1, 0.8, 0, 1)
	
	# Auto-remove after effect
	await get_tree().create_timer(2.0).timeout
	if boost_particles and is_instance_valid(boost_particles):
		boost_particles.queue_free()

func update_background_position():
	"""Update background layers to follow camera and extend infinitely"""
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return
	
	var camera_y = camera.global_position.y
	var parallax_bg = get_node("../ParallaxBackground")
	
	if parallax_bg:
		# Update sky layer position - always extend upward
		var sky_layer = parallax_bg.get_node("SkyLayer")
		if sky_layer:
			var sky_rect = sky_layer.get_node("SkyRect")
			if sky_rect:
				# Always keep sky background well above camera
				sky_rect.position.y = camera_y - 2000
				sky_rect.size.y = 8000  # Large height to cover all areas
		
		# Update mid layer position - always extend upward
		var mid_layer = parallax_bg.get_node("MidLayer")
		if mid_layer:
			var mid_rect = mid_layer.get_node("MidRect")
			if mid_rect:
				# Always keep mid background well above camera
				mid_rect.position.y = camera_y - 2000
				mid_rect.size.y = 8000  # Large height to cover all areas
