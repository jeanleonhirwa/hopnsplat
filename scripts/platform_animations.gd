extends Node2D

# Platform Animation System for Enhanced Game Feel
class_name PlatformAnimations

func animate_platform_bounce(platform: Node2D):
	"""Animate platform bounce when player lands on it"""
	if not platform:
		return
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Bounce scale animation
	var original_scale = platform.scale
	tween.tween_property(platform, "scale", original_scale * 1.1, 0.1)
	tween.tween_property(platform, "scale", original_scale * 0.95, 0.1).set_delay(0.1)
	tween.tween_property(platform, "scale", original_scale, 0.1).set_delay(0.2)
	
	# Slight position bounce
	var original_y = platform.global_position.y
	tween.tween_property(platform, "global_position:y", original_y + 3, 0.1)
	tween.tween_property(platform, "global_position:y", original_y, 0.2).set_delay(0.1)

func animate_platform_spawn(platform: Node2D):
	"""Animate platform appearing"""
	if not platform:
		return
	
	# Start invisible and small
	platform.modulate.a = 0.0
	platform.scale = Vector2(0.5, 0.5)
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade in and scale up
	tween.tween_property(platform, "modulate:a", 1.0, 0.3)
	tween.tween_property(platform, "scale", Vector2(1.0, 1.0), 0.3)

func animate_platform_destruction(platform: Node2D):
	"""Animate platform being destroyed"""
	if not platform:
		return
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade out and shrink
	tween.tween_property(platform, "modulate:a", 0.0, 0.5)
	tween.tween_property(platform, "scale", Vector2(0.0, 0.0), 0.5)
	
	# Remove after animation
	tween.tween_callback(platform.queue_free).set_delay(0.5)
