extends Node2D

# Power-up Visual Effects System
class_name PowerUpEffects

func create_boost_activation_effect(player: Node2D, boost_type: String):
	"""Create visual effect when boost is activated"""
	if not player:
		return
	
	var effect_color = get_boost_color(boost_type)
	
	# Create glow effect around player
	var glow_effect = create_glow_ring(player.global_position, effect_color)
	player.get_parent().add_child(glow_effect)
	
	# Animate the glow
	animate_boost_glow(glow_effect)

func get_boost_color(boost_type: String) -> Color:
	"""Get color for different boost types"""
	match boost_type:
		"jump":
			return Color.CYAN
		"speed":
			return Color.YELLOW
		"shield":
			return Color.BLUE
		"magnet":
			return Color.MAGENTA
		_:
			return Color.WHITE

func create_glow_ring(pos: Vector2, color: Color) -> Node2D:
	"""Create a glowing ring effect"""
	var ring = Node2D.new()
	ring.global_position = pos
	
	# Create multiple circles for layered glow effect
	for i in range(3):
		var circle = create_circle_sprite(20 + i * 10, color, 0.3 - i * 0.1)
		ring.add_child(circle)
	
	return ring

func create_circle_sprite(radius: float, color: Color, alpha: float) -> Node2D:
	"""Create a circular sprite for glow effects"""
	var sprite_node = Node2D.new()
	
	# We'll draw this in _draw() method, but for simplicity, create a ColorRect
	var rect = ColorRect.new()
	rect.size = Vector2(radius * 2, radius * 2)
	rect.position = Vector2(-radius, -radius)
	rect.color = Color(color.r, color.g, color.b, alpha)
	
	sprite_node.add_child(rect)
	return sprite_node

func animate_boost_glow(glow_effect: Node2D):
	"""Animate the boost glow effect"""
	if not glow_effect:
		return
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Pulse animation
	tween.tween_property(glow_effect, "scale", Vector2(1.5, 1.5), 0.3)
	tween.tween_property(glow_effect, "scale", Vector2(1.0, 1.0), 0.3).set_delay(0.3)
	
	# Rotation
	tween.tween_property(glow_effect, "rotation", PI * 2, 1.0)
	
	# Fade out and remove
	tween.tween_property(glow_effect, "modulate:a", 0.0, 0.5).set_delay(0.5)
	tween.tween_callback(glow_effect.queue_free).set_delay(1.0)

func create_shield_effect(player: Node2D):
	"""Create shield visual effect around player"""
	if not player:
		return
	
	var shield = Node2D.new()
	shield.name = "ShieldEffect"
	player.add_child(shield)
	
	# Create shield visual
	var shield_sprite = ColorRect.new()
	shield_sprite.size = Vector2(60, 60)
	shield_sprite.position = Vector2(-30, -30)
	shield_sprite.color = Color(0.0, 0.5, 1.0, 0.3)
	shield.add_child(shield_sprite)
	
	# Animate shield
	animate_shield_effect(shield)
	
	return shield

func animate_shield_effect(shield: Node2D):
	"""Animate the shield effect"""
	if not shield:
		return
	
	var tween = create_tween()
	tween.set_loops()
	
	# Pulsing animation
	tween.tween_property(shield, "scale", Vector2(1.1, 1.1), 0.5)
	tween.tween_property(shield, "scale", Vector2(1.0, 1.0), 0.5)

func create_magnet_effect(player: Node2D):
	"""Create coin magnet visual effect"""
	if not player:
		return
	
	var magnet_effect = Node2D.new()
	magnet_effect.name = "MagnetEffect"
	player.add_child(magnet_effect)
	
	# Create magnetic field visual
	for i in range(3):
		var ring = create_magnet_ring(i * 20 + 40)
		magnet_effect.add_child(ring)
	
	# Animate magnet effect
	animate_magnet_effect(magnet_effect)
	
	return magnet_effect

func create_magnet_ring(radius: float) -> Node2D:
	"""Create a magnetic field ring"""
	var ring = Node2D.new()
	
	var ring_sprite = ColorRect.new()
	ring_sprite.size = Vector2(radius * 2, radius * 2)
	ring_sprite.position = Vector2(-radius, -radius)
	ring_sprite.color = Color(1.0, 0.0, 1.0, 0.2)
	
	ring.add_child(ring_sprite)
	return ring

func animate_magnet_effect(magnet_effect: Node2D):
	"""Animate the magnet effect"""
	if not magnet_effect:
		return
	
	var tween = create_tween()
	tween.set_loops()
	
	# Rotating magnetic field
	tween.tween_property(magnet_effect, "rotation", PI * 2, 2.0)

func create_speed_trail_effect(player: Node2D):
	"""Create speed trail effect behind player"""
	if not player:
		return
	
	var trail = Node2D.new()
	trail.name = "SpeedTrail"
	player.add_child(trail)
	
	# Create trail particles or simple trail effect
	var trail_sprite = ColorRect.new()
	trail_sprite.size = Vector2(40, 60)
	trail_sprite.position = Vector2(-20, -30)
	trail_sprite.color = Color(1.0, 1.0, 0.0, 0.4)
	trail.add_child(trail_sprite)
	
	# Animate trail
	animate_speed_trail(trail)
	
	return trail

func animate_speed_trail(trail: Node2D):
	"""Animate the speed trail effect"""
	if not trail:
		return
	
	var tween = create_tween()
	tween.set_loops()
	
	# Flickering trail effect
	tween.tween_property(trail, "modulate:a", 0.2, 0.1)
	tween.tween_property(trail, "modulate:a", 0.6, 0.1)
