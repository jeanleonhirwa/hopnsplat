extends Camera2D

@export var player_path: NodePath   # drag your Player node here in the Inspector

var player: Node2D
var target_y := 0.0

func _ready() -> void:
	global_position = Vector2(271, 479)

	# Set camera window size as requested
	#zoom = Vector2(540.0/float(get_viewport_rect().size.x), 960.0/float(get_viewport_rect().size.y))

	if player_path != null:
		player = get_node(player_path)
		target_y = player.global_position.y

func _process(delta: float) -> void:
	if player == null:
		return
	# Only move camera up if player rises; don't follow down.
	if player.global_position.y < target_y:
		target_y = player.global_position.y
	# Smoothly interpolate camera position towards target_y
	position.y = lerp(position.y, target_y, 8.0 * delta)
