# 🔄 Game Reset Functionality

## Overview

The HopNSplat game now includes a comprehensive reset functionality that allows players to completely reset their game progress and start fresh. This feature is accessible through the Game Settings menu.

## Features

### What Gets Reset

When a player confirms the reset action, the following data is completely cleared:

#### 1. **Game Progress**
- ✅ High scores (best score reset to 0)
- ✅ Current session progress
- ✅ All gameplay statistics

#### 2. **Currency & Purchases**
- ✅ Total coins reset to 0
- ✅ All shop purchases removed
- ✅ Player skins reset to default
- ✅ Boost upgrades removed
- ✅ Power-up purchases removed

#### 3. **Achievements**
- ✅ All achievement progress reset
- ✅ Unlocked achievements cleared
- ✅ Achievement rewards removed

#### 4. **Settings**
- ✅ Audio settings reset to defaults
  - Music volume: 70%
  - SFX volume: 80%
  - Music enabled: Yes
  - SFX enabled: Yes

## User Interface

### Access Points

The reset functionality can be accessed from:

1. **Main Menu** → Settings Button → Reset Section
2. **In-Game Pause Menu** → Settings Button → Reset Section

### Reset Flow

```
User clicks "Settings" 
    ↓
Game Settings Menu opens
    ↓
User scrolls to "Reset Game Data" section
    ↓
User clicks "⚠️ RESET ALL DATA" button
    ↓
Confirmation dialog appears with warning
    ↓
User confirms "Yes, Reset Everything"
    ↓
All data is reset
    ↓
Success feedback shown: "✓ Game Reset Complete!"
    ↓
Settings menu updates to show default values
```

### Safety Features

#### Confirmation Dialog
- **Title**: "⚠️ Confirm Reset"
- **Warning Message**: Clear explanation of what will be deleted
- **Buttons**: 
  - "Yes, Reset Everything" (destructive action)
  - "Cancel" (safe option)

#### Visual Warnings
- Red text color on reset button
- Warning emoji (⚠️) to indicate danger
- Detailed list of what will be deleted
- Emphasis that action CANNOT be undone

## Technical Implementation

### Files Affected

The reset functionality modifies the following save files:

1. **`user://hopnsplat_save.dat`**
   - Game progress and currency
   - Shop purchases
   - High scores

2. **`user://achievements.dat`**
   - Achievement progress
   - Unlocked achievements list

3. **`user://audio_settings.dat`**
   - Audio volume levels
   - Audio enable/disable states

### Default Values

```gdscript
# Save Data Defaults
{
    "total_currency": 0,
    "highest_score": 0,
    "purchased_items": {}
}

# Achievement Defaults
{
    "progress": {},
    "unlocked": []
}

# Audio Settings Defaults
{
    "master_volume": 1.0,
    "music_volume": 0.7,
    "sfx_volume": 0.8,
    "music_enabled": true,
    "sfx_enabled": true
}
```

## User Experience Considerations

### Why Include Reset?

1. **Fresh Start**: Players may want to experience the game from the beginning
2. **Testing**: Developers and testers need to reset progress
3. **Multiple Users**: Shared devices benefit from reset functionality
4. **Mistakes**: Players who made unwanted purchases can start over
5. **Achievements**: Players who want to re-earn achievements

### Design Decisions

#### Placement
- Located in Settings menu (not prominently displayed)
- Requires multiple clicks to access
- Not easily triggered by accident

#### Confirmation
- Two-step process (button + dialog)
- Clear warning message
- Explicit confirmation required
- No default action (user must click)

#### Feedback
- Visual confirmation of reset completion
- Settings UI updates immediately
- Success message with checkmark
- Fade-out animation for polish

#### Irreversibility
- Clearly communicated that action cannot be undone
- No "undo" or "restore" functionality
- Encourages careful consideration

## Code Structure

### Main Components

1. **`scripts/game_settings_menu.gd`**
   - Main settings menu controller
   - Reset button handler
   - Confirmation dialog management
   - Data reset orchestration

2. **`scenes/GameSettingsMenu.tscn`**
   - Settings UI layout
   - Audio controls
   - Reset section
   - Confirmation dialog

3. **Integration Points**
   - Main menu settings button
   - Pause screen settings button
   - Main game settings handler

### Key Functions

```gdscript
# Reset orchestration
func _on_reset_confirmed()

# Individual reset functions
func reset_save_data()
func reset_achievements()
func reset_audio_settings()

# User feedback
func show_reset_feedback()
```

## Testing Checklist

- [ ] Reset button is visible in settings menu
- [ ] Confirmation dialog appears when reset is clicked
- [ ] Cancel button works (no reset occurs)
- [ ] Confirm button resets all data
- [ ] High score resets to 0
- [ ] Coins reset to 0
- [ ] Shop purchases are removed
- [ ] Achievements are cleared
- [ ] Audio settings reset to defaults
- [ ] Success message appears
- [ ] Settings UI updates correctly
- [ ] Game can be played normally after reset
- [ ] Reset works from main menu
- [ ] Reset works from pause screen

## Future Enhancements

Potential improvements for the reset functionality:

1. **Selective Reset**
   - Option to reset only specific data (e.g., just achievements)
   - Keep audio settings but reset progress
   - Reset purchases but keep achievements

2. **Backup Before Reset**
   - Create automatic backup before reset
   - Allow restore from backup within 24 hours
   - Export/import save data

3. **Cloud Save Integration**
   - Sync progress across devices
   - Restore from cloud backup
   - Prevent accidental data loss

4. **Reset Statistics**
   - Track number of resets
   - Show "total lifetime" statistics
   - Achievement for resetting game

## Accessibility

The reset functionality follows accessibility best practices:

- ✅ Clear, descriptive button text
- ✅ High contrast warning colors
- ✅ Keyboard navigation support
- ✅ Screen reader friendly labels
- ✅ Large, easy-to-tap buttons (mobile)
- ✅ Clear visual hierarchy

## Localization

The reset functionality is ready for localization:

- All text strings are in English
- No hardcoded text in scene files
- Ready for translation system integration
- Emoji used for universal understanding

---

**Document Created**: 2024
**Last Updated**: 2024
**Version**: 1.0
