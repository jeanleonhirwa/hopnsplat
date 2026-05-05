extends Node
## UIAnimationManager - Global singleton for coordinating UI animations
##
## This autoload singleton manages all UI animations and prevents performance issues
## by limiting concurrent tweens. It provides juice effect presets (bounce, squash,
## wobble, etc.) for creating smooth, playful UI animations.
##
## Requirements: 3.5, 13.1

# Animation tracking
var active_tweens: Array[Tween] = []
const MAX_CONCURRENT_TWEENS: int = 10


## Register a tween for tracking and automatic cleanup
## Ensures we don't exceed MAX_CONCURRENT_TWEENS to maintain performance
func register_tween(tween: Tween) -> void:
	cleanup_finished_tweens()
	
	if active_tweens.size() >= MAX_CONCURRENT_TWEENS:
		# Kill oldest tween to make room
		var oldest = active_tweens[0]
		oldest.kill()
		active_tweens.remove_at(0)
		push_warning("UIAnimationManager: Tween limit reached (%d), killing oldest animation" % MAX_CONCURRENT_TWEENS)
	
	active_tweens.append(tween)
	tween.finished.connect(func(): _on_tween_finished(tween))


## Remove finished tweens from tracking array
func cleanup_finished_tweens() -> void:
	var i = active_tweens.size() - 1
	while i >= 0:
		if not active_tweens[i].is_running():
			active_tweens.remove_at(i)
		i -= 1


## Stop and clear all active tweens
## Useful for scene transitions or cleanup
func stop_all_tweens() -> void:
	for tween in active_tweens:
		if tween.is_running():
			tween.kill()
	active_tweens.clear()


## Internal callback when a tween finishes
func _on_tween_finished(tween: Tween) -> void:
	active_tweens.erase(tween)


## Bounce-in animation - scales node to create a bouncy entrance effect
## @param node: The node to animate
## @param duration: Animation duration in seconds (default: 0.15)
## @param target_scale: Target scale multiplier (default: 1.1 for 110%)
## @return: The created Tween for further customization
func bounce_in(node: Node, duration: float = 0.15, target_scale: float = 1.1) -> Tween:
	var tween = create_tween()
	register_tween(tween)
	
	var original_scale = node.scale
	tween.tween_property(node, "scale", original_scale * target_scale, duration).set_ease(Tween.EASE_OUT)
	
	return tween


## Squash animation - compresses node for press feedback
## @param node: The node to animate
## @param duration: Animation duration in seconds (default: 0.1)
## @param target_scale: Target scale multiplier (default: 0.95 for 95%)
## @return: The created Tween for further customization
func squash(node: Node, duration: float = 0.1, target_scale: float = 0.95) -> Tween:
	var tween = create_tween()
	register_tween(tween)
	
	var original_scale = node.scale
	tween.tween_property(node, "scale", original_scale * target_scale, duration).set_ease(Tween.EASE_IN)
	
	return tween


## Pop-out animation - elastic bounce effect for satisfying feedback
## @param node: The node to animate
## @param duration: Animation duration in seconds (default: 0.2)
## @return: The created Tween for further customization
func pop_out(node: Node, duration: float = 0.2) -> Tween:
	var tween = create_tween()
	register_tween(tween)
	
	var original_scale = node.scale
	# Scale down first, then pop out with elastic easing
	tween.tween_property(node, "scale", original_scale * 0.8, duration * 0.3).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "scale", original_scale, duration * 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	return tween


## Wobble animation - subtle rotation for idle state emphasis
## @param node: The node to animate
## @param loop: Whether to loop the animation (default: true)
## @param angle: Maximum rotation angle in degrees (default: 5)
## @param duration: Full cycle duration in seconds (default: 2.0)
## @return: The created Tween for further customization
func wobble(node: Node, loop: bool = true, angle: float = 5.0, duration: float = 2.0) -> Tween:
	var tween = create_tween()
	register_tween(tween)
	
	if loop:
		tween.set_loops()
	
	var original_rotation = node.rotation_degrees
	# Wobble left, then right, then back to center
	tween.tween_property(node, "rotation_degrees", original_rotation + angle, duration * 0.25).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "rotation_degrees", original_rotation - angle, duration * 0.5).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "rotation_degrees", original_rotation, duration * 0.25).set_ease(Tween.EASE_IN_OUT)
	
	return tween


## Slide-in animation - moves node from a direction
## @param node: The node to animate
## @param direction: Direction vector (e.g., Vector2.RIGHT, Vector2.DOWN)
## @param duration: Animation duration in seconds (default: 0.3)
## @param distance: Distance to slide in pixels (default: 100)
## @return: The created Tween for further customization
func slide_in(node: Node, direction: Vector2, duration: float = 0.3, distance: float = 100.0) -> Tween:
	var tween = create_tween()
	register_tween(tween)
	
	var original_position = node.position
	var start_position = original_position + (direction.normalized() * distance)
	
	node.position = start_position
	tween.tween_property(node, "position", original_position, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	return tween


## Fade-in animation - gradually increases opacity
## @param node: The node to animate (must have modulate property)
## @param duration: Animation duration in seconds (default: 0.2)
## @return: The created Tween for further customization
func fade_in(node: Node, duration: float = 0.2) -> Tween:
	var tween = create_tween()
	register_tween(tween)
	
	node.modulate.a = 0.0
	tween.tween_property(node, "modulate:a", 1.0, duration).set_ease(Tween.EASE_OUT)
	
	return tween


## Count-up animation - animates a label's text from one number to another
## @param label: The Label node to animate
## @param from: Starting number
## @param to: Ending number
## @param duration: Animation duration in seconds (default: 0.5)
## @return: The created Tween for further customization
func count_up(label: Label, from: int, to: int, duration: float = 0.5) -> Tween:
	var tween = create_tween()
	register_tween(tween)
	
	var counter = {"value": from}
	tween.tween_property(counter, "value", to, duration).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func(): label.text = str(int(counter.value))).set_delay(0.0)
	
	# Update label text during animation
	var update_interval = 0.05  # Update every 50ms
	var steps = int(duration / update_interval)
	for i in range(steps):
		tween.tween_callback(func(): 
			var progress = float(i) / float(steps)
			var current_value = lerp(float(from), float(to), progress)
			label.text = str(int(current_value))
		).set_delay(update_interval * i)
	
	# Ensure final value is exact
	tween.tween_callback(func(): label.text = str(to))
	
	return tween


## Get the current number of active tweens
## Useful for debugging and performance monitoring
func get_active_tween_count() -> int:
	cleanup_finished_tweens()
	return active_tweens.size()


## Debug function to print active tween count
func print_debug_info() -> void:
	print("UIAnimationManager: %d/%d active tweens" % [get_active_tween_count(), MAX_CONCURRENT_TWEENS])
