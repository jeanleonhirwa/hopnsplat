extends CharacterBody2D

signal platform_landed(platform_y)

@export var move_speed := 100
@export var jump_force := -750
@export var gravity := 500

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var touch_direction := 0
var was_on_floor := false

func _ready() -> void:
	set_process_unhandled_input(true)



func _physics_process(delta):
	# Check if player just landed on a platform
	var current_on_floor = is_on_floor()
	if current_on_floor and not was_on_floor:
		# Player just landed - emit signal with platform Y position
		emit_signal("platform_landed", global_position.y)
	was_on_floor = current_on_floor
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Move player
	move_and_slide()

	if Input.is_action_just_pressed("jump_up") and is_on_floor():
		velocity.y = jump_force  # Jumping up
	
	
	# Animate based on state
	if is_on_floor():
		sprite.play("idle")
	elif velocity.y < 0:
		sprite.play("jump")
	elif velocity.y > 0:
		sprite.play("fly")  # falling or flying up

	# Horizontal movement (air or ground)
	var direction := 0
	if Input.is_action_pressed("ui_left"):
		direction -= 3
	if Input.is_action_pressed("ui_right"):
		direction += 3
	velocity.x = direction * move_speed

	# Get screen width (works on all phones)
	var screen_size = get_viewport_rect().size
	# Clamp X position inside screen
	position.x = clamp(position.x, 0, screen_size.x)
	

	
	var is_touching := false
	if is_touching:
		var touch_position := Vector2.ZERO
		var target_x = touch_position.x
		var current_x = global_position.x
		var distance = target_x - current_x

		# Smooth follow (you can tweak 10.0 to change how fast it follows)
		global_position.x += distance * 10.0 * delta




func _unhandled_input(event):
	var _is_touching := false
	var _touch_position := Vector2.ZERO
	if event is InputEventScreenTouch:
		if event.pressed:
			_is_touching = true
			_touch_position = event.position
		else:
			_is_touching = false
	elif event is InputEventScreenDrag:
		_touch_position = event.position
