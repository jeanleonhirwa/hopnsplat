extends Node

# UI Theme Manager for consistent styling across the game
class_name UIThemeManager

# Color palette
const COLORS = {
	"primary": Color(0.2, 0.6, 1.0),      # Blue
	"secondary": Color(0.8, 0.4, 1.0),    # Purple
	"accent": Color(1.0, 0.8, 0.2),       # Gold
	"success": Color(0.2, 0.8, 0.4),      # Green
	"warning": Color(1.0, 0.6, 0.2),      # Orange
	"danger": Color(1.0, 0.3, 0.3),       # Red
	"background": Color(0.1, 0.1, 0.15),  # Dark blue
	"surface": Color(0.15, 0.15, 0.2),    # Lighter dark
	"text_primary": Color(1.0, 1.0, 1.0), # White
	"text_secondary": Color(0.8, 0.8, 0.9) # Light gray
}

# Font sizes
const FONT_SIZES = {
	"title": 48,
	"heading": 32,
	"subheading": 24,
	"body": 18,
	"caption": 14,
	"small": 12
}

# Spacing
const SPACING = {
	"xs": 4,
	"sm": 8,
	"md": 16,
	"lg": 24,
	"xl": 32,
	"xxl": 48
}

static func create_button_style(color: Color, hover_color: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	"""Create a styled button with rounded corners and hover effects"""
	var style = StyleBoxFlat.new()
	
	# Base styling
	style.bg_color = color
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	
	# Border
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = color.lightened(0.2)
	
	# Shadow effect
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 4
	style.shadow_offset = Vector2(0, 2)
	
	return style

static func create_panel_style(color: Color = COLORS.surface) -> StyleBoxFlat:
	"""Create a styled panel background"""
	var style = StyleBoxFlat.new()
	
	style.bg_color = color
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	
	# Subtle border
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = color.lightened(0.1)
	
	# Shadow
	style.shadow_color = Color(0, 0, 0, 0.4)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0, 4)
	
	return style

static func style_button(button: Button, color_key: String = "primary"):
	"""Apply consistent styling to a button"""
	if not button:
		return
	
	var base_color = COLORS.get(color_key, COLORS.primary)
	var hover_color = base_color.lightened(0.2)
	var pressed_color = base_color.darkened(0.2)
	
	# Normal state
	button.add_theme_stylebox_override("normal", create_button_style(base_color))
	
	# Hover state
	button.add_theme_stylebox_override("hover", create_button_style(hover_color))
	
	# Pressed state
	button.add_theme_stylebox_override("pressed", create_button_style(pressed_color))
	
	# Text styling
	button.add_theme_color_override("font_color", COLORS.text_primary)
	button.add_theme_color_override("font_hover_color", COLORS.text_primary)
	button.add_theme_color_override("font_pressed_color", COLORS.text_primary)
	button.add_theme_font_size_override("font_size", FONT_SIZES.body)
	
	# Add shadow to text
	button.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	button.add_theme_constant_override("shadow_offset_x", 1)
	button.add_theme_constant_override("shadow_offset_y", 1)

static func style_label(label: Label, size_key: String = "body", color_key: String = "text_primary"):
	"""Apply consistent styling to a label"""
	if not label:
		return
	
	var color = COLORS.get(color_key, COLORS.text_primary)
	var font_size = FONT_SIZES.get(size_key, FONT_SIZES.body)
	
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", font_size)
	
	# Add shadow for better readability
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)

static func style_panel(panel: Panel, color_key: String = "surface"):
	"""Apply consistent styling to a panel"""
	if not panel:
		return
	
	var color = COLORS.get(color_key, COLORS.surface)
	panel.add_theme_stylebox_override("panel", create_panel_style(color))

static func create_progress_bar_style(fill_color: Color, bg_color: Color) -> StyleBoxFlat:
	"""Create a styled progress bar"""
	var style = StyleBoxFlat.new()
	
	style.bg_color = fill_color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	
	return style

static func style_progress_bar(progress_bar: ProgressBar, fill_color_key: String = "primary"):
	"""Apply consistent styling to a progress bar"""
	if not progress_bar:
		return
	
	var fill_color = COLORS.get(fill_color_key, COLORS.primary)
	var bg_color = COLORS.background
	
	progress_bar.add_theme_stylebox_override("fill", create_progress_bar_style(fill_color, bg_color))
	progress_bar.add_theme_stylebox_override("background", create_progress_bar_style(bg_color, bg_color))

static func add_hover_animation(button: Button):
	"""Add hover animation to a button"""
	if not button:
		return
	
	button.mouse_entered.connect(func(): animate_button_hover(button, true))
	button.mouse_exited.connect(func(): animate_button_hover(button, false))

static func animate_button_hover(button: Button, is_hovering: bool):
	"""Animate button on hover"""
	if not button:
		return
	
	var tween = button.create_tween()
	var target_scale = Vector2(1.05, 1.05) if is_hovering else Vector2(1.0, 1.0)
	
	tween.tween_property(button, "scale", target_scale, 0.1).set_ease(Tween.EASE_OUT)

static func create_notification_style() -> StyleBoxFlat:
	"""Create style for notifications"""
	var style = StyleBoxFlat.new()
	
	style.bg_color = COLORS.surface
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	
	# Glowing border
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = COLORS.accent
	
	# Strong shadow
	style.shadow_color = Color(0, 0, 0, 0.6)
	style.shadow_size = 12
	style.shadow_offset = Vector2(0, 6)
	
	return style
