extends Camera2D

# Camera following system for Hop n' Splat
# Follows player with smooth movement and offset

@export var player_path: NodePath
@export var follow_speed: float = 8.0
@export var vertical_offset: float = -200.0  # Camera offset above player
@export var smoothing_enabled: bool = true
@export var anticipation_distance: float = 100.0  # Look ahead distance
@export var easing_strength: float = 0.15  # Smoother easing

var player: Node2D
var target_y: float
var velocity_y: float = 0.0
var last_player_y: float = 0.0

# Screen shake variables
var shake_intensity: float = 0.0
var shake_duration: float = 0.0
var shake_timer: float = 0.0
var original_position: Vector2

func _ready():
	# Get player reference
	if player_path:
		player = get_node(player_path)
	
	if player:
		target_y = player.global_position.y + vertical_offset
		global_position.y = target_y
		original_position = global_position
		print("Camera initialized - following player")
	else:
		print("ERROR: Player not found for camera following!")

func _process(delta):
	if not player:
		return
	
	# Only follow if player is moving upward (negative Y)
	var player_y = player.global_position.y
	if player_y < target_y - vertical_offset:
		target_y = player_y + vertical_offset
	
	# Calculate player velocity for anticipation
	var current_player_y = player.global_position.y
	velocity_y = (last_player_y - current_player_y) / delta if delta > 0 else 0
	last_player_y = current_player_y
	
	# Add anticipation based on player velocity
	var anticipation_offset = 0.0
	if velocity_y > 50:  # Player moving up fast
		anticipation_offset = -anticipation_distance
	
	# Smooth camera movement with easing
	var base_position_y: float
	if smoothing_enabled:
		# Use exponential easing for smoother movement
		var target_with_anticipation = target_y + anticipation_offset
		base_position_y = lerp(global_position.y, target_with_anticipation, easing_strength)
	else:
		base_position_y = target_y
	
	# Apply screen shake
	var shake_offset = Vector2.ZERO
	if shake_timer > 0:
		shake_timer -= delta
		var shake_amount = shake_intensity * (shake_timer / shake_duration)
		shake_offset.x = randf_range(-shake_amount, shake_amount)
		shake_offset.y = randf_range(-shake_amount, shake_amount)
	
	global_position = Vector2(original_position.x + shake_offset.x, base_position_y + shake_offset.y)

func shake(intensity: float, duration: float):
	"""Trigger screen shake effect"""
	shake_intensity = intensity
	shake_duration = duration
	shake_timer = duration
	print("DEBUG: Screen shake triggered - intensity: ", intensity, " duration: ", duration)
