extends StaticBody2D

# Movement configuration
@export var move_speed: float = 50.0
@export var move_range: float = 150.0  # How far to move in each direction
@export var move_direction: Vector2 = Vector2(1, 0)  # Default horizontal movement

# Internal variables
var start_position: Vector2
var target_position: Vector2
var moving_right: bool = true

func _ready():
	# Store the starting position
	start_position = global_position
	
	# Normalize movement direction
	move_direction = move_direction.normalized()
	
	# Set initial target position
	target_position = start_position + (move_direction * move_range)

func _physics_process(delta):
	# Move towards target position
	var direction_to_target = (target_position - global_position).normalized()
	global_position += direction_to_target * move_speed * delta
	
	# Check if we've reached the target (with small tolerance)
	if global_position.distance_to(target_position) < 5.0:
		# Switch direction
		moving_right = !moving_right
		
		if moving_right:
			target_position = start_position + (move_direction * move_range)
		else:
			target_position = start_position - (move_direction * move_range)

func set_movement_pattern(direction: Vector2, range_param: float, speed: float):
	"""Set custom movement pattern for this platform"""
	move_direction = direction.normalized()
	move_range = range_param
	move_speed = speed
	
	# Update positions based on new settings
	start_position = global_position
	target_position = start_position + (move_direction * move_range)
