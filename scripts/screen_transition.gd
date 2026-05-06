extends Node
## ScreenTransition - Utility script for smooth scene transitions
##
## Provides fade and slide transition effects when changing scenes.
## This singleton manages transition animations to create a polished feel
## when navigating between different screens in the game.
##
## Requirements: 15.2

# Transition overlay
var transition_overlay: ColorRect = null
var is_transitioning: bool = false

func _ready():
	"""Initialize the transition system"""
	# Create a full-screen overlay for transitions
	transition_overlay = ColorRect.new()
	transition_overlay.name = "TransitionOverlay"
	transition_overlay.color = Color.BLACK
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_overlay.z_index = 1000  # Ensure it's on top
	
	# Make it cover the entire viewport
	transition_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	transition_overlay.modulate.a = 0.0  # Start invisible
	
	# Add to the scene tree
	add_child(transition_overlay)


## Fade to a new scene with a smooth fade effect
## @param scene_path: Path to the scene file to load
## @param duration: Duration of the fade effect in seconds (default: 0.3)
func fade_to_scene(scene_path: String, duration: float = 0.3) -> void:
	if is_transitioning:
		push_warning("ScreenTransition: Already transitioning, ignoring request")
		return
	
	is_transitioning = true
	
	# Fade out (darken screen)
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(transition_overlay, "modulate:a", 1.0, duration * 0.5).set_ease(Tween.EASE_IN)
	
	# Wait for fade out to complete
	await fade_out_tween.finished
	
	# Change scene
	get_tree().change_scene_to_file(scene_path)
	
	# Wait one frame for new scene to load
	await get_tree().process_frame
	
	# Fade in (lighten screen)
	var fade_in_tween = create_tween()
	fade_in_tween.tween_property(transition_overlay, "modulate:a", 0.0, duration * 0.5).set_ease(Tween.EASE_OUT)
	
	await fade_in_tween.finished
	is_transitioning = false


## Slide to a new scene with a directional slide effect
## @param scene_path: Path to the scene file to load
## @param direction: Direction to slide (Vector2.LEFT, RIGHT, UP, DOWN)
## @param duration: Duration of the slide effect in seconds (default: 0.4)
func slide_to_scene(scene_path: String, direction: Vector2, duration: float = 0.4) -> void:
	if is_transitioning:
		push_warning("ScreenTransition: Already transitioning, ignoring request")
		return
	
	is_transitioning = true
	
	# Get the current scene root
	var current_scene = get_tree().current_scene
	if not current_scene:
		# Fallback to fade if we can't get current scene
		fade_to_scene(scene_path, duration)
		return
	
	# Calculate slide distance based on viewport size
	var viewport_size = get_viewport().get_visible_rect().size
	var slide_distance = viewport_size.x if abs(direction.x) > abs(direction.y) else viewport_size.y
	
	# Slide out current scene
	var original_position = current_scene.position
	var target_position = original_position + (direction.normalized() * slide_distance)
	
	var slide_out_tween = create_tween()
	slide_out_tween.tween_property(current_scene, "position", target_position, duration * 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	
	# Fade overlay in during slide
	var fade_tween = create_tween()
	fade_tween.tween_property(transition_overlay, "modulate:a", 0.5, duration * 0.5).set_ease(Tween.EASE_IN)
	
	await slide_out_tween.finished
	
	# Change scene
	get_tree().change_scene_to_file(scene_path)
	
	# Wait one frame for new scene to load
	await get_tree().process_frame
	
	# Get new scene and position it off-screen in opposite direction
	var new_scene = get_tree().current_scene
	if new_scene:
		var start_position = Vector2.ZERO - (direction.normalized() * slide_distance)
		new_scene.position = start_position
		
		# Slide in new scene
		var slide_in_tween = create_tween()
		slide_in_tween.tween_property(new_scene, "position", Vector2.ZERO, duration * 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		
		# Fade overlay out during slide
		var fade_out_tween = create_tween()
		fade_out_tween.tween_property(transition_overlay, "modulate:a", 0.0, duration * 0.5).set_ease(Tween.EASE_OUT)
		
		await slide_in_tween.finished
	
	is_transitioning = false


## Quick fade transition (shorter duration for responsive feel)
## @param scene_path: Path to the scene file to load
func quick_fade_to_scene(scene_path: String) -> void:
	fade_to_scene(scene_path, 0.15)


## Check if a transition is currently in progress
## @return: True if transitioning, false otherwise
func is_transition_active() -> bool:
	return is_transitioning
