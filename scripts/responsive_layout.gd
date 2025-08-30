extends Control

# Responsive Layout System for mobile-first design
class_name ResponsiveLayout

# Screen size breakpoints
enum ScreenSize { SMALL, MEDIUM, LARGE }

# Layout configurations
var layout_configs = {
	ScreenSize.SMALL: {  # Phone portrait
		"button_size": Vector2(120, 50),
		"font_scale": 0.8,
		"spacing": 12,
		"margin": 16
	},
	ScreenSize.MEDIUM: {  # Phone landscape / small tablet
		"button_size": Vector2(140, 55),
		"font_scale": 1.0,
		"spacing": 16,
		"margin": 20
	},
	ScreenSize.LARGE: {  # Tablet / desktop
		"button_size": Vector2(160, 60),
		"font_scale": 1.2,
		"spacing": 20,
		"margin": 24
	}
}

var current_screen_size: ScreenSize
var safe_area_insets: Rect2

func _ready():
	update_layout()
	get_viewport().size_changed.connect(update_layout)

func update_layout():
	"""Update layout based on current screen size"""
	var viewport_size = get_viewport().get_visible_rect().size
	current_screen_size = determine_screen_size(viewport_size)
	
	# Get safe area for mobile devices
	safe_area_insets = DisplayServer.get_display_safe_area()
	
	apply_responsive_layout()

func determine_screen_size(viewport_size: Vector2) -> ScreenSize:
	"""Determine screen size category"""
	var min_dimension = min(viewport_size.x, viewport_size.y)
	
	if min_dimension < 400:
		return ScreenSize.SMALL
	elif min_dimension < 600:
		return ScreenSize.MEDIUM
	else:
		return ScreenSize.LARGE

func apply_responsive_layout():
	"""Apply layout configuration for current screen size"""
	var config = layout_configs[current_screen_size]
	
	# Apply to all UI elements recursively
	apply_layout_to_children(self, config)

func apply_layout_to_children(node: Node, config: Dictionary):
	"""Recursively apply layout configuration to children"""
	for child in node.get_children():
		if child is Button:
			apply_button_layout(child, config)
		elif child is Label:
			apply_label_layout(child, config)
		elif child is VBoxContainer or child is HBoxContainer:
			apply_container_layout(child, config)
		elif child is MarginContainer:
			apply_margin_layout(child, config)
		
		# Recursively apply to children
		if child.get_child_count() > 0:
			apply_layout_to_children(child, config)

func apply_button_layout(button: Button, config: Dictionary):
	"""Apply responsive layout to buttons"""
	button.custom_minimum_size = config.button_size
	
	# Adjust font size
	var current_font_size = button.get_theme_font_size("font_size")
	if current_font_size > 0:
		button.add_theme_font_size_override("font_size", int(current_font_size * config.font_scale))

func apply_label_layout(label: Label, config: Dictionary):
	"""Apply responsive layout to labels"""
	var current_font_size = label.get_theme_font_size("font_size")
	if current_font_size > 0:
		label.add_theme_font_size_override("font_size", int(current_font_size * config.font_scale))

func apply_container_layout(container: Container, config: Dictionary):
	"""Apply responsive layout to containers"""
	if container is VBoxContainer:
		container.add_theme_constant_override("separation", config.spacing)
	elif container is HBoxContainer:
		container.add_theme_constant_override("separation", config.spacing)

func apply_margin_layout(margin_container: MarginContainer, config: Dictionary):
	"""Apply responsive margins"""
	var margin = config.margin
	margin_container.add_theme_constant_override("margin_left", margin)
	margin_container.add_theme_constant_override("margin_right", margin)
	margin_container.add_theme_constant_override("margin_top", margin)
	margin_container.add_theme_constant_override("margin_bottom", margin)

func get_safe_area_margins() -> Dictionary:
	"""Get safe area margins for mobile devices"""
	return {
		"top": safe_area_insets.position.y,
		"bottom": safe_area_insets.size.y,
		"left": safe_area_insets.position.x,
		"right": safe_area_insets.size.x
	}

func create_responsive_button(text: String, size_multiplier: float = 1.0) -> Button:
	"""Create a button with responsive sizing"""
	var button = Button.new()
	button.text = text
	
	var config = layout_configs[current_screen_size]
	button.custom_minimum_size = config.button_size * size_multiplier
	
	# Apply basic button styling
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.3, 0.6, 1.0)
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	button.add_theme_stylebox_override("normal", style_box)
	
	return button

func create_responsive_label(text: String, size_key: String = "body") -> Label:
	"""Create a label with responsive sizing"""
	var label = Label.new()
	label.text = text
	
	# Apply basic label styling with responsive scaling
	var config = layout_configs[current_screen_size]
	var base_size = 16 if size_key == "body" else 20
	label.add_theme_font_size_override("font_size", int(base_size * config.font_scale))
	label.add_theme_color_override("font_color", Color.WHITE)
	
	return label
