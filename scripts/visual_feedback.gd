extends Node2D

# Visual Feedback System for Score and UI Elements
class_name VisualFeedback

# Visual feedback components

func create_score_popup(pos: Vector2, score: int, currency: int, parent: Node):
	"""Create floating score popup"""
	var popup = create_score_label()
	popup.global_position = pos
	popup.text = "+" + str(score) + " pts\n+" + str(currency) + " coins"
	parent.add_child(popup)
	
	animate_score_popup(popup)

func create_score_label() -> Label:
	"""Create a styled score label"""
	var label = Label.new()
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color.YELLOW)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label

func animate_score_popup(popup: Label):
	"""Animate score popup with floating motion"""
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Float upward
	tween.tween_property(popup, "global_position:y", popup.global_position.y - 50, 1.0)
	
	# Fade out
	tween.tween_property(popup, "modulate:a", 0.0, 1.0)
	
	# Scale animation
	tween.tween_property(popup, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(popup, "scale", Vector2(1.0, 1.0), 0.8)
	
	# Remove after animation
	tween.tween_callback(popup.queue_free).set_delay(1.0)

func create_coin_collect_effect(pos: Vector2, parent: Node):
	"""Create coin collection visual effect"""
	var coin_label = Label.new()
	coin_label.text = "+1 💰"
	coin_label.global_position = pos
	coin_label.add_theme_font_size_override("font_size", 16)
	coin_label.add_theme_color_override("font_color", Color.GOLD)
	coin_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	coin_label.add_theme_constant_override("shadow_offset_x", 1)
	coin_label.add_theme_constant_override("shadow_offset_y", 1)
	
	parent.add_child(coin_label)
	
	# Animate coin collection
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(coin_label, "global_position:y", pos.y - 30, 0.8)
	tween.tween_property(coin_label, "modulate:a", 0.0, 0.8)
	tween.tween_callback(coin_label.queue_free).set_delay(0.8)

func create_combo_effect(pos: Vector2, combo_count: int, parent: Node):
	"""Create combo visual effect"""
	var combo_label = Label.new()
	combo_label.text = "COMBO x" + str(combo_count) + "!"
	combo_label.global_position = pos
	combo_label.add_theme_font_size_override("font_size", 24)
	combo_label.add_theme_color_override("font_color", Color.ORANGE)
	combo_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	combo_label.add_theme_constant_override("shadow_offset_x", 2)
	combo_label.add_theme_constant_override("shadow_offset_y", 2)
	combo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	parent.add_child(combo_label)
	
	# Animate combo effect
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Bounce scale animation
	tween.tween_property(combo_label, "scale", Vector2(1.5, 1.5), 0.2)
	tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.3)
	
	# Float and fade
	tween.tween_property(combo_label, "global_position:y", pos.y - 40, 1.2)
	tween.tween_property(combo_label, "modulate:a", 0.0, 1.2)
	
	tween.tween_callback(combo_label.queue_free).set_delay(1.2)

func create_achievement_popup(pos: Vector2, achievement_name: String, parent: Node):
	"""Create achievement unlock popup"""
	var achievement_label = Label.new()
	achievement_label.text = "🏆 " + achievement_name + " Unlocked!"
	achievement_label.global_position = pos
	achievement_label.add_theme_font_size_override("font_size", 20)
	achievement_label.add_theme_color_override("font_color", Color.GOLD)
	achievement_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	achievement_label.add_theme_constant_override("shadow_offset_x", 2)
	achievement_label.add_theme_constant_override("shadow_offset_y", 2)
	achievement_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	parent.add_child(achievement_label)
	
	# Animate achievement popup
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Dramatic entrance
	achievement_label.scale = Vector2.ZERO
	tween.tween_property(achievement_label, "scale", Vector2(1.2, 1.2), 0.3)
	tween.tween_property(achievement_label, "scale", Vector2(1.0, 1.0), 0.2).set_delay(0.3)
	
	# Hold and fade
	tween.tween_property(achievement_label, "modulate:a", 0.0, 0.5).set_delay(2.0)
	tween.tween_callback(achievement_label.queue_free).set_delay(2.5)
