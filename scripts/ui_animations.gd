extends Node2D

# UI Animation System for Enhanced Game Feel
class_name UIAnimations

func animate_score_update(label: Label, new_value: int):
	"""Animate score label when value changes"""
	if not label:
		return
	
	var tween = create_tween()
	
	# Pulse animation
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.1)
	
	# Color flash
	var original_color = label.get_theme_color("font_color", "Label")
	label.add_theme_color_override("font_color", Color.YELLOW)
	tween.tween_callback(func(): label.add_theme_color_override("font_color", original_color)).set_delay(0.2)

func animate_currency_update(label: Label, new_value: int):
	"""Animate currency label when coins are earned"""
	if not label:
		return
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Bounce animation
	tween.tween_property(label, "scale", Vector2(1.3, 1.3), 0.15)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.15).set_delay(0.15)
	
	# Gold color flash
	var original_color = label.get_theme_color("font_color", "Label")
	label.add_theme_color_override("font_color", Color.GOLD)
	tween.tween_callback(func(): label.add_theme_color_override("font_color", original_color)).set_delay(0.3)

func animate_button_press(button: Button):
	"""Animate button press with satisfying feedback"""
	if not button:
		return
	
	var tween = create_tween()
	
	# Press down animation
	tween.tween_property(button, "scale", Vector2(0.95, 0.95), 0.05)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)

func animate_panel_slide_in(panel: Control, from_direction: Vector2 = Vector2(0, -100)):
	"""Animate panel sliding in from specified direction"""
	if not panel:
		return
	
	var original_pos = panel.position
	panel.position = original_pos + from_direction
	panel.modulate.a = 0.0
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Slide in
	tween.tween_property(panel, "position", original_pos, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Fade in
	tween.tween_property(panel, "modulate:a", 1.0, 0.3)

func animate_panel_slide_out(panel: Control, to_direction: Vector2 = Vector2(0, -100)):
	"""Animate panel sliding out to specified direction"""
	if not panel:
		return
	
	var target_pos = panel.position + to_direction
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Slide out
	tween.tween_property(panel, "position", target_pos, 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	
	# Fade out
	tween.tween_property(panel, "modulate:a", 0.0, 0.3)

func animate_achievement_notification(notification: Control):
	"""Animate achievement notification popup"""
	if not notification:
		return
	
	# Start from top of screen
	var original_pos = notification.position
	notification.position.y = -100
	notification.scale = Vector2(0.8, 0.8)
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Slide down with bounce
	tween.tween_property(notification, "position:y", original_pos.y, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	
	# Scale up
	tween.tween_property(notification, "scale", Vector2(1.0, 1.0), 0.3)
	
	# Hold for 3 seconds then slide up
	tween.tween_property(notification, "position:y", -100, 0.3).set_delay(3.0)
	tween.tween_property(notification, "modulate:a", 0.0, 0.3).set_delay(3.0)

func animate_health_bar_damage(health_bar: ProgressBar):
	"""Animate health bar taking damage"""
	if not health_bar:
		return
	
	var tween = create_tween()
	
	# Shake animation
	var original_pos = health_bar.position
	for i in range(3):
		tween.tween_property(health_bar, "position:x", original_pos.x + 5, 0.05)
		tween.tween_property(health_bar, "position:x", original_pos.x - 5, 0.05)
	tween.tween_property(health_bar, "position", original_pos, 0.05)
	
	# Red flash
	var original_color = health_bar.get_theme_color("fill_color", "ProgressBar")
	health_bar.add_theme_color_override("fill_color", Color.RED)
	tween.tween_callback(func(): health_bar.add_theme_color_override("fill_color", original_color)).set_delay(0.3)
