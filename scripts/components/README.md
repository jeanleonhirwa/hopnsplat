# UI Components

This directory contains reusable UI components for the Kenney UI pack overhaul.

## KenneyButton

A reusable button component that wraps `TextureButton` with Kenney asset textures.

### Features

- **Multiple Button Styles**: Rectangle, Round, and Square variants with different visual styles (flat, gloss, depth_gloss, gradient, line, border)
- **Color Packs**: Yellow, Red, Blue, Green, and Grey color schemes
- **Optional Icon**: Display an icon texture on the button
- **Optional Text Label**: Display text alongside or instead of an icon
- **Automatic State Management**: Handles normal, hover, pressed, and disabled states
- **Accessibility**: Validates minimum 44x44px touch target size
- **Error Handling**: Provides fallback placeholder textures for missing assets

### Usage

#### In GDScript

```gdscript
# Create a button programmatically
var button = KenneyButton.new()
button.button_style = KenneyButton.ButtonStyle.RECTANGLE_DEPTH_GLOSS
button.color_pack = KenneyButton.ColorPack.YELLOW
button.button_text = "PLAY"
button.custom_minimum_size = Vector2(300, 70)
add_child(button)

# Update button dynamically
button.set_button_text("START GAME")
button.set_icon(preload("res://assets/ui_packs/Extra/Default/icon_play.png"))
```

#### In Godot Editor

1. Add a `TextureButton` node to your scene
2. Attach the `kenney_button.gd` script to it
3. Configure the exported properties in the Inspector:
   - **Button Style**: Choose from 30 available styles
   - **Color Pack**: Select Yellow, Red, Blue, Green, or Grey
   - **Icon Texture**: Optional icon to display
   - **Button Text**: Optional text label
   - **Enable Idle Wobble**: Enable subtle animation (placeholder for Task 2.4)

### Button Styles

The component supports 30 button style variants:

**Rectangle Styles:**
- RECTANGLE_FLAT
- RECTANGLE_GLOSS
- RECTANGLE_DEPTH_GLOSS (recommended for primary buttons)
- RECTANGLE_DEPTH_FLAT
- RECTANGLE_GRADIENT
- RECTANGLE_DEPTH_GRADIENT
- RECTANGLE_LINE
- RECTANGLE_DEPTH_LINE
- RECTANGLE_BORDER
- RECTANGLE_DEPTH_BORDER

**Round Styles:**
- ROUND_FLAT
- ROUND_GLOSS
- ROUND_DEPTH_GLOSS (recommended for icon-only buttons)
- ROUND_DEPTH_FLAT
- ROUND_GRADIENT
- ROUND_DEPTH_GRADIENT
- ROUND_LINE
- ROUND_DEPTH_LINE
- ROUND_BORDER
- ROUND_DEPTH_BORDER

**Square Styles:**
- SQUARE_FLAT
- SQUARE_GLOSS
- SQUARE_DEPTH_GLOSS (recommended for back/navigation buttons)
- SQUARE_DEPTH_FLAT
- SQUARE_GRADIENT
- SQUARE_DEPTH_GRADIENT
- SQUARE_LINE
- SQUARE_DEPTH_LINE
- SQUARE_BORDER
- SQUARE_DEPTH_BORDER

### Color Packs

- **YELLOW**: Primary color, warm and inviting (matches pink alien theme)
- **RED**: For important actions, warnings, or quit buttons
- **BLUE**: Alternative accent color
- **GREEN**: For positive actions or confirmations
- **GREY**: For disabled states or secondary actions

### Animation Integration (Coming in Task 2.4)

The following methods are placeholders and will be implemented when the UIAnimationManager is created:

- `play_hover_animation()`: Bounce-in effect when hovering
- `play_press_animation()`: Squash effect when pressed
- `play_idle_wobble()`: Subtle wobble animation for important buttons

### Sound Integration (Coming in Task 3.3)

The following properties are placeholders for sound integration:

- `hover_sound`: AudioStream to play on hover
- `click_sound`: AudioStream to play on click

### Technical Details

**Texture Loading:**
- Textures are loaded from `res://assets/ui_packs/{ColorPack}/Default/{style_name}.png`
- Disabled state uses Grey pack variant
- Missing textures fall back to magenta placeholder for easy debugging

**State Mapping:**
- Normal, Hover, Pressed: Use the same texture (animation will handle visual changes)
- Disabled: Uses Grey pack variant or modulated normal texture

**Child Node Structure:**
- Icon (TextureRect): Optional, positioned left or centered
- Label (Label): Optional, positioned right of icon or centered

**Accessibility:**
- Validates minimum 44x44px touch target size in `_ready()`
- Logs warning if button is below minimum size
- Automatically adjusts `custom_minimum_size` to meet requirements

### Example Configurations

**Primary Play Button:**
```gdscript
button.button_style = KenneyButton.ButtonStyle.RECTANGLE_DEPTH_GLOSS
button.color_pack = KenneyButton.ColorPack.YELLOW
button.button_text = "PLAY"
button.enable_idle_wobble = true
button.custom_minimum_size = Vector2(300, 70)
```

**Secondary Shop Button:**
```gdscript
button.button_style = KenneyButton.ButtonStyle.RECTANGLE_GLOSS
button.color_pack = KenneyButton.ColorPack.YELLOW
button.button_text = "SHOP"
button.custom_minimum_size = Vector2(300, 60)
```

**Quit Button (Red):**
```gdscript
button.button_style = KenneyButton.ButtonStyle.RECTANGLE_GLOSS
button.color_pack = KenneyButton.ColorPack.RED
button.button_text = "QUIT"
button.custom_minimum_size = Vector2(300, 60)
```

**Back Button (Square):**
```gdscript
button.button_style = KenneyButton.ButtonStyle.SQUARE_DEPTH_GLOSS
button.color_pack = KenneyButton.ColorPack.YELLOW
button.icon_texture = preload("res://assets/ui_packs/Extra/Default/arrow_basic_w.png")
button.custom_minimum_size = Vector2(60, 60)
```

### Requirements Satisfied

This component satisfies the following requirements from the design document:

- **Requirement 2.1**: Replace StyleBoxFlat buttons with TextureButton using Kenney assets
- **Requirement 2.2**: Use Yellow/Red color palettes
- **Requirement 2.3**: Show appropriate textures for button states
- **Requirement 2.4**: Ensure 44x44px minimum touch target size
- **Requirement 2.6**: Support icon overlays on buttons

### Future Enhancements

- Task 2.4: Animation integration with UIAnimationManager
- Task 3.3: Sound feedback integration with AudioManager
- Task 14.6: Texture atlas optimization for reduced draw calls
