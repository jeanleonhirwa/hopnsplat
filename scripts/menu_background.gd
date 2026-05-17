extends Control

@onready var sky_layer = $ParallaxBackground/SkyLayer
@onready var player = $ParallaxBackground/ActionLayer/Player

var cloud_speed = 20.0
var player_state = "idle" # idle, running, jumping
var player_velocity = Vector2.ZERO
var gravity = 1500.0
var floor_y = 750.0

func _ready():
	# Modulate player so it looks like it's in the background (silhouette or tinted)
	player.modulate = Color(0.8, 0.8, 1.0, 0.8)
	
	# Initial random positions for clouds
	for child in sky_layer.get_children():
		child.modulate.a = randf_range(0.4, 0.7)
		child.position.x = randf_range(0, 540)
	
	# Start the sequence
	var t = get_tree().create_timer(1.0)
	t.timeout.connect(_start_player_sequence)

func _process(delta):
	# Scroll clouds infinitely (ParallaxLayer mirroring handles the wrap)
	if sky_layer:
		sky_layer.motion_offset.x -= cloud_speed * delta
	
	# Handle player running/jumping logic
	if player_state != "idle":
		player_velocity.y += gravity * delta
		player.position += player_velocity * delta
		
		# Floor collision
		if player.position.y >= floor_y:
			player.position.y = floor_y
			if player_state == "jumping":
				player_state = "running"
				player.play("run")
				
				# Small bounce
				player_velocity.y = -200
				
				# Jump again later
				var t = get_tree().create_timer(randf_range(0.5, 1.2))
				t.timeout.connect(_jump)

		# Screen wrap/reset when running far off screen
		if player.position.x > 700:
			player_state = "idle"
			player.position.x = -100
			
			# Schedule next run in a few seconds
			var t = get_tree().create_timer(randf_range(3.0, 7.0))
			t.timeout.connect(_start_player_sequence)

func _start_player_sequence():
	# Don't start if already running or jumping
	if player_state != "idle": return
	
	player_state = "running"
	player.position = Vector2(-100, floor_y)
	player_velocity = Vector2(randf_range(200, 350), 0)
	player.play("run")
	
	# Jump randomly after a short time
	var t = get_tree().create_timer(randf_range(0.5, 1.5))
	t.timeout.connect(_jump)

func _jump():
	# Only jump if running on floor
	if player_state != "running": return
	player_state = "jumping"
	player_velocity.y = randf_range(-500, -700)
	player.play("jump")
