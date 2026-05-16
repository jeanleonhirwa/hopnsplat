class_name AchievementCard
extends KenneyPanel

## AchievementCard Component
## A reusable card component for displaying achievement information with locked/unlocked states,
## progress tracking for progressive achievements, and visual feedback.

# Achievement data properties
@export var achievement_id: String = ""
@export var achievement_title: String = "Achievement Title"
@export var achievement_description: String = "Achievement description goes here"
@export var achievement_icon: Texture2D
@export var is_locked: bool = true
@export var is_progressive: bool = false
@export var current_progress: int = 0
@export var max_progress: int = 100

# Child node references
var icon_container: CenterContainer
var icon_background: TextureRect
var achievement_icon_node: TextureRect
var info_container: VBoxContainer
var title_label: Label
var description_label: Label
var progress_bar: HSlider  # Using HSlider as base for KenneySlider-like behavior
var progress_label: Label
var status_container: CenterContainer
var status_star: TextureRect
var locked_overlay: ColorRect

# Signals
signal achievement_unlocked(achievement_id: String)


func _ready() -> void:
	super._ready()
	
	# Set up the card panel style
	panel_style = PanelStyle.RECTANGLE_DEPTH
	color_pack = ColorPack.YELLOW
	
	# Build the card UI
	_setup_card_ui()
	
	# Update UI based on initial state
	_update_ui_state()


func _setup_card_ui() -> void:
	"""Build the achievement card UI structure."""
	# Create main HBoxContainer
	var main_container = HBoxContainer.new()
	main_container.name = "MainContainer"
	main_container.anchor_left = 0.0
	main_container.anchor_top = 0.0
	main_container.anchor_right = 1.0
	main_container.anchor_bottom = 1.0
	main_container.offset_left = 8
	main_container.offset_top = 6
	main_container.offset_right = -8
	main_container.offset_bottom = -6
	add_child(main_container)
	
	# Icon Container (left side)
	icon_container = CenterContainer.new()
	icon_container.name = "IconContainer"
	icon_container.custom_minimum_size = Vector2(60, 60)
	main_container.add_child(icon_container)
	
	# Icon Background (button_square_depth_gloss.png)
	icon_background = TextureRect.new()
	icon_background.name = "IconBackground"
	icon_background.texture = load("res://assets/ui_packs/Yellow/Default/button_square_depth_gloss.png")
	icon_background.custom_minimum_size = Vector2(48, 48)
	icon_background.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_container.add_child(icon_background)
	
	# Achievement Icon (on top of background)
	achievement_icon_node = TextureRect.new()
	achievement_icon_node.name = "AchievementIcon"
	achievement_icon_node.custom_minimum_size = Vector2(36, 36)
	achievement_icon_node.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	achievement_icon_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if achievement_icon:
		achievement_icon_node.texture = achievement_icon
	else:
		# Use star as default icon
		achievement_icon_node.texture = load("res://assets/ui_packs/Yellow/Default/star.png")
	icon_background.add_child(achievement_icon_node)
	
	# Center the icon on the background
	achievement_icon_node.anchor_left = 0.5
	achievement_icon_node.anchor_top = 0.5
	achievement_icon_node.anchor_right = 0.5
	achievement_icon_node.anchor_bottom = 0.5
	achievement_icon_node.offset_left = -18
	achievement_icon_node.offset_top = -18
	achievement_icon_node.offset_right = 18
	achievement_icon_node.offset_bottom = 18
	
	# Add spacer
	var spacer1 = Control.new()
	spacer1.custom_minimum_size = Vector2(8, 0)
	main_container.add_child(spacer1)
	
	# Info Container (middle section)
	info_container = VBoxContainer.new()
	info_container.name = "InfoContainer"
	info_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_container.add_child(info_container)
	
	# Title Label
	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = achievement_title
	title_label.add_theme_font_size_override("font_size", 15)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	info_container.add_child(title_label)
	
	# Description Label
	description_label = Label.new()
	description_label.name = "DescriptionLabel"
	description_label.text = achievement_description
	description_label.add_theme_font_size_override("font_size", 12)
	description_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_container.add_child(description_label)
	
	# Progress Bar (for progressive achievements, hidden by default)
	var progress_container = HBoxContainer.new()
	progress_container.name = "ProgressContainer"
	progress_container.custom_minimum_size = Vector2(0, 30)
	info_container.add_child(progress_container)
	
	# Progress bar using HSlider styled like KenneySlider
	progress_bar = HSlider.new()
	progress_bar.name = "ProgressBar"
	progress_bar.custom_minimum_size = Vector2(200, 20)
	progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	progress_bar.min_value = 0
	progress_bar.max_value = max_progress
	progress_bar.value = current_progress
	progress_bar.editable = false
	progress_bar.scrollable = false
	progress_container.add_child(progress_bar)
	
	# Progress label (X/Y)
	progress_label = Label.new()
	progress_label.name = "ProgressLabel"
	progress_label.text = "%d/%d" % [current_progress, max_progress]
	progress_label.add_theme_font_size_override("font_size", 12)
	progress_label.add_theme_color_override("font_color", Color.WHITE)
	progress_label.custom_minimum_size = Vector2(60, 0)
	progress_container.add_child(progress_label)
	
	# Hide progress container if not progressive
	progress_container.visible = is_progressive
	
	# Add spacer
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(8, 0)
	main_container.add_child(spacer2)
	
	# Status Container (right side)
	status_container = CenterContainer.new()
	status_container.name = "StatusContainer"
	status_container.custom_minimum_size = Vector2(36, 36)
	main_container.add_child(status_container)
	
	# Status Star (filled or outline based on locked state)
	status_star = TextureRect.new()
	status_star.name = "StatusStar"
	status_star.custom_minimum_size = Vector2(28, 28)
	status_star.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	status_star.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	status_container.add_child(status_star)
	
	# Locked Overlay (semi-transparent grey, shown when locked)
	locked_overlay = ColorRect.new()
	locked_overlay.name = "LockedOverlay"
	locked_overlay.color = Color(0.3, 0.3, 0.3, 0.6)
	locked_overlay.anchor_left = 0.0
	locked_overlay.anchor_top = 0.0
	locked_overlay.anchor_right = 1.0
	locked_overlay.anchor_bottom = 1.0
	locked_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(locked_overlay)


func _update_ui_state() -> void:
	"""Update the UI based on locked/unlocked state."""
	if is_locked:
		# Locked state
		status_star.texture = load("res://assets/ui_packs/Yellow/Default/star_outline.png")
		locked_overlay.visible = true
		
		# Desaturate icon
		achievement_icon_node.modulate = Color(0.5, 0.5, 0.5, 1.0)
	else:
		# Unlocked state
		status_star.texture = load("res://assets/ui_packs/Yellow/Default/star.png")
		locked_overlay.visible = false
		
		# Full color icon
		achievement_icon_node.modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	# Update progress bar visibility
	if info_container:
		var progress_container = info_container.get_node_or_null("ProgressContainer")
		if progress_container:
			progress_container.visible = is_progressive
	
	# Update progress label
	if progress_label:
		progress_label.text = "%d/%d" % [current_progress, max_progress]
	
	# Update progress bar value
	if progress_bar:
		progress_bar.max_value = max_progress
		progress_bar.value = current_progress


# Public API methods

func set_achievement_data(id: String, title: String, description: String, icon: Texture2D, progressive: bool = false, max_prog: int = 100) -> void:
	"""Set the achievement data for this card."""
	achievement_id = id
	achievement_title = title
	achievement_description = description
	achievement_icon = icon
	is_progressive = progressive
	max_progress = max_prog
	
	# Update UI if nodes exist
	if title_label:
		title_label.text = achievement_title
	if description_label:
		description_label.text = achievement_description
	if achievement_icon_node:
		achievement_icon_node.texture = achievement_icon if achievement_icon else load("res://assets/ui_packs/Yellow/Default/star.png")
	
	_update_ui_state()


func set_locked(locked: bool) -> void:
	"""Set the locked state of this achievement."""
	is_locked = locked
	_update_ui_state()


func set_progress(progress: int) -> void:
	"""Set the current progress for progressive achievements."""
	current_progress = clamp(progress, 0, max_progress)
	
	# Update progress bar with animation
	if progress_bar:
		var tween = create_tween()
		tween.tween_property(progress_bar, "value", current_progress, 0.3).set_ease(Tween.EASE_OUT)
	
	# Update progress label
	if progress_label:
		progress_label.text = "%d/%d" % [current_progress, max_progress]
	
	# Check if achievement should be unlocked
	if current_progress >= max_progress and is_locked:
		unlock_achievement()


func unlock_achievement() -> void:
	"""Unlock this achievement and play the unlock animation."""
	if not is_locked:
		return  # Already unlocked
	
	is_locked = false
	play_unlock_animation()
	achievement_unlocked.emit(achievement_id)


func play_unlock_animation() -> void:
	"""Play the achievement unlock animation sequence."""
	# Task 11.5: Unlock animation sequence
	# 1. Card shakes (0.2s)
	# 2. Overlay fades out (0.3s)
	# 3. Icon saturates (0.3s)
	# 4. Star outline morphs to filled with scale pulse (0.4s)
	# 5. Particle burst from card (0.5s)
	# 6. Glow effect fades in and out (1.0s)
	
	# 1. Card shakes (0.2s)
	await _animate_shake()
	
	# 2. Overlay fades out (0.3s)
	var overlay_tween = create_tween()
	overlay_tween.tween_property(locked_overlay, "modulate:a", 0.0, 0.3).set_ease(Tween.EASE_OUT)
	
	# 3. Icon saturates (0.3s) - run in parallel with overlay fade
	var icon_tween = create_tween()
	icon_tween.tween_property(achievement_icon_node, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3).set_ease(Tween.EASE_OUT)
	
	# Wait for overlay and icon animations
	await overlay_tween.finished
	
	# Hide overlay after fade
	locked_overlay.visible = false
	locked_overlay.modulate.a = 0.6  # Reset for next time
	
	# 4. Star outline morphs to filled with scale pulse (0.4s)
	status_star.texture = load("res://assets/ui_packs/Yellow/Default/star.png")
	var star_tween = create_tween()
	star_tween.tween_property(status_star, "scale", Vector2(1.3, 1.3), 0.2).set_ease(Tween.EASE_OUT)
	star_tween.tween_property(status_star, "scale", Vector2(1.0, 1.0), 0.2).set_ease(Tween.EASE_IN)
	
	# 5. Particle burst from card (0.5s)
	_spawn_unlock_particles()
	
	# 6. Glow effect fades in and out (1.0s)
	_animate_glow_effect()
	
	# Play unlock sound
	AudioManager.play_ui_click()


func _animate_shake() -> void:
	"""Animate a shake effect on the card."""
	var original_position = position
	var shake_amount = 5.0
	var shake_duration = 0.05
	
	for i in range(4):  # 4 shakes in 0.2s
		var tween = create_tween()
		var offset = Vector2(randf_range(-shake_amount, shake_amount), randf_range(-shake_amount, shake_amount))
		tween.tween_property(self, "position", original_position + offset, shake_duration)
		await tween.finished
	
	# Return to original position
	var final_tween = create_tween()
	final_tween.tween_property(self, "position", original_position, shake_duration)
	await final_tween.finished


func _spawn_unlock_particles() -> void:
	"""Spawn a particle burst at the card location using star textures."""
	# Create particle system
	var particles = CPUParticles2D.new()
	
	# Add to the card
	add_child(particles)
	
	# Position at center of card
	particles.position = size / 2
	
	# Configure particle properties
	particles.emitting = false
	particles.amount = 30
	particles.lifetime = 0.8
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.randomness = 0.5
	
	# Set texture
	particles.texture = load("res://assets/ui_packs/Yellow/Default/star.png")
	
	# Emission shape (circle)
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 30.0
	
	# Direction and spread
	particles.direction = Vector2(0, -1)
	particles.spread = 180.0
	
	# Velocity
	particles.initial_velocity_min = 150.0
	particles.initial_velocity_max = 250.0
	
	# Gravity
	particles.gravity = Vector2(0, 400)
	
	# Scale
	particles.scale_amount_min = 0.4
	particles.scale_amount_max = 0.8
	
	# Color (yellow/gold tint)
	particles.color = Color(1.0, 0.9, 0.3, 1.0)
	
	# Fade out over lifetime
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 1, 1, 1))
	gradient.add_point(1.0, Color(1, 1, 1, 0))
	particles.color_ramp = gradient
	
	# Start emitting
	particles.emitting = true
	
	# Auto-cleanup after lifetime
	await get_tree().create_timer(particles.lifetime + 0.1).timeout
	particles.queue_free()


func _animate_glow_effect() -> void:
	"""Animate a glow effect that fades in and out."""
	# Create a glow overlay using a ColorRect with a shader or simple modulate
	var glow = ColorRect.new()
	glow.name = "GlowEffect"
	glow.color = Color(1.0, 0.9, 0.3, 0.0)  # Yellow glow, initially transparent
	glow.anchor_left = 0.0
	glow.anchor_top = 0.0
	glow.anchor_right = 1.0
	glow.anchor_bottom = 1.0
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(glow)
	
	# Fade in (0.3s)
	var fade_in_tween = create_tween()
	fade_in_tween.tween_property(glow, "color:a", 0.3, 0.3).set_ease(Tween.EASE_OUT)
	await fade_in_tween.finished
	
	# Hold (0.2s)
	await get_tree().create_timer(0.2).timeout
	
	# Fade out (0.5s)
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(glow, "color:a", 0.0, 0.5).set_ease(Tween.EASE_IN)
	await fade_out_tween.finished
	
	# Cleanup
	glow.queue_free()
