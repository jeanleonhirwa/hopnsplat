extends Area2D

# Splat obstacle types
enum SplatType { SPIKE, BOUNCER, ROTATOR, FALLING }

# Configuration
@export var splat_type: SplatType = SplatType.SPIKE
@export var movement_speed: float = 100.0
@export var movement_range: float = 80.0
@export var rotation_speed: float = 180.0  # degrees per second

# Internal variables
var start_position: Vector2
var movement_direction: Vector2 = Vector2(1, 0)
var moving_right: bool = true

# Node references
@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D
@onready var animation_player = $AnimationPlayer

func _ready():
	# Connect collision signal
	body_entered.connect(_on_body_entered)
	
	# Store starting position
	start_position = global_position
	
	# Configure based on splat type
	setup_splat_type()

func setup_splat_type():
	"""Configure obstacle based on its type"""
	match splat_type:
		SplatType.SPIKE:
			# Static red spikes
			sprite.modulate = Color(1, 0.2, 0.2, 1)
			sprite.rotation_degrees = 45  # Diamond shape for spikes
			
		SplatType.BOUNCER:
			# Orange bouncing obstacle
			sprite.modulate = Color(1, 0.6, 0.2, 1)
			movement_direction = Vector2(0, 1)  # Vertical movement
			
		SplatType.ROTATOR:
			# Purple rotating obstacle
			sprite.modulate = Color(0.8, 0.2, 1, 1)
			
		SplatType.FALLING:
			# Yellow falling obstacle
			sprite.modulate = Color(1, 1, 0.2, 1)
			movement_direction = Vector2(0, 1)  # Falls downward

func _physics_process(delta):
	match splat_type:
		SplatType.SPIKE:
			# Static - no movement
			pass
			
		SplatType.BOUNCER:
			# Bounce up and down
			bounce_movement(delta)
			
		SplatType.ROTATOR:
			# Rotate continuously
			sprite.rotation_degrees += rotation_speed * delta
			
		SplatType.FALLING:
			# Fall downward continuously
			global_position.y += movement_speed * delta
			# Remove if fallen too far below screen
			if global_position.y > get_viewport_rect().size.y + 200:
				queue_free()

func bounce_movement(delta):
	"""Handle bouncing movement for BOUNCER type"""
	var target_position: Vector2
	
	if moving_right:
		target_position = start_position + (movement_direction * movement_range)
	else:
		target_position = start_position - (movement_direction * movement_range)
	
	# Move towards target
	var direction_to_target = (target_position - global_position).normalized()
	global_position += direction_to_target * movement_speed * delta
	
	# Check if reached target
	if global_position.distance_to(target_position) < 5.0:
		moving_right = !moving_right

func _on_body_entered(body):
	"""Handle collision with player"""
	if body.name == "Player":
		# Trigger splat effect
		trigger_splat(body)

func trigger_splat(player):
	"""Trigger the splat effect and game over"""
	print("SPLAT! Player hit obstacle of type: ", SplatType.keys()[splat_type])
	
	# Play danger sound through player
	if player.has_method("_on_splat_obstacle_hit"):
		player._on_splat_obstacle_hit(self)
	
	# Optional: Add splat visual effect here
	create_splat_effect()

func create_splat_effect():
	"""Create visual splat effect"""
	# Simple scale animation for splat effect
	var tween = create_tween()
	tween.parallel().tween_property(sprite, "scale", Vector2(1.5, 1.5), 0.2)
	tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)

func set_splat_type(type: SplatType):
	"""Set the splat obstacle type"""
	splat_type = type
	if is_inside_tree():
		setup_splat_type()
