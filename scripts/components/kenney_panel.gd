class_name KenneyPanel
extends NinePatchRect

## KenneyPanel Component
## A reusable panel background component using NinePatchRect for scalable backgrounds.
## Supports different panel styles, color packs, and semi-transparency for overlay panels.
## Provides placeholders for entrance animations (to be added in later tasks).

# Enums for panel configuration
enum PanelStyle {
	RECTANGLE,
	RECTANGLE_DEPTH,
	SQUARE,
	SQUARE_DEPTH
}

enum ColorPack {
	YELLOW,
	RED,
	BLUE,
	GREEN,
	GREY
}

# Configuration properties
@export var panel_style: PanelStyle = PanelStyle.RECTANGLE_DEPTH
@export var color_pack: ColorPack = ColorPack.YELLOW
@export var semi_transparent: bool = false

# Transparency settings for overlay panels
@export_range(0.0, 1.0) var transparency_alpha: float = 0.85

# Mapping from enum to texture filename
const STYLE_NAMES: Dictionary = {
	PanelStyle.RECTANGLE: "input_rectangle",
	PanelStyle.RECTANGLE_DEPTH: "input_rectangle",  # Using same texture, depth is visual
	PanelStyle.SQUARE: "input_square",
	PanelStyle.SQUARE_DEPTH: "input_square"  # Using same texture, depth is visual
}

const COLOR_NAMES: Dictionary = {
	ColorPack.YELLOW: "Yellow",
	ColorPack.RED: "Red",
	ColorPack.BLUE: "Blue",
	ColorPack.GREEN: "Green",
	ColorPack.GREY: "Grey"
}


func _ready() -> void:
	# Load and apply panel texture
	_load_panel_texture()
	
	# Apply transparency if needed
	if semi_transparent:
		set_transparency(transparency_alpha)
	
	# Placeholder: Entrance animation will be added in Task 2.4


func _load_panel_texture() -> void:
	"""Load and apply the panel background texture based on style and color."""
	var style_name = STYLE_NAMES[panel_style]
	
	# Panel textures are in the Extra pack for input backgrounds
	var texture_path = "res://assets/ui_packs/Extra/Default/" + style_name + ".png"
	
	var panel_texture = load_kenney_texture(texture_path)
	
	if panel_texture:
		texture = panel_texture
		
		# Set nine-patch margins for proper scaling
		# These values work well for the Kenney input textures
		# Adjust based on the actual texture border sizes
		match panel_style:
			PanelStyle.RECTANGLE, PanelStyle.RECTANGLE_DEPTH:
				# Rectangle panels have ~10px borders
				patch_margin_left = 10
				patch_margin_top = 10
				patch_margin_right = 10
				patch_margin_bottom = 10
			PanelStyle.SQUARE, PanelStyle.SQUARE_DEPTH:
				# Square panels have ~10px borders
				patch_margin_left = 10
				patch_margin_top = 10
				patch_margin_right = 10
				patch_margin_bottom = 10


func load_kenney_texture(path: String) -> Texture2D:
	"""Load a Kenney texture with error handling and fallback."""
	var loaded_texture = load(path)
	if loaded_texture == null:
		push_error("Failed to load Kenney panel texture: " + path)
		return create_placeholder_texture()
	return loaded_texture


func create_placeholder_texture() -> Texture2D:
	"""Create a magenta placeholder texture for missing assets."""
	var img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color.MAGENTA)  # Obvious error color
	return ImageTexture.create_from_image(img)


# Public API methods

func set_transparency(alpha: float) -> void:
	"""Set the transparency level for overlay panels (0.0 = fully transparent, 1.0 = fully opaque)."""
	transparency_alpha = clamp(alpha, 0.0, 1.0)
	modulate.a = transparency_alpha


# Placeholder method for animation integration (Task 2.4)
func play_entrance_animation() -> void:
	"""Placeholder: Will be implemented in Task 2.4 with UIAnimationManager."""
	pass
