class_name KenneySlider
extends HSlider

## KenneySlider Component
## A custom slider component using Kenney UI pack textures for audio settings and other value controls.
## Displays a background track, colored fill bar based on value, and a draggable handle.
## Supports optional value label display with customizable suffix.

# Enums for slider configuration
enum ColorPack {
	YELLOW,
	RED,
	BLUE,
	GREEN,
	GREY
}

# Configuration properties
@export var slider_color: ColorPack = ColorPack.YELLOW
@export var show_value_label: bool = true
@export var value_suffix: String = "%"

# Animation settings
@export var handle_hover_scale: float = 1.1
@export var handle_drag_scale: float = 1.15
@export var animation_duration: float = 0.1

# Child node references
var background_rect: TextureRect
var fill_rect: TextureRect
var handle_rect: TextureRect
var value_label: Label

# Animation state tracking
var current_tween: Tween = null
var is_dragging: bool = false
var original_handle_scale: Vector2 = Vector2.ONE

# Texture cache
var texture_cache: Dictionary = {}

# Mapping from enum to color name
const COLOR_NAMES: Dictionary = {
	ColorPack.YELLOW: "Yellow",
	ColorPack.RED: "Red",
	ColorPack.BLUE: "Blue",
	ColorPack.GREEN: "Green",
	ColorPack.GREY: "Grey"
}


func _ready() -> void:
	# Load and cache textures
	_load_textures()
	
	# Set up child nodes
	_setup_children()
	
	# Connect signals for interaction
	value_changed.connect(_on_value_changed)
	drag_started.connect(_on_drag_started)
	drag_ended.connect(_on_drag_ended)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Initial update
	_update_fill_bar()
	_update_value_label()
	
	# Hide default slider visuals (we're using custom drawing)
	add_theme_stylebox_override("slider", StyleBoxEmpty.new())
	add_theme_stylebox_override("grabber_area", StyleBoxEmpty.new())
	add_theme_stylebox_override("grabber_area_highlight", StyleBoxEmpty.new())


func _load_textures() -> void:
	"""Load and cache all slider textures."""
	var color_name = COLOR_NAMES[slider_color]
	var base_path = "res://assets/ui_packs/%s/Default/" % color_name
	
	# Load background (grey track)
	var background_path = base_path.replace(color_name, "Yellow") + "slide_horizontal_grey.png"
	texture_cache["background"] = load_kenney_texture(background_path)
	
	# Load fill (colored track)
	var fill_path = base_path + "slide_horizontal_color.png"
	texture_cache["fill"] = load_kenney_texture(fill_path)
	
	# Load handle (draggable knob)
	var handle_path = base_path + "slide_hangle.png"
	texture_cache["handle"] = load_kenney_texture(handle_path)


func _setup_children() -> void:
	"""Set up TextureRect nodes for background, fill, and handle."""
	# Background track (full width)
	background_rect = TextureRect.new()
	background_rect.texture = texture_cache["background"]
	background_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_rect.stretch_mode = TextureRect.STRETCH_SCALE
	background_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background_rect)
	
	# Position background to fill the slider area
	background_rect.anchor_left = 0.0
	background_rect.anchor_top = 0.5
	background_rect.anchor_right = 1.0
	background_rect.anchor_bottom = 0.5
	background_rect.offset_top = -19  # Half of texture height (39px)
	background_rect.offset_bottom = 20
	background_rect.offset_left = 0
	background_rect.offset_right = 0
	
	# Fill bar (width based on value)
	fill_rect = TextureRect.new()
	fill_rect.texture = texture_cache["fill"]
	fill_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fill_rect.stretch_mode = TextureRect.STRETCH_SCALE
	fill_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fill_rect)
	
	# Position fill bar (will be updated based on value)
	fill_rect.anchor_left = 0.0
	fill_rect.anchor_top = 0.5
	fill_rect.anchor_right = 0.0  # Will be updated
	fill_rect.anchor_bottom = 0.5
	fill_rect.offset_top = -19
	fill_rect.offset_bottom = 20
	fill_rect.offset_left = 0
	fill_rect.offset_right = 0
	
	# Handle (draggable knob)
	handle_rect = TextureRect.new()
	handle_rect.texture = texture_cache["handle"]
	handle_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	handle_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	handle_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(handle_rect)
	
	# Position handle (will be updated based on value)
	handle_rect.anchor_left = 0.0  # Will be updated
	handle_rect.anchor_top = 0.5
	handle_rect.anchor_right = 0.0  # Will be updated
	handle_rect.anchor_bottom = 0.5
	handle_rect.offset_left = -24  # Half of handle width (49px)
	handle_rect.offset_top = -24  # Half of handle height (49px)
	handle_rect.offset_right = 25
	handle_rect.offset_bottom = 25
	
	# Store original scale for animations
	original_handle_scale = handle_rect.scale
	
	# Value label (optional)
	if show_value_label:
		value_label = Label.new()
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		value_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(value_label)
		
		# Position label to the right of the slider
		value_label.anchor_left = 1.0
		value_label.anchor_top = 0.0
		value_label.anchor_right = 1.0
		value_label.anchor_bottom = 1.0
		value_label.offset_left = 10
		value_label.offset_right = 60


func _update_fill_bar() -> void:
	"""Update the fill bar width based on current value."""
	if not fill_rect:
		return
	
	# Calculate fill percentage
	var fill_percentage = (value - min_value) / (max_value - min_value)
	fill_percentage = clamp(fill_percentage, 0.0, 1.0)
	
	# Animate fill bar with smooth transition (0.2s)
	var fill_tween = create_tween()
	fill_tween.tween_property(fill_rect, "anchor_right", fill_percentage, 0.2).set_ease(Tween.EASE_OUT)


func _update_handle_position() -> void:
	"""Update the handle position based on current value."""
	if not handle_rect:
		return
	
	# Calculate handle position percentage
	var handle_percentage = (value - min_value) / (max_value - min_value)
	handle_percentage = clamp(handle_percentage, 0.0, 1.0)
	
	# Update handle anchors
	handle_rect.anchor_left = handle_percentage
	handle_rect.anchor_right = handle_percentage


func _update_value_label() -> void:
	"""Update the value label text."""
	if not value_label or not show_value_label:
		return
	
	# Format value based on suffix
	var display_value = int(value)
	value_label.text = str(display_value) + value_suffix


func load_kenney_texture(path: String) -> Texture2D:
	"""Load a Kenney texture with error handling and fallback."""
	var loaded_texture = load(path)
	if loaded_texture == null:
		push_error("Failed to load Kenney slider texture: " + path)
		return create_placeholder_texture()
	return loaded_texture


func create_placeholder_texture() -> Texture2D:
	"""Create a magenta placeholder texture for missing assets."""
	var img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color.MAGENTA)  # Obvious error color
	return ImageTexture.create_from_image(img)


# Public API methods

func set_slider_value(new_value: float) -> void:
	"""Set the slider value programmatically."""
	value = new_value
	_update_fill_bar()
	_update_handle_position()
	_update_value_label()


func play_handle_animation() -> void:
	"""Play a subtle bounce animation on the handle when value changes."""
	if not handle_rect or not editable:
		return
	
	# Cancel any existing animation
	if current_tween and current_tween.is_running():
		current_tween.kill()
	
	# Create bounce animation (0.15s total as per requirements)
	current_tween = create_tween()
	current_tween.tween_property(handle_rect, "scale", original_handle_scale * 1.2, 0.075).set_ease(Tween.EASE_OUT)
	current_tween.tween_property(handle_rect, "scale", original_handle_scale, 0.075).set_ease(Tween.EASE_IN)


# Signal handlers

func _on_value_changed(new_value: float) -> void:
	"""Handle value changes - update visuals and play animation."""
	_update_fill_bar()
	_update_handle_position()
	_update_value_label()
	
	# Play animation if dragging (provides feedback)
	if is_dragging:
		play_handle_animation()


func _on_drag_started() -> void:
	"""Handle drag start - scale up handle."""
	is_dragging = true
	
	if not handle_rect or not editable:
		return
	
	# Cancel any existing animation
	if current_tween and current_tween.is_running():
		current_tween.kill()
	
	# Scale up handle
	current_tween = create_tween()
	current_tween.tween_property(handle_rect, "scale", original_handle_scale * handle_drag_scale, animation_duration).set_ease(Tween.EASE_OUT)


func _on_drag_ended(value_changed: bool) -> void:
	"""Handle drag end - return handle to normal scale."""
	is_dragging = false
	
	if not handle_rect or not editable:
		return
	
	# Cancel any existing animation
	if current_tween and current_tween.is_running():
		current_tween.kill()
	
	# Return to normal scale
	current_tween = create_tween()
	current_tween.tween_property(handle_rect, "scale", original_handle_scale, animation_duration).set_ease(Tween.EASE_OUT)


func _on_mouse_entered() -> void:
	"""Handle mouse enter - scale up handle slightly."""
	if not editable or is_dragging:
		return
	
	if not handle_rect:
		return
	
	# Cancel any existing animation
	if current_tween and current_tween.is_running():
		current_tween.kill()
	
	# Scale up handle
	current_tween = create_tween()
	current_tween.tween_property(handle_rect, "scale", original_handle_scale * handle_hover_scale, animation_duration).set_ease(Tween.EASE_OUT)


func _on_mouse_exited() -> void:
	"""Handle mouse exit - return handle to normal scale."""
	if not editable or is_dragging:
		return
	
	if not handle_rect:
		return
	
	# Cancel any existing animation
	if current_tween and current_tween.is_running():
		current_tween.kill()
	
	# Return to normal scale
	current_tween = create_tween()
	current_tween.tween_property(handle_rect, "scale", original_handle_scale, animation_duration).set_ease(Tween.EASE_OUT)
