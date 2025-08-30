extends Control

# Power-Up UI System
class_name PowerUpUI

# UI Elements
var active_power_ups_container: VBoxContainer
var power_up_notification_scene: PackedScene
var power_up_icons: Dictionary = {}

# Animation
var notification_tween: Tween
var icon_animations: Dictionary = {}

func _ready():
	setup_power_up_ui()

func setup_power_up_ui():
	"""Setup power-up UI elements"""
	# Create container for active power-ups
	active_power_ups_container = VBoxContainer.new()
	active_power_ups_container.name = "ActivePowerUps"
	active_power_ups_container.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	active_power_ups_container.position = Vector2(-220, 80)
	add_child(active_power_ups_container)

func show_power_up_notification(power_up_name: String, icon: String, color: Color):
	"""Show power-up activation notification"""
	# Create notification panel
	var notification = Panel.new()
	notification.custom_minimum_size = Vector2(250, 60)
	
	# Style notification
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = color
	style_box.bg_color.a = 0.9
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	notification.add_theme_stylebox_override("panel", style_box)
	
	# Create content container
	var hbox = HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 10)
	notification.add_child(hbox)
	
	# Add margin
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 5)
	margin.add_theme_constant_override("margin_bottom", 5)
	hbox.add_child(margin)
	
	var content_hbox = HBoxContainer.new()
	content_hbox.add_theme_constant_override("separation", 10)
	margin.add_child(content_hbox)
	
	# Add icon
	var icon_label = Label.new()
	icon_label.text = icon
	icon_label.add_theme_font_size_override("font_size", 24)
	content_hbox.add_child(icon_label)
	
	# Add text
	var text_label = Label.new()
	text_label.text = power_up_name + " Activated!"
	text_label.add_theme_font_size_override("font_size", 14)
	text_label.add_theme_color_override("font_color", Color.WHITE)
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	content_hbox.add_child(text_label)
	
	# Position notification
	add_child(notification)
	notification.position = Vector2(
		(get_viewport().get_visible_rect().size.x - notification.size.x) / 2,
		100
	)
	
	# Animate notification
	animate_power_up_notification(notification)

func animate_power_up_notification(notification: Panel):
	"""Animate power-up notification"""
	# Start off-screen
	notification.position.y = -notification.size.y
	notification.modulate.a = 0.0
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Slide down and fade in
	tween.tween_property(notification, "position:y", 100, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(notification, "modulate:a", 1.0, 0.3)
	
	# Hold for 2 seconds
	await get_tree().create_timer(2.0).timeout
	
	# Slide up and fade out
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(notification, "position:y", -notification.size.y, 0.3).set_ease(Tween.EASE_IN)
	tween.tween_property(notification, "modulate:a", 0.0, 0.3)
	
	await tween.finished
	notification.queue_free()

func add_active_power_up_icon(power_up_name: String, icon: String, color: Color, duration: float):
	"""Add icon for active power-up"""
	# Create power-up icon container
	var power_up_panel = Panel.new()
	power_up_panel.custom_minimum_size = Vector2(180, 40)
	power_up_panel.name = power_up_name
	
	# Style panel
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = color
	style_box.bg_color.a = 0.8
	style_box.corner_radius_top_left = 6
	style_box.corner_radius_top_right = 6
	style_box.corner_radius_bottom_left = 6
	style_box.corner_radius_bottom_right = 6
	power_up_panel.add_theme_stylebox_override("panel", style_box)
	
	# Create content
	var hbox = HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 8)
	power_up_panel.add_child(hbox)
	
	# Add margin
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	hbox.add_child(margin)
	
	var content_hbox = HBoxContainer.new()
	content_hbox.add_theme_constant_override("separation", 8)
	margin.add_child(content_hbox)
	
	# Add icon
	var icon_label = Label.new()
	icon_label.text = icon
	icon_label.add_theme_font_size_override("font_size", 18)
	content_hbox.add_child(icon_label)
	
	# Add name and timer
	var vbox = VBoxContainer.new()
	content_hbox.add_child(vbox)
	
	var name_label = Label.new()
	name_label.text = power_up_name
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(name_label)
	
	# Add timer if duration-based
	if duration > 0:
		var timer_label = Label.new()
		timer_label.name = "Timer"
		timer_label.text = str(int(duration)) + "s"
		timer_label.add_theme_font_size_override("font_size", 10)
		timer_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
		vbox.add_child(timer_label)
		
		# Start timer countdown
		start_power_up_timer(power_up_panel, duration)
	
	# Add to container
	active_power_ups_container.add_child(power_up_panel)
	power_up_icons[power_up_name] = power_up_panel
	
	# Animate appearance
	animate_power_up_icon_appear(power_up_panel)

func start_power_up_timer(power_up_panel: Panel, duration: float):
	"""Start countdown timer for power-up"""
	var timer_label = power_up_panel.get_node("HBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/Timer")
	if not timer_label:
		return
	
	var remaining_time = duration
	var timer = Timer.new()
	timer.wait_time = 0.1  # Update every 0.1 seconds
	timer.timeout.connect(func():
		remaining_time -= 0.1
		if remaining_time <= 0:
			timer.queue_free()
			remove_active_power_up_icon(power_up_panel.name)
		else:
			timer_label.text = str(int(remaining_time + 0.9)) + "s"
			
			# Change color as time runs out
			if remaining_time < 3.0:
				timer_label.add_theme_color_override("font_color", Color.RED)
			elif remaining_time < 5.0:
				timer_label.add_theme_color_override("font_color", Color.YELLOW)
	)
	
	add_child(timer)
	timer.start()

func remove_active_power_up_icon(power_up_name: String):
	"""Remove active power-up icon"""
	if power_up_icons.has(power_up_name):
		var icon = power_up_icons[power_up_name]
		animate_power_up_icon_disappear(icon)
		power_up_icons.erase(power_up_name)

func animate_power_up_icon_appear(icon: Panel):
	"""Animate power-up icon appearance"""
	icon.scale = Vector2(0.5, 0.5)
	icon.modulate.a = 0.0
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(icon, "scale", Vector2(1.0, 1.0), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(icon, "modulate:a", 1.0, 0.2)

func animate_power_up_icon_disappear(icon: Panel):
	"""Animate power-up icon disappearance"""
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(icon, "scale", Vector2(0.5, 0.5), 0.2).set_ease(Tween.EASE_IN)
	tween.tween_property(icon, "modulate:a", 0.0, 0.2)
	
	await tween.finished
	icon.queue_free()

func show_power_up_combo_notification(combo_count: int):
	"""Show notification for power-up combo"""
	var notification = Panel.new()
	notification.custom_minimum_size = Vector2(300, 80)
	
	# Rainbow gradient for combo
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color.PURPLE
	style_box.bg_color.a = 0.9
	style_box.corner_radius_top_left = 12
	style_box.corner_radius_top_right = 12
	style_box.corner_radius_bottom_left = 12
	style_box.corner_radius_bottom_right = 12
	notification.add_theme_stylebox_override("panel", style_box)
	
	# Add text
	var label = Label.new()
	label.text = "POWER COMBO x" + str(combo_count) + "!"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color.WHITE)
	
	notification.add_child(label)
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Position and animate
	add_child(notification)
	notification.position = Vector2(
		(get_viewport().get_visible_rect().size.x - notification.size.x) / 2,
		150
	)
	
	animate_combo_notification(notification)

func animate_combo_notification(notification: Panel):
	"""Animate combo notification with special effects"""
	notification.scale = Vector2(0.3, 0.3)
	notification.modulate.a = 0.0
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Explosive appearance
	tween.tween_property(notification, "scale", Vector2(1.3, 1.3), 0.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(notification, "scale", Vector2(1.0, 1.0), 0.1).set_delay(0.2)
	tween.tween_property(notification, "modulate:a", 1.0, 0.2)
	
	# Pulsing effect
	for i in range(3):
		tween.tween_property(notification, "scale", Vector2(1.1, 1.1), 0.2).set_delay(0.5 + i * 0.4)
		tween.tween_property(notification, "scale", Vector2(1.0, 1.0), 0.2).set_delay(0.7 + i * 0.4)
	
	# Hold and fade out
	await get_tree().create_timer(3.0).timeout
	
	tween = create_tween()
	tween.tween_property(notification, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	notification.queue_free()

func clear_all_power_up_icons():
	"""Clear all active power-up icons"""
	for icon_name in power_up_icons.keys():
		var icon = power_up_icons[icon_name]
		if is_instance_valid(icon):
			icon.queue_free()
	
	power_up_icons.clear()

func update_power_up_icon_timer(power_up_name: String, remaining_time: float):
	"""Update timer for specific power-up icon"""
	if power_up_icons.has(power_up_name):
		var icon = power_up_icons[power_up_name]
		var timer_label = icon.get_node_or_null("HBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/Timer")
		if timer_label:
			timer_label.text = str(int(remaining_time + 0.9)) + "s"
