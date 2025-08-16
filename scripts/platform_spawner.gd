extends Node2D

@export var platform_scene: PackedScene
@export var vertical_spacing: float = 50
@export var horizontal_range: float = 30
@export var initial_platform_count: int = 10
@export var camera_path: NodePath

var last_platform_y = 0.0
var camera: Node2D
var platforms := []

func _ready():
	if camera_path != null:
		camera = get_node(camera_path)
	else:
		push_error("Camera path not set in PlatformSpawner!")
	for i in range(initial_platform_count):
		spawn_platform(i * vertical_spacing)

func _process(delta):
	if camera == null:
		return
	var upper_limit = last_platform_y
	var spawn_thresh = camera.global_position.y - 480  # about half screen above camera
	# Continuously spawn platforms as camera moves up
	while upper_limit < camera.global_position.y + 960:  # maintain buffer ahead
		upper_limit += vertical_spacing
		spawn_platform(upper_limit)
	last_platform_y = upper_limit

	# Remove platforms way below camera
	var remove_distance = camera.global_position.y - 480  # half screen below
	for platform in platforms:
		if platform.position.y < remove_distance:
			if platform.get_parent():
				platform.queue_free()
	platforms = [p for p in platforms if (p.get_parent() and p.position.y >= remove_distance)]

func spawn_platform(y):
	if platform_scene == null:
		push_error("Platform scene not assigned!")
		return
	var platform = platform_scene.instantiate()
	var screen_width = get_viewport_rect().size.x
	var margin = 50

	var x = randf_range(margin, screen_width - margin)
	platform.position = Vector2(x, y)
	add_child(platform)
	platforms.append(platform)
