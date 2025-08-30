extends Control

# Enhanced Game UI Manager with better UX
class_name GameUIManager

# UI References
@onready var score_display: Control
@onready var currency_display: Control
@onready var combo_display: Control
@onready var pause_button: Button
@onready var progress_indicator: ProgressBar

# UI State
var is_ui_hidden: bool = false
var ui_fade_tween: Tween

# HUD Elements
var floating_texts: Array[Control] = []
var max_floating_texts: int = 5

func _ready():
	setup_enhanced_ui()

func setup_enhanced_ui():
	"""Setup enhanced UI with better visual hierarchy"""
	# Create main HUD container
	var hud_container = create_hud_container()
	add_child(hud_container)
	
	# Setup score display with better styling
	setup_score_display()
	
	# Setup currency display with coin animation
	setup_currency_display()
	
	# Setup combo display with visual effects
	setup_combo_display()
	
	# Setup pause button with better positioning
	setup_pause_button()
	
	# Setup progress indicators
	setup_progress_indicators()

func create_hud_container() -> Control:
	"""Create main HUD container with safe area margins"""
	var container = MarginContainer.new()
	container.name = "HUDContainer"
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Apply safe area margins for mobile
	var safe_area = DisplayServer.get_display_safe_area()
	var safe_margins = {
		"top": safe_area.position.y,
		"bottom": safe_area.size.y,
		"left": safe_area.position.x,
		"right": safe_area.size.x
	}
	container.add_theme_constant_override("margin_top", safe_margins.top + 20)
	container.add_theme_constant_override("margin_left", safe_margins.left + 16)
	container.add_theme_constant_override("margin_right", safe_margins.right + 16)
	container.add_theme_constant_override("margin_bottom", safe_margins.bottom + 16)
	
	return container

func setup_score_display():
	"""Create enhanced score display"""
	var score_container = VBoxContainer.new()
	score_container.name = "ScoreContainer"
	
	# Score label with icon
	var score_hbox = HBoxContainer.new()
	
	var score_icon = Label.new()
	score_icon.text = "🏆"
	score_icon.add_theme_font_size_override("font_size", 24)
	
	var score_label = Label.new()
	score_label.name = "ScoreLabel"
	score_label.text = "Score: 0"
	score_label.add_theme_font_size_override("font_size", 20)
	score_label.add_theme_color_override("font_color", Color.WHITE)
	
	score_hbox.add_child(score_icon)
	score_hbox.add_child(score_label)
	score_container.add_child(score_hbox)
	
	# High score display
	var high_score_label = Label.new()
	high_score_label.name = "HighScoreLabel"
	high_score_label.text = "Best: 0"
	high_score_label.add_theme_font_size_override("font_size", 14)
	high_score_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	score_container.add_child(high_score_label)
	
	get_child(0).add_child(score_container)

func setup_currency_display():
	"""Create enhanced currency display with coin animation"""
	var currency_container = HBoxContainer.new()
	currency_container.name = "CurrencyContainer"
	
	# Animated coin icon
	var coin_icon = Label.new()
	coin_icon.name = "CoinIcon"
	coin_icon.text = "💰"
	coin_icon.add_theme_font_size_override("font_size", 18)
	
	# Currency label
	var currency_label = Label.new()
	currency_label.name = "CurrencyLabel"
	currency_label.text = "0"
	currency_label.add_theme_font_size_override("font_size", 18)
	currency_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))
	
	currency_container.add_child(coin_icon)
	currency_container.add_child(currency_label)
	
	# Position in top-right
	currency_container.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	get_child(0).add_child(currency_container)
	
	# Add coin bounce animation
	animate_coin_icon(coin_icon)

func animate_coin_icon(coin_icon: Label):
	"""Add subtle bounce animation to coin icon"""
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(coin_icon, "scale", Vector2(1.1, 1.1), 1.0)
	tween.tween_property(coin_icon, "scale", Vector2(1.0, 1.0), 1.0)

func setup_combo_display():
	"""Create enhanced combo display"""
	var combo_container = Panel.new()
	combo_container.name = "ComboContainer"
	combo_container.custom_minimum_size = Vector2(200, 60)
	combo_container.visible = false
	
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.2, 0.6, 1.0, 0.9)
	style_box.corner_radius_top_left = 12
	style_box.corner_radius_top_right = 12
	style_box.corner_radius_bottom_left = 12
	style_box.corner_radius_bottom_right = 12
	combo_container.add_theme_stylebox_override("panel", style_box)
	
	var combo_label = Label.new()
	combo_label.name = "ComboLabel"
	combo_label.text = "COMBO x1"
	combo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	combo_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	combo_label.add_theme_font_size_override("font_size", 18)
	combo_label.add_theme_color_override("font_color", Color.WHITE)
	
	combo_container.add_child(combo_label)
	combo_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Center horizontally, position in upper middle
	combo_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	combo_container.position.y = 100
	
	get_child(0).add_child(combo_container)

func setup_pause_button():
	"""Create enhanced pause button"""
	var pause_btn = Button.new()
	pause_btn.name = "PauseButton"
	pause_btn.text = "⏸"
	pause_btn.custom_minimum_size = Vector2(50, 50)
	
	var pause_style = StyleBoxFlat.new()
	pause_style.bg_color = Color(0.4, 0.4, 0.4, 0.8)
	pause_style.corner_radius_top_left = 8
	pause_style.corner_radius_top_right = 8
	pause_style.corner_radius_bottom_left = 8
	pause_style.corner_radius_bottom_right = 8
	pause_btn.add_theme_stylebox_override("normal", pause_style)
	
	# Position in top-left
	pause_btn.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	pause_btn.position = Vector2(20, 20)
	
	get_child(0).add_child(pause_btn)
	pause_button = pause_btn

func setup_progress_indicators():
	"""Create progress indicators for achievements and goals"""
	var progress_container = VBoxContainer.new()
	progress_container.name = "ProgressContainer"
	progress_container.custom_minimum_size = Vector2(200, 100)
	
	# Achievement progress
	var achievement_progress = ProgressBar.new()
	achievement_progress.name = "AchievementProgress"
	achievement_progress.max_value = 100
	achievement_progress.value = 0
	var progress_style = StyleBoxFlat.new()
	progress_style.bg_color = Color(1.0, 0.8, 0.2)
	achievement_progress.add_theme_stylebox_override("fill", progress_style)
	
	var progress_label = Label.new()
	progress_label.text = "Next Achievement"
	progress_label.add_theme_font_size_override("font_size", 12)
	progress_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	
	progress_container.add_child(progress_label)
	progress_container.add_child(achievement_progress)
	
	# Position in bottom-left
	progress_container.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	progress_container.position = Vector2(20, -120)
	
	get_child(0).add_child(progress_container)

func update_score_display(score: int, high_score: int = 0):
	"""Update score display with animation"""
	var score_label = get_node_or_null("HUDContainer/ScoreContainer/HBoxContainer/ScoreLabel")
	var high_score_label = get_node_or_null("HUDContainer/ScoreContainer/HighScoreLabel")
	
	if score_label:
		score_label.text = "Score: " + str(score)
		animate_score_update(score_label)
	
	if high_score_label and high_score > 0:
		high_score_label.text = "Best: " + str(high_score)

func animate_score_update(label: Label):
	"""Animate score label update"""
	var tween = create_tween()
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.1)

func update_currency_display(currency: int):
	"""Update currency display with coin animation"""
	var currency_label = get_node_or_null("HUDContainer/CurrencyContainer/CurrencyLabel")
	var coin_icon = get_node_or_null("HUDContainer/CurrencyContainer/CoinIcon")
	
	if currency_label:
		currency_label.text = str(currency)
		animate_currency_gain(currency_label, coin_icon)

func animate_currency_gain(label: Label, icon: Label):
	"""Animate currency gain"""
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Bounce label
	tween.tween_property(label, "scale", Vector2(1.3, 1.3), 0.15)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.15).set_delay(0.15)
	
	# Spin coin icon
	tween.tween_property(icon, "rotation", icon.rotation + PI * 2, 0.3)

func show_combo_display(combo_count: int):
	"""Show combo display with animation"""
	var combo_container = get_node_or_null("HUDContainer/ComboContainer")
	var combo_label = get_node_or_null("HUDContainer/ComboContainer/ComboLabel")
	
	if combo_container and combo_label:
		combo_label.text = "COMBO x" + str(combo_count) + "!"
		combo_container.visible = true
		
		# Animate combo appearance
		var tween = create_tween()
		combo_container.scale = Vector2(0.5, 0.5)
		combo_container.modulate.a = 0.0
		
		tween.set_parallel(true)
		tween.tween_property(combo_container, "scale", Vector2(1.2, 1.2), 0.2)
		tween.tween_property(combo_container, "scale", Vector2(1.0, 1.0), 0.1).set_delay(0.2)
		tween.tween_property(combo_container, "modulate:a", 1.0, 0.2)
		
		# Auto-hide after delay
		await get_tree().create_timer(2.0).timeout
		hide_combo_display()

func hide_combo_display():
	"""Hide combo display with animation"""
	var combo_container = get_node_or_null("HUDContainer/ComboContainer")
	
	if combo_container and combo_container.visible:
		var tween = create_tween()
		tween.tween_property(combo_container, "modulate:a", 0.0, 0.3)
		await tween.finished
		combo_container.visible = false

func create_floating_text(text: String, text_position: Vector2, color: Color = Color.WHITE):
	"""Create floating text effect"""
	if floating_texts.size() >= max_floating_texts:
		# Remove oldest floating text
		var oldest = floating_texts.pop_front()
		if oldest and is_instance_valid(oldest):
			oldest.queue_free()
	
	var floating_label = Label.new()
	floating_label.text = text
	floating_label.global_position = text_position
	floating_label.add_theme_color_override("font_color", color)
	floating_label.add_theme_font_size_override("font_size", 20)
	floating_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	floating_label.add_theme_constant_override("shadow_offset_x", 2)
	floating_label.add_theme_constant_override("shadow_offset_y", 2)
	
	add_child(floating_label)
	floating_texts.append(floating_label)
	
	# Animate floating text
	animate_floating_text(floating_label)

func animate_floating_text(label: Label):
	"""Animate floating text movement"""
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Float upward
	tween.tween_property(label, "global_position:y", label.global_position.y - 80, 1.5)
	
	# Fade out
	tween.tween_property(label, "modulate:a", 0.0, 1.5)
	
	# Scale animation
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.3)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 1.2).set_delay(0.3)
	
	await tween.finished
	
	# Remove from array and free
	floating_texts.erase(label)
	label.queue_free()

func toggle_ui_visibility(ui_visible: bool = !is_ui_hidden):
	"""Toggle UI visibility for clean screenshots or focus"""
	is_ui_hidden = !ui_visible
	
	if ui_fade_tween:
		ui_fade_tween.kill()
	
	ui_fade_tween = create_tween()
	var target_alpha = 1.0 if ui_visible else 0.0
	ui_fade_tween.tween_property(self, "modulate:a", target_alpha, 0.3)

func update_achievement_progress(progress: float, achievement_name: String = ""):
	"""Update achievement progress indicator"""
	var progress_bar = get_node_or_null("HUDContainer/ProgressContainer/AchievementProgress")
	var progress_label = get_node_or_null("HUDContainer/ProgressContainer/Label")
	
	if progress_bar:
		var tween = create_tween()
		tween.tween_property(progress_bar, "value", progress, 0.5)
	
	if progress_label and achievement_name != "":
		progress_label.text = achievement_name
