extends Node2D

# Particle Effects System for Enhanced Game Feel
class_name ParticleEffects

# Particle scenes and materials
var jump_particles: GPUParticles2D
var landing_particles: GPUParticles2D
var coin_collect_particles: GPUParticles2D
var boost_particles: GPUParticles2D

func _ready():
	setup_particle_systems()

func setup_particle_systems():
	"""Initialize all particle systems"""
	# Jump particles - upward burst when jumping
	jump_particles = create_jump_particles()
	add_child(jump_particles)
	
	# Landing particles - impact effect when landing on platforms
	landing_particles = create_landing_particles()
	add_child(landing_particles)
	
	# Coin collection particles - sparkle effect
	coin_collect_particles = create_coin_particles()
	add_child(coin_collect_particles)
	
	# Boost activation particles - power-up glow
	boost_particles = create_boost_particles()
	add_child(boost_particles)

func create_jump_particles() -> GPUParticles2D:
	"""Create particle system for jump effects"""
	var particles = GPUParticles2D.new()
	particles.emitting = false
	particles.amount = 20
	particles.lifetime = 1.0
	particles.one_shot = true
	
	# Create process material
	var process_material = ParticleProcessMaterial.new()
	process_material.direction = Vector3(0, -1, 0)
	process_material.initial_velocity_min = 50.0
	process_material.initial_velocity_max = 100.0
	process_material.angular_velocity_min = -180.0
	process_material.angular_velocity_max = 180.0
	process_material.gravity = Vector3(0, 98, 0)
	process_material.scale_min = 0.5
	process_material.scale_max = 1.5
	process_material.color = Color.CYAN
	
	particles.process_material = process_material
	particles.texture = create_particle_texture()
	
	return particles

func create_landing_particles() -> GPUParticles2D:
	"""Create particle system for landing effects"""
	var particles = GPUParticles2D.new()
	particles.emitting = false
	particles.amount = 15
	particles.lifetime = 0.8
	particles.one_shot = true
	
	# Create process material
	var process_material = ParticleProcessMaterial.new()
	process_material.direction = Vector3(0, -1, 0)
	process_material.initial_velocity_min = 30.0
	process_material.initial_velocity_max = 80.0
	process_material.angular_velocity_min = -90.0
	process_material.angular_velocity_max = 90.0
	process_material.gravity = Vector3(0, 150, 0)
	process_material.scale_min = 0.3
	process_material.scale_max = 1.0
	process_material.color = Color.WHITE
	
	# Spread particles horizontally
	process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process_material.emission_box_extents = Vector3(20, 5, 0)
	
	particles.process_material = process_material
	particles.texture = create_particle_texture()
	
	return particles

func create_coin_particles() -> GPUParticles2D:
	"""Create particle system for coin collection effects"""
	var particles = GPUParticles2D.new()
	particles.emitting = false
	particles.amount = 10
	particles.lifetime = 0.6
	particles.one_shot = true
	
	# Create process material
	var process_material = ParticleProcessMaterial.new()
	process_material.direction = Vector3(0, -1, 0)
	process_material.initial_velocity_min = 20.0
	process_material.initial_velocity_max = 60.0
	process_material.angular_velocity_min = -360.0
	process_material.angular_velocity_max = 360.0
	process_material.gravity = Vector3(0, 50, 0)
	process_material.scale_min = 0.8
	process_material.scale_max = 1.2
	process_material.color = Color.GOLD
	
	# Radial emission
	process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	
	particles.process_material = process_material
	particles.texture = create_particle_texture()
	
	return particles

func create_boost_particles() -> GPUParticles2D:
	"""Create particle system for boost activation effects"""
	var particles = GPUParticles2D.new()
	particles.emitting = false
	particles.amount = 25
	particles.lifetime = 1.2
	particles.one_shot = true
	
	# Create process material
	var process_material = ParticleProcessMaterial.new()
	process_material.direction = Vector3(0, 0, 0)
	process_material.initial_velocity_min = 40.0
	process_material.initial_velocity_max = 80.0
	process_material.angular_velocity_min = -180.0
	process_material.angular_velocity_max = 180.0
	process_material.gravity = Vector3(0, -20, 0)  # Slight upward drift
	process_material.scale_min = 0.6
	process_material.scale_max = 1.4
	process_material.color = Color.MAGENTA
	
	# Radial burst
	process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	
	particles.process_material = process_material
	particles.texture = create_particle_texture()
	
	return particles

func create_particle_texture() -> ImageTexture:
	"""Create a simple circular particle texture"""
	var image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	var center = Vector2(8, 8)
	
	# Draw a circle
	for x in range(16):
		for y in range(16):
			var distance = Vector2(x, y).distance_to(center)
			if distance <= 6:
				var alpha = 1.0 - (distance / 6.0)
				image.set_pixel(x, y, Color(1, 1, 1, alpha))
			else:
				image.set_pixel(x, y, Color.TRANSPARENT)
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

# Public methods to trigger effects
func play_jump_effect(pos: Vector2):
	"""Play jump particle effect at position"""
	jump_particles.global_position = pos
	jump_particles.restart()

func play_landing_effect(pos: Vector2):
	"""Play landing particle effect at position"""
	landing_particles.global_position = pos
	landing_particles.restart()

func play_coin_collect_effect(pos: Vector2):
	"""Play coin collection particle effect at position"""
	coin_collect_particles.global_position = pos
	coin_collect_particles.restart()

func play_boost_effect(pos: Vector2):
	"""Play boost activation particle effect at position"""
	boost_particles.global_position = pos
	boost_particles.restart()
