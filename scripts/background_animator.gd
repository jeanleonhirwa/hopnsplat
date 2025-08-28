extends Node2D

# Background animation system for Hop n' Splat
# Handles animated background elements and effects

# Cloud animation variables
var clouds: Array = []
var cloud_speed: float = 20.0
var cloud_spawn_timer: float = 0.0
var cloud_spawn_interval: float = 3.0

# Particle systems
@onready var ambient_particles = $AmbientParticles

func _ready():
	# Find all cloud elements
	find_clouds()
	
	# Setup ambient particles
	setup_ambient_particles()
	
	print("Background animator initialized")

func find_clouds():
	"""Find all cloud elements in the scene"""
	var parallax_bg = get_node("../ParallaxBackground")
	if parallax_bg:
		var cloud_layer = parallax_bg.get_node("CloudLayer")
		if cloud_layer:
			for child in cloud_layer.get_children():
				if "Cloud" in child.name:
					clouds.append(child)
					print("Found cloud: ", child.name)

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
	
	# Update background positioning to follow camera
	update_background_position()

func animate_clouds(delta):
	"""Animate cloud movement"""
	for cloud in clouds:
		if cloud and is_instance_valid(cloud):
			# Move clouds horizontally
			cloud.position.x += cloud_speed * delta
			
			# Wrap around screen
			if cloud.position.x > 600:
				cloud.position.x = -100
				# Randomize vertical position
				cloud.position.y = randf_range(50, 400)

func update_cloud_spawning(delta):
	"""Handle dynamic cloud spawning"""
	cloud_spawn_timer += delta
	
	if cloud_spawn_timer >= cloud_spawn_interval:
		cloud_spawn_timer = 0.0
		spawn_dynamic_cloud()

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
		# Update sky layer position
		var sky_layer = parallax_bg.get_node("SkyLayer")
		if sky_layer:
			var sky_rect = sky_layer.get_node("SkyRect")
			if sky_rect:
				# Extend sky background upward as camera moves up
				if camera_y < sky_rect.position.y:
					sky_rect.position.y = camera_y - 1000
					sky_rect.size.y = 6000
		
		# Update mid layer position
		var mid_layer = parallax_bg.get_node("MidLayer")
		if mid_layer:
			var mid_rect = mid_layer.get_node("MidRect")
			if mid_rect:
				# Extend mid background upward as camera moves up
				if camera_y < mid_rect.position.y:
					mid_rect.position.y = camera_y - 1000
					mid_rect.size.y = 6000
