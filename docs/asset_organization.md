# Kenney UI Pack Asset Organization

## Overview

This document describes the organization and usage of Kenney UI pack assets integrated into the HopNSplat game. The assets are organized by color pack and type, providing a comprehensive library of UI elements for creating a playful, engaging interface that matches the game's pink alien theme.

## Folder Structure

```
assets/
├── ui_packs/                    # Kenney UI texture assets
│   ├── Yellow/                  # Primary color pack (warm, inviting)
│   │   ├── Default/             # Standard resolution textures
│   │   └── Double/              # 2x resolution for high-DPI displays
│   ├── Red/                     # Secondary color pack (important actions, warnings)
│   │   ├── Default/
│   │   └── Double/
│   ├── Blue/                    # Available but not primary
│   │   ├── Default/
│   │   └── Double/
│   ├── Green/                   # Available but not primary
│   │   ├── Default/
│   │   └── Double/
│   ├── Grey/                    # Used for disabled states
│   │   ├── Default/
│   │   └── Double/
│   └── Extra/                   # Color-neutral elements (panels, dividers, icons)
│       ├── Default/
│       └── Double/
├── ui_sounds/                   # Kenney UI audio feedback
│   ├── click-a.ogg              # Button press sound variant A
│   ├── click-b.ogg              # Button press sound variant B
│   ├── tap-a.ogg                # Button hover sound variant A
│   ├── tap-b.ogg                # Button hover sound variant B
│   ├── switch-a.ogg             # Toggle/checkbox sound variant A
│   └── switch-b.ogg             # Toggle/checkbox sound variant B
└── fonts/
    └── arial.ttf                # Default UI font
```

## Asset Categories

### 1. Buttons

Button textures are available in three shapes with multiple style variants:

#### Rectangle Buttons
**Location:** `assets/ui_packs/{Color}/Default/button_rectangle_*.png`

**Variants:**
- `button_rectangle_flat.png` - Simple flat design
- `button_rectangle_gloss.png` - Glossy finish
- `button_rectangle_gradient.png` - Gradient fill
- `button_rectangle_border.png` - Border outline only
- `button_rectangle_line.png` - Thin line style
- `button_rectangle_depth_flat.png` - Flat with depth shadow
- `button_rectangle_depth_gloss.png` - **Primary choice** - Glossy with depth
- `button_rectangle_depth_gradient.png` - Gradient with depth
- `button_rectangle_depth_border.png` - Border with depth
- `button_rectangle_depth_line.png` - Line with depth

**Usage:**
- Main action buttons (Play, Shop, Achievements)
- Navigation buttons (Continue, Restart, Menu)
- Standard UI interactions

**Typical Size:** 190x49 pixels (can be scaled)

#### Round Buttons
**Location:** `assets/ui_packs/{Color}/Default/button_round_*.png`

**Variants:** Same as rectangle (flat, gloss, gradient, border, line, depth variants)

**Usage:**
- Icon-only buttons
- Floating action buttons
- Special interactive elements

**Typical Size:** 49x49 pixels

#### Square Buttons
**Location:** `assets/ui_packs/{Color}/Default/button_square_*.png`

**Variants:** Same as rectangle (flat, gloss, gradient, border, line, depth variants)

**Usage:**
- Back buttons with arrow icons
- Settings buttons
- Compact navigation elements

**Typical Size:** 49x49 pixels

### 2. Panels and Backgrounds

Panel textures provide backgrounds for UI containers and overlays.

#### Input Panels
**Location:** `assets/ui_packs/Extra/Default/input_*.png`

**Files:**
- `input_rectangle.png` - Rectangular panel background
- `input_square.png` - Square panel background
- `input_outline_rectangle.png` - Outlined rectangular panel
- `input_outline_square.png` - Outlined square panel

**Usage:**
- Stats display panels (score, currency, high score)
- Container backgrounds for grouped UI elements
- Text input fields (if needed)
- Semi-transparent overlays for pause/game over screens

**Implementation:** Use with NinePatchRect for scalable backgrounds

### 3. Sliders

Slider components for volume controls and progress bars.

#### Horizontal Sliders
**Location:** `assets/ui_packs/{Color}/Default/slide_horizontal_*.png`

**Files:**
- `slide_horizontal_grey.png` - Background track (unfilled)
- `slide_horizontal_color.png` - Filled track (colored)
- `slide_horizontal_grey_section.png` - Segmented background
- `slide_horizontal_color_section.png` - Segmented filled
- `slide_horizontal_grey_section_wide.png` - Wide segmented background
- `slide_horizontal_color_section_wide.png` - Wide segmented filled
- `slide_hangle.png` - Slider handle/thumb (note: typo in original filename)

**Usage:**
- Audio volume controls (Master, Music, SFX)
- Progress bars for achievements
- Any adjustable value display

**Typical Size:** 190x39 pixels (track), 49x49 pixels (handle)

#### Vertical Sliders
**Location:** `assets/ui_packs/{Color}/Default/slide_vertical_*.png`

**Files:** Same variants as horizontal (grey, color, section, section_wide)

**Usage:**
- Vertical volume controls (if needed)
- Vertical progress indicators

### 4. Checkboxes and Toggles

Checkbox and radio button textures for settings and selections.

#### Square Checkboxes
**Location:** `assets/ui_packs/{Color}/Default/check_square_*.png`

**Files:**
- `check_square_grey.png` - Unchecked state (grey)
- `check_square_color.png` - Unchecked state (colored)
- `check_square_grey_checkmark.png` - Checked with checkmark (grey)
- `check_square_color_checkmark.png` - **Primary choice** - Checked with checkmark (colored)
- `check_square_grey_cross.png` - Checked with cross (grey)
- `check_square_color_cross.png` - Checked with cross (colored)
- `check_square_grey_square.png` - Checked with filled square (grey)
- `check_square_color_square.png` - Checked with filled square (colored)

**Usage:**
- Audio settings toggles (Music Enabled, SFX Enabled)
- Option selections
- Feature toggles

**Typical Size:** 38x36 pixels

#### Round Checkboxes (Radio Buttons)
**Location:** `assets/ui_packs/{Color}/Default/check_round_*.png`

**Files:**
- `check_round_grey.png` - Unchecked state (grey)
- `check_round_color.png` - Unchecked state (colored)
- `check_round_grey_circle.png` - Checked with filled circle (grey)
- `check_round_round_circle.png` - Checked with filled circle (colored)

**Usage:**
- Radio button selections
- Single-choice options

### 5. Icons

Small icon textures for button overlays and status indicators.

#### Basic Icons (Yellow/Red Packs)
**Location:** `assets/ui_packs/{Color}/Default/icon_*.png`

**Files:**
- `icon_checkmark.png` - Checkmark symbol (for purchased/equipped items)
- `icon_cross.png` - Cross/close symbol
- `icon_circle.png` - Filled circle
- `icon_square.png` - Filled square
- `icon_outline_checkmark.png` - Outlined checkmark
- `icon_outline_cross.png` - Outlined cross
- `icon_outline_circle.png` - Outlined circle
- `icon_outline_square.png` - Outlined square

**Usage:**
- Shop item status indicators (purchased, equipped)
- Button overlays
- Status symbols

#### Extra Icons (Extra Pack)
**Location:** `assets/ui_packs/Extra/Default/icon_*.png`

**Files:**
- `icon_play_dark.png` - Play/resume icon (dark)
- `icon_play_light.png` - Play/resume icon (light)
- `icon_play_outline.png` - Play/resume icon (outline)
- `icon_repeat_dark.png` - Restart/repeat icon (dark)
- `icon_repeat_light.png` - Restart/repeat icon (light)
- `icon_repeat_outline.png` - Restart/repeat icon (outline)
- `icon_arrow_up_dark.png` - Up arrow (dark)
- `icon_arrow_up_light.png` - Up arrow (light)
- `icon_arrow_up_outline.png` - Up arrow (outline)
- `icon_arrow_down_dark.png` - Down arrow (dark)
- `icon_arrow_down_light.png` - Down arrow (light)
- `icon_arrow_down_outline.png` - Down arrow (outline)

**Usage:**
- Button icons (play, restart, navigation)
- Directional indicators
- Action symbols

**Typical Size:** 32x32 pixels

### 6. Decorative Elements

Visual embellishments to enhance UI appeal.

#### Arrows
**Location:** `assets/ui_packs/{Color}/Default/arrow_*.png`

**Files:**
- `arrow_basic_n.png` / `arrow_basic_n_small.png` - North (up) arrow
- `arrow_basic_s.png` / `arrow_basic_s_small.png` - South (down) arrow
- `arrow_basic_e.png` / `arrow_basic_e_small.png` - East (right) arrow
- `arrow_basic_w.png` / `arrow_basic_w_small.png` - West (left) arrow
- `arrow_decorative_n.png` / `arrow_decorative_n_small.png` - Decorative north arrow
- `arrow_decorative_s.png` / `arrow_decorative_s_small.png` - Decorative south arrow
- `arrow_decorative_e.png` / `arrow_decorative_e_small.png` - Decorative east arrow
- `arrow_decorative_w.png` / `arrow_decorative_w_small.png` - Decorative west arrow

**Usage:**
- Back button icons (arrow_basic_w)
- Decorative elements on MainMenu (arrow_decorative_s)
- Navigation hints
- Floating animated elements

#### Stars
**Location:** `assets/ui_packs/{Color}/Default/star*.png`

**Files:**
- `star.png` - Filled star (for ratings, achievements)
- `star_outline.png` - Outlined star (for locked achievements)
- `star_outline_depth.png` - Outlined star with depth shadow

**Usage:**
- Achievement status indicators (filled = unlocked, outline = locked)
- Star ratings on GameOver screen
- Particle effects for celebrations
- Decorative floating elements on MainMenu
- High score indicators

**Typical Size:** 32x32 pixels

#### Dividers
**Location:** `assets/ui_packs/Extra/Default/divider*.png`

**Files:**
- `divider.png` - Simple horizontal divider line
- `divider_edges.png` - Divider with decorative edges

**Usage:**
- Section separators in PauseScreen
- Visual breaks between UI groups
- Header/footer separators

### 7. UI Sounds

Audio feedback for UI interactions.

**Location:** `assets/ui_sounds/`

**Files:**
- `tap-a.ogg` - Hover sound variant A (light tap)
- `tap-b.ogg` - Hover sound variant B (light tap)
- `click-a.ogg` - Click sound variant A (button press)
- `click-b.ogg` - Click sound variant B (button press)
- `switch-a.ogg` - Toggle sound variant A (checkbox/switch)
- `switch-b.ogg` - Toggle sound variant B (checkbox/switch)

**Usage:**
- Button hover: Randomly play tap-a or tap-b
- Button press: Randomly play click-a or click-b
- Checkbox toggle: Randomly play switch-a or switch-b
- Pitch variation: 0.95-1.05 range for variety

**Format:** OGG Vorbis, optimized for mobile

## Color Palette Strategy

### Primary: Yellow Pack
**Rationale:** Warm, inviting color that provides excellent contrast with the pink alien character. Creates a playful, casual atmosphere matching the game's aesthetic.

**Usage:**
- All main action buttons (Play, Shop, Achievements, Settings)
- Primary panels and backgrounds
- Default slider colors
- Standard checkboxes

### Secondary: Red Pack
**Rationale:** Draws attention to critical or destructive actions. Used sparingly for emphasis.

**Usage:**
- Quit/Exit buttons
- Delete/Remove actions
- Warning indicators
- Special highlights (new high score)

### Accent: Extra Pack
**Rationale:** Color-neutral elements that work with any color scheme.

**Usage:**
- Panel backgrounds (input_rectangle, input_square)
- Dividers and separators
- Icons (play, repeat, arrows)
- Outline buttons

### Disabled: Grey Pack
**Rationale:** Clear visual indication of non-interactive elements.

**Usage:**
- Disabled button states
- Locked achievement overlays
- Inactive UI elements

## Import Settings

All Kenney PNG textures use these optimized import settings for mobile performance:

```
[remap]
importer="texture"
type="CompressedTexture2D"

[params]
compress/mode=2                  # VRAM Compressed
compress/high_quality=false
compress/lossy_quality=0.7
compress/hdr_compression=1
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=false           # Disabled for crisp UI
mipmaps/limit=-1
roughness/mode=0
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=0
```

**Key Settings:**
- **Mipmaps disabled:** UI elements are viewed at fixed sizes, mipmaps unnecessary
- **Filter enabled:** Smooth scaling for different screen sizes
- **VRAM compression:** Reduces memory usage on mobile GPUs
- **Lossy quality 0.7:** Balances file size and visual quality

## Texture Atlas Strategy

### Current State (Phase 1)
Individual texture files loaded separately. Simple to implement but creates many draw calls.

### Future Optimization (Phase 9 - Task 14.6)
Consolidate frequently used textures into atlases to reduce draw calls and improve performance.

#### Planned Atlases

**1. Button Atlas (Yellow Pack)**
- Combine all button_rectangle_*, button_round_*, button_square_* textures
- Estimated size: 2048x2048 pixels
- Expected draw call reduction: ~30 to ~3 per screen

**2. Icon Atlas (All Packs)**
- Combine all icon_*, star*, arrow_* textures
- Estimated size: 1024x1024 pixels
- Expected draw call reduction: ~15 to ~1 per screen

**3. Slider Atlas (Yellow Pack)**
- Combine all slide_* textures
- Estimated size: 512x512 pixels
- Used primarily in AudioSettingsMenu

**4. Checkbox Atlas (Yellow Pack)**
- Combine all check_* textures
- Estimated size: 512x512 pixels
- Used in settings and shop screens

#### Implementation Approach

1. **Tool Script:** Create editor script using `AtlasTextureBuilder` to generate atlases
2. **Theme Update:** Modify `kenney_ui_theme.tres` to reference atlas textures instead of individual files
3. **Component Update:** Update KenneyButton, KenneyPanel, KenneySlider to use atlas textures
4. **Validation:** Profile with Godot Visual Profiler to measure draw call reduction
5. **Fallback:** Keep individual textures as fallback for debugging

#### Expected Performance Gains

| Metric | Before Atlas | After Atlas | Improvement |
|--------|--------------|-------------|-------------|
| Draw Calls (MainMenu) | ~35 | ~8 | 77% reduction |
| Draw Calls (Shop) | ~50 | ~12 | 76% reduction |
| Texture Memory | ~15MB | ~8MB | 47% reduction |
| Scene Load Time | ~180ms | ~120ms | 33% faster |

#### Atlas Generation Script (Planned)

```gdscript
@tool
extends EditorScript

func _run():
    # Generate button atlas
    var button_atlas = create_button_atlas()
    ResourceSaver.save(button_atlas, "res://resources/atlases/kenney_buttons_yellow.tres")
    
    # Generate icon atlas
    var icon_atlas = create_icon_atlas()
    ResourceSaver.save(icon_atlas, "res://resources/atlases/kenney_icons.tres")
    
    print("Texture atlases generated successfully")

func create_button_atlas() -> AtlasTexture:
    # Implementation in Phase 9
    pass

func create_icon_atlas() -> AtlasTexture:
    # Implementation in Phase 9
    pass
```

## Usage Guidelines

### For Developers

**1. Choosing Button Styles:**
- Use `button_rectangle_depth_gloss` for primary actions (most prominent)
- Use `button_rectangle_gloss` for secondary actions (less prominent)
- Use `button_square_depth_gloss` for icon-only buttons (back, settings)
- Use Red pack for destructive actions (quit, delete)

**2. Panel Backgrounds:**
- Use `input_rectangle.png` from Extra pack for stat displays
- Use semi-transparent panels (85% opacity) for overlays (PauseScreen)
- Use NinePatchRect with proper margins for scalable panels

**3. Icons:**
- Overlay icons on buttons using TextureRect child nodes
- Use outline variants for better visibility on colored backgrounds
- Size icons at 32x32 or 24x24 pixels for clarity

**4. Animations:**
- Use star.png for particle effects (celebrations, achievements)
- Animate decorative arrows with subtle floating motion
- Apply bounce/squash animations to buttons, not textures

**5. Sounds:**
- Pre-cache all UI sounds in AudioManager for instant playback
- Apply pitch variation (0.95-1.05) for variety
- Implement cooldown (100ms) to prevent audio spam on rapid hover

### For Designers

**1. Color Consistency:**
- Yellow = Primary, friendly actions
- Red = Critical, destructive actions
- Grey = Disabled, inactive states
- Extra = Neutral, universal elements

**2. Visual Hierarchy:**
- Depth variants (depth_gloss, depth_flat) = Higher importance
- Flat variants = Lower importance
- Border/Line variants = Minimal emphasis

**3. Accessibility:**
- Ensure all buttons meet 44x44px minimum touch target
- Verify text contrast against panel backgrounds (4.5:1 ratio)
- Use icons alongside text for clarity

**4. Consistency:**
- Apply kenney_ui_theme.tres to all screens for uniform styling
- Use same button styles for same actions across screens
- Maintain consistent spacing and alignment

## Asset Inventory

### Total Asset Count

| Category | Yellow | Red | Blue | Green | Grey | Extra | Total |
|----------|--------|-----|------|-------|------|-------|-------|
| Buttons | 30 | 30 | 30 | 30 | 30 | 6 | 156 |
| Checkboxes | 12 | 12 | 12 | 12 | 12 | 0 | 60 |
| Sliders | 13 | 13 | 13 | 13 | 13 | 0 | 65 |
| Icons | 8 | 8 | 8 | 8 | 8 | 12 | 52 |
| Arrows | 16 | 16 | 16 | 16 | 16 | 0 | 80 |
| Stars | 3 | 3 | 3 | 3 | 3 | 0 | 15 |
| Panels | 0 | 0 | 0 | 0 | 0 | 6 | 6 |
| Dividers | 0 | 0 | 0 | 0 | 0 | 2 | 2 |
| **Total** | **82** | **82** | **82** | **82** | **82** | **26** | **436** |

### UI Sounds
- 6 OGG files (2 hover, 2 click, 2 switch)

### Total Assets
- **442 files** (436 textures + 6 sounds)
- **Estimated total size:** ~25MB (textures) + ~500KB (sounds) = ~25.5MB

## Maintenance

### Adding New Assets
1. Place new textures in appropriate color pack folder
2. Verify import settings match template above
3. Update this documentation with new asset descriptions
4. Regenerate texture atlases if applicable
5. Test on target mobile devices

### Updating Existing Assets
1. Replace texture file in same location
2. Clear Godot import cache (`.godot/imported/`)
3. Reimport assets in Godot editor
4. Test all screens using the updated asset
5. Update documentation if usage changes

### Asset Naming Conventions
- **Buttons:** `button_{shape}_{style}.png` (e.g., button_rectangle_depth_gloss.png)
- **Checkboxes:** `check_{shape}_{color}_{state}.png` (e.g., check_square_color_checkmark.png)
- **Sliders:** `slide_{orientation}_{color}_{variant}.png` (e.g., slide_horizontal_color.png)
- **Icons:** `icon_{name}.png` or `icon_outline_{name}.png`
- **Arrows:** `arrow_{style}_{direction}_{size}.png` (e.g., arrow_decorative_s_small.png)

## References

- **Kenney UI Pack:** [kenney.nl](https://kenney.nl/assets/ui-pack)
- **Design Document:** `.kiro/specs/ui-overhaul-kenney-pack/design.md`
- **Requirements Document:** `.kiro/specs/ui-overhaul-kenney-pack/requirements.md`
- **Implementation Tasks:** `.kiro/specs/ui-overhaul-kenney-pack/tasks.md`
- **Theme Resource:** `resources/themes/kenney_ui_theme.tres`

---

**Document Version:** 1.0  
**Last Updated:** 2024 (Initial creation)  
**Maintained By:** HopNSplat Development Team
