class_name KenneyButton
extends TextureButton

## KenneyButton Component
## A reusable button component that wraps TextureButton with Kenney asset textures.
## Supports different button styles, color packs, optional icons and text labels.
## Provides placeholders for animation and sound integration (to be added in later tasks).

# Enums for button configuration
enum ButtonStyle {
	RECTANGLE_FLAT,
	RECTANGLE_GLOSS,
	RECTANGLE_DEPTH_GLOSS,
	RECTANGLE_DEPTH_FLAT,
	RECTANGLE_GRADIENT,
	RECTANGLE_DEPTH_GRADIENT,
	RECTANGLE_LINE,
	RECTANGLE_DEPTH_LINE,
	RECTANGLE_BORDER,
	RECTANGLE_DEPTH_BORDER,
	ROUND_FLAT,
	ROUND_GLOSS,
	ROUND_DEPTH_GLOSS,
	ROUND_DEPTH_FLAT,
	ROUND_GRADIENT,
	ROUND_DEPTH_GRADIENT,
	ROUND_LINE,
	ROUND_DEPTH_LINE,
	ROUND_BORDER,
	ROUND_DEPTH_BORDER,
	SQUARE_FLAT,
	SQUARE_GLOSS,
	SQUARE_DEPTH_GLOSS,
	SQUARE_DEPTH_FLAT,
	SQUARE_GRADIENT,
	SQUARE_DEPTH_GRADIENT,
	SQUARE_LINE,
	SQUARE_DEPTH_LINE,
	SQUARE_BORDER,
	SQUARE_DEPTH_BORDER
}

enum ColorPack {
	YELLOW,
	RED,
	BLUE,
	GREEN,
	GREY
}

# Configuration properties
@export var button_style: ButtonStyle = ButtonStyle.RECTANGLE_DEPTH_GLOSS
@export var color_pack: ColorPack = ColorPack.YELLOW
@export var icon_texture: Texture2D
@export var button_text: String = ""
@export var enable_idle_wobble: bool = false

# Animation settings
@export var hover_scale: float = 1.1
@export var press_scale: float = 0.95
@export var animation_duration: float = 0.15

# Sound settings (placeholders for Task 3.3)
@export var hover_sound: AudioStream
@export var click_sound: AudioStream

# Child node references
var icon_node: TextureRect
var label_node: Label

# Animation state tracking
var current_tween: Tween = null
var idle_wobble_tween: Tween = null
var original_scale: Vector2 = Vector2.ONE

# Sound cooldown tracking (Task 3.3)
var last_hover_time: float = 0.0
const HOVER_SOUND_COOLDOWN: float = 0.1  # 100ms cooldown

# Texture cache for efficient state management
var texture_cache: Dictionary = {}

# Mapping from enum to texture filename
const STYLE_NAMES: Dictionary = {
	ButtonStyle.RECTANGLE_FLAT: "button_rectangle_flat",
	ButtonStyle.RECTANGLE_GLOSS: "button_rectangle_gloss",
	ButtonStyle.RECTANGLE_DEPTH_GLOSS: "button_rectangle_depth_gloss",
	ButtonStyle.RECTANGLE_DEPTH_FLAT: "button_rectangle_depth_flat",
	ButtonStyle.RECTANGLE_GRADIENT: "button_rectangle_gradient",
	ButtonStyle.RECTANGLE_DEPTH_GRADIENT: "button_rectangle_depth_gradient",
	ButtonStyle.RECTANGLE_LINE: "button_rectangle_line",
	ButtonStyle.RECTANGLE_DEPTH_LINE: "button_rectangle_depth_line",
	ButtonStyle.RECTANGLE_BORDER: "button_rectangle_border",
	ButtonStyle.RECTANGLE_DEPTH_BORDER: "button_rectangle_depth_border",
	ButtonStyle.ROUND_FLAT: "button_round_flat",
	ButtonStyle.ROUND_GLOSS: "button_round_gloss",
	ButtonStyle.ROUND_DEPTH_GLOSS: "button_round_depth_gloss",
	ButtonStyle.ROUND_DEPTH_FLAT: "button_round_depth_flat",
	ButtonStyle.ROUND_GRADIENT: "button_round_gradient",
	ButtonStyle.ROUND_DEPTH_GRADIENT: "button_round_depth_gradient",
	ButtonStyle.ROUND_LINE: "button_round_line",
	ButtonStyle.ROUND_DEPTH_LINE: "button_round_depth_line",
	ButtonStyle.ROUND_BORDER: "button_round_border",
	ButtonStyle.ROUND_DEPTH_BORDER: "button_round_depth_border",
	ButtonStyle.SQUARE_FLAT: "button_square_flat",
	ButtonStyle.SQUARE_GLOSS: "button_square_gloss",
	ButtonStyle.SQUARE_DEPTH_GLOSS: "button_square_depth_gloss",
	ButtonStyle.SQUARE_DEPTH_FLAT: "button_square_depth_flat",
	ButtonStyle.SQUARE_GRADIENT: "button_square_gradient",
	ButtonStyle.SQUARE_DEPTH_GRADIENT: "button_square_depth_gradient",
	ButtonStyle.SQUARE_LINE: "button_square_line",
	ButtonStyle.SQUARE_DEPTH_LINE: "button_square_depth_line",
	ButtonStyle.SQUARE_BORDER: "button_square_border",
	ButtonStyle.SQUARE_DEPTH_BORDER: "button_square_depth_border"
}

const COLOR_NAMES: Dictionary = {
	ColorPack.YELLOW: "Yellow",
	ColorPack.RED: "Red",
	ColorPack.BLUE: "Blue",
	ColorPack.GREEN: "Green",
	ColorPack.GREY: "Grey"
}


func _ready() -> void:
	# Store original scale for animations
	original_scale = scale
	
	# Configure TextureButton to scale the texture to fit the button size
	ignore_texture_size = false
	stretch_mode = TextureButton.STRETCH_SCALE
	
	# Load and cache textures
	_load_textures()
	
	# Apply textures to button states
	_apply_textures()
	
	# Set up child nodes if needed
	_setup_children()
	
	# Validate touch target size (accessibility requirement)
	_validate_touch_target_size()
	
	# Connect signals for animation integration
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	
	# Start idle wobble if enabled
	if enable_idle_wobble:
		play_idle_wobble()


func _load_textures() -> void:
	"""Load and cache all button state textures."""
	var color_name = COLOR_NAMES[color_pack]
	var style_name = STYLE_NAMES[button_style]
	# Use Double size textures for better quality and proper sizing
	var base_path = "res://assets/ui_packs/%s/Double/" % color_name
	
	# Load normal state texture
	var normal_path = base_path + style_name + ".png"
	var normal_texture = load_kenney_texture(normal_path)
	
	if normal_texture:
		texture_cache["normal"] = normal_texture
		# For hover and pressed, we use the same texture (animation handles visual change)
		texture_cache["hover"] = normal_texture
		texture_cache["pressed"] = normal_texture
	
	# Load disabled state texture (use Grey pack variant)
	var disabled_path = "res://assets/ui_packs/Grey/Double/" + style_name + ".png"
	var disabled_texture = load_kenney_texture(disabled_path)
	
	if disabled_texture:
		texture_cache["disabled"] = disabled_texture
	else:
		# Fallback: use normal texture with reduced modulation
		texture_cache["disabled"] = normal_texture


func _apply_textures() -> void:
	"""Apply cached textures to button states."""
	if texture_cache.has("normal"):
		texture_normal = texture_cache["normal"]
	if texture_cache.has("hover"):
		texture_hover = texture_cache["hover"]
	if texture_cache.has("pressed"):
		texture_pressed = texture_cache["pressed"]
	if texture_cache.has("disabled"):
		texture_disabled = texture_cache["disabled"]


func _setup_children() -> void:
	"""Set up optional Icon and Label child nodes."""
	# Set up icon if texture is provided
	if icon_texture:
		icon_node = TextureRect.new()
		icon_node.texture = icon_texture
		icon_node.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(icon_node)
		
		# Position icon (centered or left-aligned depending on text presence)
		if button_text.is_empty():
			# Center icon
			icon_node.anchor_left = 0.5
			icon_node.anchor_top = 0.5
			icon_node.anchor_right = 0.5
			icon_node.anchor_bottom = 0.5
			icon_node.offset_left = -16
			icon_node.offset_top = -16
			icon_node.offset_right = 16
			icon_node.offset_bottom = 16
		else:
			# Left-align icon with some padding
			icon_node.anchor_left = 0.0
			icon_node.anchor_top = 0.5
			icon_node.anchor_right = 0.0
			icon_node.anchor_bottom = 0.5
			icon_node.offset_left = 10
			icon_node.offset_top = -16
			icon_node.offset_right = 42
			icon_node.offset_bottom = 16
	
	# Set up label if text is provided
	if not button_text.is_empty():
		label_node = Label.new()
		label_node.text = button_text
		label_node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label_node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		# Style the label with proper font size and color
		label_node.add_theme_font_size_override("font_size", 18)
		label_node.add_theme_color_override("font_color", Color.WHITE)
		label_node.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
		label_node.add_theme_constant_override("shadow_offset_x", 2)
		label_node.add_theme_constant_override("shadow_offset_y", 2)
		
		add_child(label_node)
		
		# Position label
		if icon_texture:
			# Offset label to the right of icon
			label_node.anchor_left = 0.0
			label_node.anchor_top = 0.0
			label_node.anchor_right = 1.0
			label_node.anchor_bottom = 1.0
			label_node.offset_left = 50
			label_node.offset_right = -10
		else:
			# Center label
			label_node.anchor_left = 0.0
			label_node.anchor_top = 0.0
			label_node.anchor_right = 1.0
			label_node.anchor_bottom = 1.0
			label_node.offset_left = 10
			label_node.offset_top = 0
			label_node.offset_right = -10
			label_node.offset_bottom = 0


func _validate_touch_target_size() -> void:
	"""Ensure button meets minimum 44x44px touch target size for accessibility."""
	if custom_minimum_size.x < 44 or custom_minimum_size.y < 44:
		push_warning("Button '%s' below minimum touch target size (44x44px)" % name)
		custom_minimum_size = Vector2(
			max(custom_minimum_size.x, 44),
			max(custom_minimum_size.y, 44)
		)


func load_kenney_texture(path: String) -> Texture2D:
	"""Load a Kenney texture with error handling and fallback."""
	var texture = load(path)
	if texture == null:
		push_error("Failed to load Kenney texture: " + path)
		return create_placeholder_texture()
	return texture


func create_placeholder_texture() -> Texture2D:
	"""Create a magenta placeholder texture for missing assets."""
	var img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color.MAGENTA)  # Obvious error color
	return ImageTexture.create_from_image(img)


# Public API methods

func set_button_text(text: String) -> void:
	"""Update the button text dynamically."""
	button_text = text
	if label_node:
		label_node.text = text
	elif not text.is_empty():
		# Create label if it doesn't exist
		_setup_children()


func set_icon(texture: Texture2D) -> void:
	"""Update the button icon dynamically."""
	icon_texture = texture
	if icon_node:
		icon_node.texture = texture
	elif texture:
		# Create icon if it doesn't exist
		_setup_children()


# Placeholder methods for animation integration (Task 2.4)
func play_hover_animation() -> void:
	"""Play bounce-in animation when button is hovered."""
	if disabled:
		return
	
	# Cancel any existing animation
	if current_tween and current_tween.is_running():
		current_tween.kill()
	
	# Call UIAnimationManager to create bounce-in effect
	current_tween = UIAnimationManager.bounce_in(self, animation_duration, hover_scale)


func play_press_animation() -> void:
	"""Play squash animation when button is pressed."""
	if disabled:
		return
	
	# Cancel any existing animation
	if current_tween and current_tween.is_running():
		current_tween.kill()
	
	# Call UIAnimationManager to create squash effect
	current_tween = UIAnimationManager.squash(self, animation_duration * 0.67, press_scale)


func play_idle_wobble() -> void:
	"""Play subtle wobble animation for important buttons (loops)."""
	if disabled:
		return
	
	# Stop any existing wobble
	if idle_wobble_tween and idle_wobble_tween.is_running():
		idle_wobble_tween.kill()
	
	# Call UIAnimationManager to create wobble effect
	# Use smaller angle (2 degrees) and longer duration (2.5s) for subtle effect
	idle_wobble_tween = UIAnimationManager.wobble(self, true, 2.0, 2.5)


func stop_idle_wobble() -> void:
	"""Stop the idle wobble animation."""
	if idle_wobble_tween and idle_wobble_tween.is_running():
		idle_wobble_tween.kill()
		rotation_degrees = 0.0


func _on_mouse_entered() -> void:
	"""Handle mouse enter event - play hover animation and sound."""
	# Play hover sound with cooldown check (Task 3.3)
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_hover_time >= HOVER_SOUND_COOLDOWN:
		AudioManager.play_ui_hover()
		last_hover_time = current_time
	
	# Play hover animation
	play_hover_animation()


func _on_mouse_exited() -> void:
	"""Handle mouse exit event - return to normal scale."""
	if disabled:
		return
	
	# Cancel any existing animation
	if current_tween and current_tween.is_running():
		current_tween.kill()
	
	# Smoothly return to original scale
	current_tween = create_tween()
	current_tween.tween_property(self, "scale", original_scale, animation_duration * 0.5).set_ease(Tween.EASE_OUT)


func _on_button_down() -> void:
	"""Handle button press event - play press animation and click sound."""
	# Play click sound (Task 3.3)
	AudioManager.play_ui_click()
	
	# Play press animation
	play_press_animation()


func _on_button_up() -> void:
	"""Handle button release event - return to hover scale."""
	if disabled:
		return
	
	# Cancel any existing animation
	if current_tween and current_tween.is_running():
		current_tween.kill()
	
	# Return to hover scale (if mouse is still over button)
	var target_scale = original_scale * hover_scale if is_hovered() else original_scale
	current_tween = create_tween()
	current_tween.tween_property(self, "scale", target_scale, animation_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
