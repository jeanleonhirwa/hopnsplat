# 🎮 Reset Feature Integration Guide

## Quick Start

The reset functionality has been fully integrated into HopNSplat. Here's how it works:

## User Journey

### From Main Menu

```
Main Menu
    ↓
[Settings Button] ⚙️
    ↓
Game Settings Menu
    ├─ 🔊 Audio Settings
    │   ├─ Music Volume Slider
    │   ├─ Music Toggle
    │   ├─ SFX Volume Slider
    │   └─ SFX Toggle
    │
    └─ 🔄 Reset Game Data
        ├─ Description of what gets reset
        └─ [⚠️ RESET ALL DATA Button]
            ↓
        Confirmation Dialog
            ├─ Warning message
            ├─ [Yes, Reset Everything]
            └─ [Cancel]
                ↓
        ✓ Game Reset Complete!
```

### From In-Game Pause Menu

```
Playing Game
    ↓
[Pause Button] ⏸️
    ↓
Pause Screen
    ├─ [Resume]
    ├─ [Settings] ⚙️ ← NEW!
    ├─ [Restart]
    └─ [Menu]
        ↓
Game Settings Menu
    (same as above)
```

## Files Created

### New Scripts
1. **`scripts/game_settings_menu.gd`**
   - Comprehensive settings controller
   - Handles audio settings
   - Manages reset functionality
   - Shows confirmation dialogs
   - Provides user feedback

### New Scenes
2. **`scenes/GameSettingsMenu.tscn`**
   - Complete settings UI
   - Audio controls section
   - Reset section with warnings
   - Confirmation dialog
   - Responsive layout for mobile

### Documentation
3. **`docs/reset-functionality.md`**
   - Complete feature documentation
   - Technical implementation details
   - User experience guidelines
   - Testing checklist

4. **`docs/reset-feature-integration.md`** (this file)
   - Integration guide
   - Quick reference
   - File structure

## Modified Files

### Updated Scripts
1. **`scripts/main_menu.gd`**
   - Updated `show_settings_panel()` to use new GameSettingsMenu
   - Maintains backward compatibility with old AudioSettingsMenu

2. **`scripts/pause_screen.gd`**
   - Added settings button reference
   - Added `open_settings` signal
   - Added `_on_settings_pressed()` handler
   - Updated button styling to include settings button

3. **`scripts/main.gd`**
   - Added `_on_open_settings()` handler
   - Dynamically loads GameSettingsMenu when needed
   - Connects pause screen settings signal

## UI Layout

### Game Settings Menu Structure

```
GameSettingsMenu (Control)
├─ Background (ColorRect - semi-transparent black)
├─ Panel (centered)
│   └─ VBoxContainer
│       ├─ TitleLabel: "⚙️ GAME SETTINGS"
│       ├─ HSeparator
│       │
│       ├─ AudioSection (VBoxContainer)
│       │   ├─ AudioTitle: "🔊 Audio Settings"
│       │   ├─ MusicContainer
│       │   │   ├─ MusicLabel: "Music Volume: 70%"
│       │   │   ├─ MusicSlider (0-100%)
│       │   │   └─ MusicToggle: "Enable Music"
│       │   └─ SFXContainer
│       │       ├─ SFXLabel: "SFX Volume: 80%"
│       │       ├─ SFXSlider (0-100%)
│       │       └─ SFXToggle: "Enable SFX"
│       │
│       ├─ HSeparator
│       │
│       ├─ ResetSection (VBoxContainer)
│       │   ├─ ResetTitle: "🔄 Reset Game Data"
│       │   ├─ ResetDescription: (multi-line warning)
│       │   └─ ResetButton: "⚠️ RESET ALL DATA"
│       │
│       ├─ HSeparator
│       │
│       └─ ButtonContainer
│           └─ CloseButton: "CLOSE"
│
└─ ConfirmationDialog
    ├─ Title: "⚠️ Confirm Reset"
    ├─ Message: (detailed warning)
    ├─ OkButton: "Yes, Reset Everything"
    └─ CancelButton: "Cancel"
```

## Integration Points

### 1. Main Menu Integration

**File**: `scripts/main_menu.gd`

```gdscript
func show_settings_panel():
    """Show game settings menu"""
    # Try new comprehensive settings first
    var game_settings = $GameSettingsMenu
    if game_settings:
        game_settings.show_settings()
        return
    
    # Fallback to audio settings
    var audio_settings = $AudioSettingsMenu
    if audio_settings:
        audio_settings.visible = true
```

### 2. Pause Screen Integration

**File**: `scripts/pause_screen.gd`

```gdscript
# New signal
signal open_settings

# New button reference
@onready var settings_button = $PausePanel/.../SettingsButton

# New handler
func _on_settings_pressed():
    """Settings button pressed"""
    open_settings.emit()
```

### 3. Main Game Integration

**File**: `scripts/main.gd`

```gdscript
func _on_open_settings():
    """Handle settings button from pause screen"""
    var game_settings = ui_layer.get_node_or_null("GameSettingsMenu")
    if not game_settings:
        # Create settings menu dynamically
        var settings_scene = load("res://scenes/GameSettingsMenu.tscn")
        if settings_scene:
            game_settings = settings_scene.instantiate()
            ui_layer.add_child(game_settings)
    
    if game_settings:
        game_settings.show_settings()
```

## Reset Process Flow

### Step-by-Step Execution

1. **User Clicks Reset Button**
   ```gdscript
   func _on_reset_button_pressed():
       if confirmation_dialog:
           confirmation_dialog.popup_centered()
   ```

2. **Confirmation Dialog Shows**
   - Displays warning message
   - User must explicitly confirm

3. **User Confirms Reset**
   ```gdscript
   func _on_reset_confirmed():
       reset_save_data()
       reset_achievements()
       reset_audio_settings()
       load_current_settings()
       show_reset_feedback()
   ```

4. **Data Reset Sequence**
   ```gdscript
   # 1. Reset save data
   {
       "total_currency": 0,
       "highest_score": 0,
       "purchased_items": {}
   }
   
   # 2. Reset achievements
   {
       "progress": {},
       "unlocked": []
   }
   
   # 3. Reset audio settings
   {
       "master_volume": 1.0,
       "music_volume": 0.7,
       "sfx_volume": 0.8,
       "music_enabled": true,
       "sfx_enabled": true
   }
   ```

5. **UI Updates**
   - Settings sliders reset to defaults
   - Success message appears
   - Fade-out animation plays

## Testing the Feature

### Manual Testing Steps

1. **Access from Main Menu**
   - [ ] Launch game
   - [ ] Click Settings button
   - [ ] Verify GameSettingsMenu opens
   - [ ] Verify audio controls work
   - [ ] Click Reset button
   - [ ] Verify confirmation dialog appears
   - [ ] Click Cancel - verify nothing resets
   - [ ] Click Reset again
   - [ ] Click Confirm - verify data resets
   - [ ] Verify success message appears

2. **Access from Pause Screen**
   - [ ] Start a game
   - [ ] Earn some coins and score
   - [ ] Pause the game
   - [ ] Click Settings button
   - [ ] Verify GameSettingsMenu opens
   - [ ] Perform reset
   - [ ] Resume game
   - [ ] Verify score/coins are reset

3. **Data Persistence**
   - [ ] Earn coins and high score
   - [ ] Buy shop items
   - [ ] Unlock achievements
   - [ ] Perform reset
   - [ ] Verify all data is cleared
   - [ ] Close and reopen game
   - [ ] Verify data remains reset

## Mobile Considerations

### Touch-Friendly Design
- Large buttons (minimum 40px height)
- Adequate spacing between elements
- Clear visual feedback on tap
- Confirmation dialog prevents accidents

### Screen Sizes
- Responsive layout adapts to different screens
- Centered panel works on all aspect ratios
- Scrollable content if needed
- Portrait orientation optimized

## Backward Compatibility

The implementation maintains backward compatibility:

- Old `AudioSettingsMenu` still works if present
- Fallback logic in `show_settings_panel()`
- No breaking changes to existing code
- Gradual migration path

## Future Enhancements

### Planned Improvements

1. **Selective Reset Options**
   ```
   Reset Options:
   [ ] High Scores
   [ ] Coins & Purchases
   [ ] Achievements
   [ ] Audio Settings
   [Reset Selected]
   ```

2. **Backup System**
   ```
   Before Reset:
   - Create automatic backup
   - Store in separate file
   - Allow restore within 24h
   ```

3. **Statistics Tracking**
   ```
   Lifetime Stats:
   - Total games played: 1,234
   - Total coins earned: 45,678
   - Times reset: 2
   ```

## Troubleshooting

### Common Issues

**Issue**: Settings button doesn't appear in pause screen
- **Solution**: Update PauseScreen.tscn to include SettingsButton node

**Issue**: Reset doesn't clear all data
- **Solution**: Check file paths in reset functions match save file locations

**Issue**: Confirmation dialog doesn't show
- **Solution**: Verify ConfirmationDialog node exists in GameSettingsMenu.tscn

**Issue**: Success message doesn't appear
- **Solution**: Check `show_reset_feedback()` function is called after reset

## Summary

The reset functionality is now fully integrated into HopNSplat with:

✅ Comprehensive settings menu  
✅ Audio controls  
✅ Complete data reset  
✅ Safety confirmations  
✅ User feedback  
✅ Mobile-friendly UI  
✅ Backward compatibility  
✅ Full documentation  

The feature fits naturally into the game's existing UI and provides a safe, user-friendly way for players to reset their progress.

---

**Integration Complete**: 2024
**Version**: 1.0
**Status**: Ready for Testing
