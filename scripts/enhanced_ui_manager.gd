extends Control

# Enhanced UI Manager for improved UX
class_name EnhancedUIManager

signal ui_transition_started
signal ui_transition_finished

# UI state management
enum UIState { MENU, GAME, PAUSED, SHOP, ACHIEVEMENTS, GAME_OVER }
var current_state: UIState = UIState.MENU
var previous_state: UIState = UIState.MENU

# Transition system
var transition_overlay: ColorRect
var is_transitioning: bool = false

# Responsive design
var base_resolution: Vector2 = Vector2(540, 960)
var current_scale: float = 1.0

# UI containers
var ui_containers: Dictionary = {}

func _ready():
	setup_responsive_ui()
	setup_transition_overlay()
	connect_to_viewport_changes()

func setup_responsive_ui():
	"""Setup responsive UI scaling"""
	var viewport_size = get_viewport().get_visible_rect().size
	current_scale = min(viewport_size.x / base_resolution.x, viewport_size.y / base_resolution.y)
	
	# Apply scaling to UI elements
	scale = Vector2(current_scale, current_scale)

func setup_transition_overlay():
	"""Create smooth transition overlay"""
	transition_overlay = ColorRect.new()
	transition_overlay.color = Color(0, 0, 0, 0)
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(transition_overlay)
	transition_overlay.z_index = 1000  # Always on top

func connect_to_viewport_changes():
	"""Connect to viewport size changes for responsive design"""
	get_viewport().size_changed.connect(_on_viewport_size_changed)

func _on_viewport_size_changed():
	"""Handle viewport size changes"""
	setup_responsive_ui()

func transition_to_state(new_state: UIState, duration: float = 0.3):
	"""Smooth transition between UI states"""
	if is_transitioning:
		return
	
	is_transitioning = true
	previous_state = current_state
	current_state = new_state
	
	emit_signal("ui_transition_started")
	
	# Fade out
	var tween = create_tween()
	tween.tween_property(transition_overlay, "color:a", 1.0, duration / 2)
	
	# Wait for fade out, then change state
	await tween.finished
	
	# Apply state changes here
	_apply_ui_state_changes()
	
	# Fade in
	tween = create_tween()
	tween.tween_property(transition_overlay, "color:a", 0.0, duration / 2)
	
	await tween.finished
	
	is_transitioning = false
	emit_signal("ui_transition_finished")

func _apply_ui_state_changes():
	"""Apply visual changes for new UI state"""
	match current_state:
		UIState.MENU:
			_setup_menu_state()
		UIState.GAME:
			_setup_game_state()
		UIState.PAUSED:
			_setup_pause_state()
		UIState.SHOP:
			_setup_shop_state()
		UIState.ACHIEVEMENTS:
			_setup_achievements_state()
		UIState.GAME_OVER:
			_setup_game_over_state()

func _setup_menu_state():
	"""Setup UI for main menu"""
	# Hide game UI, show menu UI
	pass

func _setup_game_state():
	"""Setup UI for gameplay"""
	# Show game UI, hide menu UI
	pass

func _setup_pause_state():
	"""Setup UI for pause screen"""
	# Show pause overlay
	pass

func _setup_shop_state():
	"""Setup UI for shop"""
	# Show shop UI
	pass

func _setup_achievements_state():
	"""Setup UI for achievements"""
	# Show achievements UI
	pass

func _setup_game_over_state():
	"""Setup UI for game over"""
	# Show game over UI
	pass

func create_notification(message: String, type: String = "info", duration: float = 3.0) -> Control:
	"""Create animated notification popup"""
	var notification_panel = Panel.new()
	notification_panel.custom_minimum_size = Vector2(300, 60)
	
	# Apply basic styling based on type
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.2, 0.2, 0.2, 0.9)
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	notification_panel.add_theme_stylebox_override("panel", style_box)
	
	# Add text
	var label = Label.new()
	label.text = message
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 16)
	
	notification_panel.add_child(label)
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Position notification
	add_child(notification_panel)
	notification_panel.position = Vector2(
		(get_viewport().get_visible_rect().size.x - notification_panel.size.x) / 2,
		50
	)
	
	# Animate notification
	animate_notification(notification_panel, duration)
	
	return notification_panel

func animate_notification(notification_control: Control, duration: float):
	"""Animate notification appearance and disappearance"""
	# Start above screen
	var final_pos = notification_control.position
	notification_control.position.y = -notification_control.size.y
	notification_control.modulate.a = 0.0
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Slide down and fade in
	tween.tween_property(notification_control, "position:y", final_pos.y, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(notification_control, "modulate:a", 1.0, 0.3)
	
	# Hold for duration
	await get_tree().create_timer(duration).timeout
	
	# Slide up and fade out
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(notification_control, "position:y", -notification_control.size.y, 0.3).set_ease(Tween.EASE_IN)
	tween.tween_property(notification_control, "modulate:a", 0.0, 0.3)
	
	await tween.finished
	notification_control.queue_free()

func create_loading_indicator(parent: Control) -> Control:
	"""Create animated loading indicator"""
	var loading_container = Control.new()
	loading_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Background overlay
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.7)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	loading_container.add_child(overlay)
	
	# Loading spinner
	var spinner = Control.new()
	spinner.custom_minimum_size = Vector2(60, 60)
	loading_container.add_child(spinner)
	
	# Center the spinner
	spinner.position = Vector2(
		(parent.size.x - spinner.size.x) / 2,
		(parent.size.y - spinner.size.y) / 2
	)
	
	# Create spinning animation
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(spinner, "rotation", PI * 2, 1.0)
	
	parent.add_child(loading_container)
	return loading_container

func show_tooltip(text: String, tooltip_position: Vector2, duration: float = 2.0):
	"""Show contextual tooltip"""
	var tooltip = Panel.new()
	# Apply basic styling
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	style_box.corner_radius_top_left = 4
	style_box.corner_radius_top_right = 4
	style_box.corner_radius_bottom_left = 4
	style_box.corner_radius_bottom_right = 4
	tooltip.add_theme_stylebox_override("panel", style_box)
	
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 12)
	
	tooltip.add_child(label)
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Size tooltip to fit text
	tooltip.custom_minimum_size = Vector2(label.get_theme_font("font").get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, label.get_theme_font_size("font_size")).x + 20, 30)
	
	add_child(tooltip)
	tooltip.position = tooltip_position
	
	# Animate tooltip
	tooltip.modulate.a = 0.0
	tooltip.scale = Vector2(0.8, 0.8)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(tooltip, "modulate:a", 1.0, 0.2)
	tween.tween_property(tooltip, "scale", Vector2(1.0, 1.0), 0.2)
	
	# Auto-remove after duration
	await get_tree().create_timer(duration).timeout
	
	tween = create_tween()
	tween.tween_property(tooltip, "modulate:a", 0.0, 0.2)
	await tween.finished
	
	tooltip.queue_free()

func add_button_sound_feedback(button: Button):
	"""Add sound feedback to button interactions"""
	button.pressed.connect(_on_button_pressed)
	button.mouse_entered.connect(_on_button_hover)

func _on_button_pressed():
	"""Handle button press sound"""
	# Play button press sound
	pass

func _on_button_hover():
	"""Handle button hover sound"""
	# Play button hover sound
	pass
