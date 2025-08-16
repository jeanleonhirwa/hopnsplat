extends CharacterBody2D

@export var move_speed := 100
@export var jump_force := -750
@export var gravity := 500

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var touch_direction := 0

func _ready() -> void:
	set_process_unhandled_input(true)



func _physics_process(delta):
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
	var is_touching := false
	var touch_position := Vector2.ZERO
	if event is InputEventScreenTouch:
		if event.pressed:
			is_touching = true
			touch_position = event.position
		else:
			is_touching = false
	elif event is InputEventScreenDrag:
		touch_position = event.position
