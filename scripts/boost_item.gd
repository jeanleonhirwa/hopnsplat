extends Area2D

# Boost types available in the game
enum BoostType { JUMP_BOOST, SPEED_BOOST, SHIELD, COIN_MAGNET, DOUBLE_POINTS }

# Configuration
@export var boost_type: BoostType = BoostType.JUMP_BOOST
@export var float_amplitude: float = 10.0  # How much the boost floats up/down
@export var float_speed: float = 2.0  # Speed of floating animation
@export var rotation_speed: float = 90.0  # Degrees per second rotation

# Internal variables
var start_position: Vector2
var time_alive: float = 0.0
var collected: bool = false

# Node references
@onready var sprite: Sprite2D = $Sprite2D
@onready var particles: CPUParticles2D = $Particles
@onready var collection_sound: AudioStreamPlayer = $CollectionSound

func _ready():
	# Connect collision signal
	body_entered.connect(_on_body_entered)
	
	# Store starting position for floating animation
	start_position = global_position
	
	# Configure boost based on type
	setup_boost_type()
	
	# Start particle effects
	if particles:
		particles.emitting = true

func setup_boost_type():
	"""Configure boost appearance and effects based on type"""
	match boost_type:
		BoostType.JUMP_BOOST:
			# Golden upward arrow with sparkles
			sprite.modulate = Color(1.0, 0.8, 0.2, 1.0)  # Golden
			sprite.rotation_degrees = 0  # Upward arrow
			setup_particles(Color.YELLOW, 20)
			
		BoostType.SPEED_BOOST:
			# Blue streak with wind trails
			sprite.modulate = Color(0.2, 0.6, 1.0, 1.0)  # Blue
			sprite.rotation_degrees = 90  # Horizontal arrow
			setup_particles(Color.CYAN, 25)
			
		BoostType.SHIELD:
			# Glowing blue dome
			sprite.modulate = Color(0.4, 0.8, 1.0, 0.8)  # Light blue
			sprite.scale = Vector2(1.2, 1.2)  # Slightly larger
			setup_particles(Color.BLUE, 15)
			
		BoostType.COIN_MAGNET:
			# Golden magnetic field
			sprite.modulate = Color(1.0, 0.7, 0.0, 1.0)  # Gold
			sprite.scale = Vector2(1.1, 1.1)
			setup_particles(Color.ORANGE, 30)
			
		BoostType.DOUBLE_POINTS:
			# Rainbow star with pulsing glow
			sprite.modulate = Color(1.0, 0.5, 1.0, 1.0)  # Magenta
			sprite.scale = Vector2(1.3, 1.3)  # Largest boost
			setup_particles(Color.WHITE, 40)

func setup_particles(color: Color, amount: int):
	"""Configure particle effects for the boost"""
	if particles:
		particles.emission.amount = amount
		particles.color = color
		particles.emission.rate = amount / 2.0
		particles.lifetime = 1.5
		particles.scale_amount_min = 0.5
		particles.scale_amount_max = 1.0

func _physics_process(delta):
	if collected:
		return
		
	time_alive += delta
	
	# Floating animation
	var float_offset = sin(time_alive * float_speed) * float_amplitude
	global_position.y = start_position.y + float_offset
	
	# Rotation animation
	sprite.rotation_degrees += rotation_speed * delta
	
	# Pulsing effect for rare boosts
	if boost_type == BoostType.DOUBLE_POINTS:
		var pulse = 1.0 + sin(time_alive * 4.0) * 0.2
		sprite.scale = Vector2(1.3 * pulse, 1.3 * pulse)

func _on_body_entered(body):
	"""Handle collision with player"""
	if body.name == "Player" and not collected:
		collect_boost(body)

func collect_boost(player):
	"""Apply boost effect to player and remove boost"""
	collected = true
	
	# Play collection sound
	if collection_sound:
		collection_sound.play()
	
	# Apply boost effect to player
	if player.has_method("apply_boost"):
		player.apply_boost(boost_type)
	
	# Create collection effect
	create_collection_effect()
	
	# Remove boost after brief delay for sound/effect
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.3
	timer.one_shot = true
	timer.timeout.connect(queue_free)
	timer.start()
	
	# Hide sprite immediately
	sprite.visible = false
	if particles:
		particles.emitting = false

func create_collection_effect():
	"""Create visual effect when boost is collected"""
	# Scale up effect
	var tween = create_tween()
	tween.parallel().tween_property(sprite, "scale", sprite.scale * 2.0, 0.2)
	tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.2)
	
	# Burst particle effect
	if particles:
		particles.amount = particles.amount * 3
		particles.emitting = true

func set_boost_type(type: BoostType):
	"""Set the boost type (used by spawner)"""
	boost_type = type
	if is_inside_tree():
		setup_boost_type()

func get_boost_info() -> Dictionary:
	"""Get information about this boost type"""
	match boost_type:
		BoostType.JUMP_BOOST:
			return {
				"name": "Jump Boost",
				"description": "1.5x jump height for 8 seconds",
				"duration": 8.0,
				"multiplier": 1.5
			}
		BoostType.SPEED_BOOST:
			return {
				"name": "Speed Boost", 
				"description": "2x movement speed for 6 seconds",
				"duration": 6.0,
				"multiplier": 2.0
			}
		BoostType.SHIELD:
			return {
				"name": "Shield",
				"description": "Immunity to 1 obstacle hit",
				"duration": 0.0,  # Until used
				"uses": 1
			}
		BoostType.COIN_MAGNET:
			return {
				"name": "Coin Magnet",
				"description": "Auto-collect coins for 10 seconds",
				"duration": 10.0,
				"radius": 150.0
			}
		BoostType.DOUBLE_POINTS:
			return {
				"name": "Double Points",
				"description": "2x score multiplier for 12 seconds",
				"duration": 12.0,
				"multiplier": 2.0
			}
		_:
			return {"name": "Unknown", "description": "Unknown boost"}
