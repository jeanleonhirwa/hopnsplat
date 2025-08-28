extends Camera2D

# Camera following system for Hop n' Splat
# Follows player with smooth movement and offset

@export var player_path: NodePath
@export var follow_speed: float = 5.0
@export var vertical_offset: float = -200.0  # Camera offset above player
@export var smoothing_enabled: bool = true

var player: Node2D
var target_y: float

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
	
	# Smooth camera movement
	var base_position_y: float
	if smoothing_enabled:
		base_position_y = lerp(global_position.y, target_y, follow_speed * delta)
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
