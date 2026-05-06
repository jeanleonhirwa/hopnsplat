# AchievementCard Component

## Overview

The `AchievementCard` is a reusable UI component for displaying achievement information in the HopNSplat game. It supports locked/unlocked states, progress tracking for progressive achievements, and includes visual feedback animations.

## Features

- **Locked/Unlocked States**: Visual distinction between locked and unlocked achievements
- **Progressive Achievements**: Optional progress bar for achievements with multiple steps
- **Icon Display**: Custom achievement icons with background styling
- **Status Indicator**: Star icon (filled for unlocked, outline for locked)
- **Unlock Animation**: Celebratory animation sequence when achievement is unlocked
- **Particle Effects**: Star particle burst on unlock

## File Structure

- **Scene**: `scenes/components/AchievementCard.tscn`
- **Script**: `scripts/components/achievement_card.gd`
- **Test Scene**: `scenes/test_achievement_card.tscn`
- **Test Script**: `scripts/test_achievement_card.gd`

## Component Structure

```
AchievementCard (KenneyPanel)
├── MainContainer (HBoxContainer)
│   ├── IconContainer (CenterContainer)
│   │   ├── IconBackground (TextureRect) - button_square_depth_gloss.png
│   │   └── AchievementIcon (TextureRect) - Custom achievement icon
│   ├── InfoContainer (VBoxContainer)
│   │   ├── TitleLabel (Label)
│   │   ├── DescriptionLabel (Label)
│   │   └── ProgressContainer (HBoxContainer) [visible only for progressive achievements]
│   │       ├── ProgressBar (HSlider)
│   │       └── ProgressLabel (Label) - "X/Y" format
│   └── StatusContainer (CenterContainer)
│       └── StatusStar (TextureRect) - star.png or star_outline.png
└── LockedOverlay (ColorRect) - Semi-transparent grey [hidden when unlocked]
```

## Exported Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `achievement_id` | String | "" | Unique identifier for the achievement |
| `achievement_title` | String | "Achievement Title" | Display title |
| `achievement_description` | String | "Achievement description goes here" | Description text |
| `achievement_icon` | Texture2D | null | Custom icon (defaults to star if null) |
| `is_locked` | bool | true | Whether achievement is locked |
| `is_progressive` | bool | false | Whether achievement tracks progress |
| `current_progress` | int | 0 | Current progress value |
| `max_progress` | int | 100 | Maximum progress value |

## Public Methods

### `set_achievement_data(id, title, description, icon, progressive, max_prog)`
Set all achievement data at once.

**Parameters:**
- `id` (String): Achievement identifier
- `title` (String): Achievement title
- `description` (String): Achievement description
- `icon` (Texture2D): Achievement icon texture
- `progressive` (bool): Whether this is a progressive achievement
- `max_prog` (int): Maximum progress value for progressive achievements

**Example:**
```gdscript
var card = AchievementCard.new()
card.set_achievement_data(
    "jump_master",
    "Jump Master",
    "Complete 100 jumps",
    preload("res://assets/icons/jump_icon.png"),
    true,
    100
)
```

### `set_locked(locked)`
Set the locked state of the achievement.

**Parameters:**
- `locked` (bool): True to lock, false to unlock

**Example:**
```gdscript
card.set_locked(false)  # Unlock the achievement
```

### `set_progress(progress)`
Update the progress for progressive achievements. Automatically unlocks when progress reaches max_progress.

**Parameters:**
- `progress` (int): New progress value (clamped to 0-max_progress)

**Example:**
```gdscript
card.set_progress(50)  # Set progress to 50
```

### `unlock_achievement()`
Unlock the achievement and play the unlock animation sequence.

**Example:**
```gdscript
card.unlock_achievement()
```

### `play_unlock_animation()`
Play the unlock animation sequence (called automatically by `unlock_achievement()`).

**Animation Sequence:**
1. Card shakes (0.2s)
2. Overlay fades out (0.3s)
3. Icon saturates (0.3s)
4. Star outline morphs to filled with scale pulse (0.4s)
5. Particle burst from card (0.5s)
6. Glow effect fades in and out (1.0s)

## Signals

### `achievement_unlocked(achievement_id: String)`
Emitted when the achievement is unlocked.

**Example:**
```gdscript
card.achievement_unlocked.connect(_on_achievement_unlocked)

func _on_achievement_unlocked(achievement_id: String) -> void:
    print("Achievement unlocked: ", achievement_id)
```

## Visual States

### Locked State
- Grey semi-transparent overlay (60% opacity)
- Star outline icon
- Desaturated achievement icon (50% saturation)

### Unlocked State
- No overlay
- Filled star icon
- Full color achievement icon

### Progressive Achievement
- Shows progress bar with current/max label
- Progress bar animates smoothly when updated
- Automatically unlocks when progress reaches maximum

## Usage Example

### Basic Achievement (One-time unlock)
```gdscript
var achievement = AchievementCard.new()
achievement.set_achievement_data(
    "first_jump",
    "First Jump",
    "Complete your first jump",
    preload("res://assets/icons/jump.png"),
    false,  # Not progressive
    0
)
achievement.set_locked(true)
add_child(achievement)

# Later, when player completes the achievement
achievement.unlock_achievement()
```

### Progressive Achievement
```gdscript
var achievement = AchievementCard.new()
achievement.set_achievement_data(
    "coin_collector",
    "Coin Collector",
    "Collect 1000 coins",
    preload("res://assets/icons/coin.png"),
    true,  # Progressive
    1000
)
achievement.set_locked(true)
achievement.set_progress(0)
add_child(achievement)

# Update progress as player collects coins
achievement.set_progress(350)  # 350/1000
achievement.set_progress(750)  # 750/1000
achievement.set_progress(1000) # 1000/1000 - automatically unlocks!
```

## Testing

Run the test scene to see the component in action:
1. Open `scenes/test_achievement_card.tscn` in Godot
2. Run the scene (F6)
3. Click "Unlock First" to see the unlock animation
4. Click "Add Progress" to increment the progressive achievement

## Assets Used

- **Panel Background**: `assets/ui_packs/Extra/Default/input_rectangle.png`
- **Icon Background**: `assets/ui_packs/Yellow/Default/button_square_depth_gloss.png`
- **Star (Unlocked)**: `assets/ui_packs/Yellow/Default/star.png`
- **Star Outline (Locked)**: `assets/ui_packs/Yellow/Default/star_outline.png`
- **Default Icon**: `assets/ui_packs/Yellow/Default/star.png` (if no custom icon provided)

## Requirements Satisfied

This component satisfies the following requirements from the spec:

- **Requirement 9.1**: Achievement cards with Kenney textures
- **Requirement 9.2**: Star icons for completion status (filled/outline)
- **Requirement 9.4**: Locked achievements with greyed or outline variants

## Notes

- The component extends `KenneyPanel` for consistent styling
- Progress bar uses `HSlider` as a base (can be replaced with `KenneySlider` when available)
- Unlock animation includes particle effects and sound feedback
- All animations use tweens for smooth performance
- Component is fully self-contained and reusable

## Future Enhancements

- Replace HSlider with KenneySlider component when Task 12.1 is completed
- Add more particle effect variations
- Support for different achievement tiers (bronze, silver, gold)
- Add tooltip on hover with detailed statistics
