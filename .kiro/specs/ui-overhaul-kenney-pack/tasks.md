# Implementation Plan: UI Overhaul with Kenney Pack

## Overview

This implementation plan breaks down the UI overhaul into actionable coding tasks following the 10-phase roadmap from the design document. The overhaul transforms HopNSplat's basic blue StyleBoxFlat buttons into a playful, engaging UI using Kenney UI pack assets with animations, sound feedback, and visual polish.

**Implementation Language**: GDScript (Godot 4.6)

**Target Screens**: MainMenu, Shop, PauseScreen, GameOver, Achievements, AudioSettingsMenu

**Key Technologies**: TextureButton, NinePatchRect, Tween animations, AudioManager integration

## Tasks

- [x] 1. Phase 1: Foundation Setup - Asset Integration and Core Components
  - [x] 1.1 Verify and configure Kenney asset import settings
    - Verify all PNG textures in `assets/ui_packs/` have correct import settings (mipmaps off, filter on, VRAM compression mode 2)
    - Create import preset for Kenney UI textures if needed
    - Document any missing or incorrectly imported assets
    - _Requirements: 1.1, 1.4_

  - [x] 1.2 Create Kenney UI Theme resource
    - Create `resources/themes/kenney_ui_theme.tres` file
    - Configure StyleBoxTexture resources for Yellow pack button textures (rectangle_depth_gloss, round_depth_gloss, square_depth_gloss)
    - Set up font configurations (arial.ttf, sizes, colors)
    - Add panel and slider style configurations
    - _Requirements: 1.5, 12.1, 12.2, 12.3_

  - [x] 1.3 Implement KenneyButton component
    - Create `scripts/components/kenney_button.gd` with class_name KenneyButton extending TextureButton
    - Implement ButtonStyle and ColorPack enums
    - Add @export properties for configuration (button_style, color_pack, icon_texture, button_text, enable_idle_wobble)
    - Implement texture loading and state mapping (normal, hover, pressed, disabled)
    - Add node structure with optional Icon (TextureRect) and Label children
    - _Requirements: 2.1, 2.2, 2.3, 2.6_

  - [x] 1.4 Implement KenneyPanel component
    - Create `scripts/components/kenney_panel.gd` with class_name KenneyPanel extending NinePatchRect
    - Implement PanelStyle and ColorPack enums
    - Add @export properties for panel_style, color_pack, semi_transparent
    - Implement texture loading for panel backgrounds (rectangle_depth, square_depth)
    - Add set_transparency() method for overlay panels
    - _Requirements: 2.1, 7.2_

  - [x] 1.5 Create asset organization documentation
    - Document the asset folder structure in `docs/asset_organization.md`
    - List all Kenney texture files being used by category (buttons, panels, sliders, icons)
    - Document texture atlas strategy for future optimization
    - _Requirements: 1.3_

- [-] 2. Phase 2: Animation System - UI Juice Effects
  - [x] 2.1 Create UIAnimationManager autoload singleton
    - Create `scripts/autoload/ui_animation_manager.gd` extending Node
    - Add to project.godot autoload configuration
    - Implement active_tweens array and MAX_CONCURRENT_TWEENS constant (10)
    - Implement register_tween(), cleanup_finished_tweens(), stop_all_tweens() methods
    - _Requirements: 3.5, 13.1_

  - [x] 2.2 Implement core juice effect methods
    - Implement bounce_in(node, duration) - scale from 1.0 to 1.1 with EASE_OUT
    - Implement squash(node, duration) - scale to 0.95 with EASE_IN
    - Implement pop_out(node, duration) - scale with TRANS_ELASTIC easing
    - Implement wobble(node, loop) - subtle rotation animation for idle state
    - All methods should return Tween and call register_tween()
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

  - [x] 2.3 Implement additional animation effects
    - Implement slide_in(node, direction, duration) for panel entrances
    - Implement fade_in(node, duration) for screen transitions
    - Implement count_up(label, from, to, duration) for currency animations
    - _Requirements: 15.2, 15.4_

  - [x] 2.4 Integrate animations into KenneyButton
    - Add AnimationTween node reference to KenneyButton
    - Implement play_hover_animation() calling UIAnimationManager.bounce_in()
    - Implement play_press_animation() calling UIAnimationManager.squash()
    - Implement play_idle_wobble() for important buttons
    - Connect mouse_entered, button_down, button_up signals to animation methods
    - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [x] 3. Phase 3: Sound Integration - UI Audio Feedback
  - [x] 3.1 Extend AudioManager with UI sound support
    - Add ui_sounds_cache Dictionary to AudioManager
    - Add ui_sound_pitch_variance float property (0.05)
    - Pre-cache all UI sounds in _ready(): tap-a.ogg, tap-b.ogg, click-a.ogg, click-b.ogg, switch-a.ogg, switch-b.ogg
    - _Requirements: 4.5, 13.3_

  - [x] 3.2 Implement UI sound playback methods
    - Implement play_ui_hover() - randomly plays tap-a or tap-b
    - Implement play_ui_click() - randomly plays click-a or click-b
    - Implement play_ui_switch() - randomly plays switch-a or switch-b
    - Implement _play_ui_sound(sound, pitch_variance) helper method
    - Implement _get_random_pitch() returning value between 0.95 and 1.05
    - _Requirements: 4.1, 4.2, 4.3, 4.4_

  - [x] 3.3 Integrate sounds into KenneyButton
    - Add hover_sound and click_sound @export properties to KenneyButton
    - Add last_hover_time tracking and HOVER_SOUND_COOLDOWN constant (0.1s)
    - Call AudioManager.play_ui_hover() in mouse_entered with cooldown check
    - Call AudioManager.play_ui_click() in button_down signal
    - _Requirements: 4.1, 4.2_

- [x] 4. Checkpoint - Foundation Validation
  - Ensure all tests pass, verify KenneyButton and KenneyPanel components work correctly, ask the user if questions arise.

- [x] 5. Phase 4: MainMenu Screen Overhaul
  - [x] 5.1 Replace MainMenu buttons with KenneyButton instances
    - Replace PlayButton with KenneyButton (RECTANGLE_DEPTH_GLOSS, Yellow, 300x70px)
    - Replace ShopButton with KenneyButton (RECTANGLE_GLOSS, Yellow, 300x60px)
    - Replace AchievementsButton with KenneyButton (RECTANGLE_GLOSS, Yellow, 300x60px)
    - Replace SettingsButton with KenneyButton (RECTANGLE_GLOSS, Yellow, 300x60px)
    - Replace QuitButton with KenneyButton (RECTANGLE_GLOSS, Red, 300x60px)
    - Set appropriate icons for each button (rocket, cart, star, gear, cross)
    - Enable idle_wobble for PlayButton
    - _Requirements: 5.1, 5.5, 2.4_

  - [x] 5.2 Add decorative elements to MainMenu
    - Add BackgroundDecoration Control node
    - Add FloatingStar1 and FloatingStar2 TextureRect nodes with star.png texture
    - Add DecorativeArrow TextureRect with arrow_decorative_s.png
    - Implement floating animation for stars using UIAnimationManager
    - _Requirements: 5.2, 15.3_

  - [x] 5.3 Create stats panel with Kenney backgrounds
    - Wrap HighScoreLabel and CurrencyLabel in KenneyPanel (RECTANGLE_DEPTH, Yellow)
    - Add star icon TextureRect next to HighScoreLabel
    - Add coin icon TextureRect next to CurrencyLabel
    - _Requirements: 5.4_

  - [x] 5.4 Implement MainMenu stagger animation sequence
    - In main_menu.gd _ready(), implement animation timeline from design
    - Fade in background (0.3s)
    - Title drop with bounce (0.4s, starts at 0.1s)
    - Stats panel slide in (0.3s, starts at 0.3s)
    - Stagger button appearances (0.2s each, starting at 0.6s with 0.1s delays)
    - Start PlayButton wobble loop after stagger complete
    - _Requirements: 5.3_

- [ ] 6. Phase 5: Shop Screen Overhaul
  - [x] 6.1 Create ShopItemCard reusable component
    - Create `scenes/components/ShopItemCard.tscn` with KenneyPanel root
    - Add ItemIcon (TextureRect), ItemName (Label), ItemDescription (Label)
    - Add PricePanel (KenneyPanel) with CoinIcon and PriceLabel
    - Add PurchaseButton (KenneyButton, RECTANGLE_DEPTH_GLOSS)
    - Add EquippedCheckmark (TextureRect with icon_checkmark.png, hidden by default)
    - Create `scripts/components/shop_item_card.gd` with item data properties
    - _Requirements: 6.2_

  - [x] 6.2 Convert Shop.tscn header to use Kenney components
    - Replace BackButton with KenneyButton (SQUARE_DEPTH_GLOSS, arrow icon)
    - Wrap CurrencyLabel in KenneyPanel with coin icon
    - Apply kenney_ui_theme to Shop scene
    - _Requirements: 6.1, 6.4_

  - [x] 6.3 Style TabContainer with Kenney textures
    - Configure TabContainer to use Yellow button textures for tabs
    - Active tab: button_rectangle_depth_gloss.png
    - Inactive tab: button_rectangle_flat.png with 80% opacity
    - _Requirements: 6.1_

  - [x] 6.4 Implement tab switching animation
    - In shop.gd, connect TabContainer tab_changed signal
    - Implement slide-in animation (0.3s) when switching tabs
    - Use UIAnimationManager.slide_in() with direction from right
    - _Requirements: 6.3_

  - [x] 6.5 Implement purchase animation sequence
    - In ShopItemCard, implement _on_purchase_button_pressed()
    - Button press animation (0.1s)
    - Coin icon flies from item to header currency display (0.5s with arc motion)
    - Currency count-up animation (0.3s)
    - Checkmark appears with pop-out animation (0.2s)
    - Spawn particle burst at item location using star textures
    - _Requirements: 6.6_

  - [x] 6.6 Add particle system for purchase celebrations
    - Create CPUParticles2D or GPUParticles2D with star.png texture
    - Configure particle settings: 20-30 particles, 0.8s lifetime, explosiveness 1.0
    - Implement spawn_celebration_particles() method in shop.gd
    - Auto-cleanup particles after lifetime
    - _Requirements: 15.1_

- [ ] 7. Checkpoint - Shop and MainMenu Complete
  - Ensure all tests pass, verify MainMenu and Shop screens work correctly with animations and sounds, ask the user if questions arise.

- [ ] 8. Phase 6: PauseScreen Overhaul
  - [ ] 8.1 Convert PauseScreen.tscn to use Kenney components
    - Replace PausePanel with KenneyPanel (RECTANGLE_DEPTH, Yellow, 85% opacity)
    - Wrap ScoreLabel in KenneyPanel with star icon
    - Wrap CoinsLabel in KenneyPanel with coin icon
    - Add Divider TextureRect nodes with divider_edges.png
    - _Requirements: 7.1, 7.2, 7.4_

  - [x] 8.2 Replace PauseScreen buttons with KenneyButton
    - Replace ResumeButton with KenneyButton (RECTANGLE_DEPTH_GLOSS, Yellow, play icon)
    - Replace SettingsButton with KenneyButton (RECTANGLE_GLOSS, Yellow, gear icon)
    - Replace RestartButton with KenneyButton (RECTANGLE_GLOSS, Yellow, repeat icon)
    - Replace MenuButton with KenneyButton (RECTANGLE_GLOSS, Red, home icon)
    - All buttons 350x60px
    - _Requirements: 7.1, 7.5_

  - [ ] 8.3 Implement PauseScreen entrance animation
    - In pause_screen.gd _ready(), implement animation sequence
    - Background fades in (0.2s)
    - Panel zooms in with elastic easing (0.4s, scale from 0.5 to 1.0)
    - Content elements fade in sequentially (0.15s each, 0.05s delay)
    - _Requirements: 7.3_

- [ ] 9. Phase 6: GameOver Screen Overhaul
  - [~] 9.1 Convert GameOver.tscn to use Kenney components
    - Replace panel with KenneyPanel (RECTANGLE_DEPTH, Yellow)
    - Wrap FinalScoreLabel, CurrencyEarnedLabel, JumpsLabel, HighScoreLabel in KenneyPanel instances
    - Add appropriate icons (star, coin) to stat panels
    - _Requirements: 8.1_

  - [~] 9.2 Implement star rating system
    - Add StarRating HBoxContainer with 3 TextureRect nodes
    - Implement star rating logic: 1 star (score > 0), 2 stars (score > 50), 3 stars (score > 100)
    - Use star.png for filled, star_outline.png for empty
    - Animate stars filling in sequence with pop effect (0.2s each, 0.1s delay)
    - _Requirements: 8.2_

  - [~] 9.3 Replace GameOver buttons with KenneyButton
    - Replace ContinueButton with KenneyButton (RECTANGLE_DEPTH_GLOSS, Yellow, 350x80px, TV icon, idle wobble enabled)
    - Replace RestartButton with KenneyButton (RECTANGLE_DEPTH_GLOSS, Yellow, 350x60px, repeat icon)
    - Replace MenuButton with KenneyButton (RECTANGLE_GLOSS, Yellow, 350x60px, home icon)
    - _Requirements: 8.3_

  - [~] 9.4 Implement new high score celebration animation
    - In game_over.gd _ready(), detect if new high score achieved
    - Title flashes between colors (0.5s loop, 3 times)
    - Spawn particle burst from title using star textures
    - All stat panels bounce in sequence
    - Play celebration sound effect
    - _Requirements: 8.4_

  - [~] 9.5 Add CelebrationParticles system
    - Add CPUParticles2D node to GameOver scene
    - Configure for star texture burst effect
    - Trigger on new high score detection
    - _Requirements: 15.1_

- [ ] 10. Checkpoint - Overlay Screens Complete
  - Ensure all tests pass, verify PauseScreen and GameOver work correctly with entrance animations, ask the user if questions arise.

- [ ] 11. Phase 7: Achievements Screen Overhaul
  - [~] 11.1 Create AchievementCard reusable component
    - Create `scenes/components/AchievementCard.tscn` with KenneyPanel root
    - Add IconContainer with IconBackground (button_square_depth_gloss.png) and AchievementIcon
    - Add InfoContainer with TitleLabel, DescriptionLabel, ProgressBar (KenneySlider for progressive achievements)
    - Add StatusContainer with StatusStar (star.png filled or star_outline.png locked)
    - Add LockedOverlay (ColorRect, semi-transparent grey, hidden when unlocked)
    - Create `scripts/components/achievement_card.gd` with achievement data properties
    - _Requirements: 9.1, 9.2, 9.4_

  - [~] 11.2 Convert Achievements.tscn to use Kenney components
    - Replace BackButton with KenneyButton (SQUARE_DEPTH_GLOSS, arrow icon)
    - Wrap ProgressLabel in KenneyPanel with star icon
    - Add Divider TextureRect with divider_edges.png
    - Replace achievement list with AchievementCard instances
    - _Requirements: 9.1_

  - [~] 11.3 Implement locked/unlocked visual states
    - In AchievementCard, implement set_locked(bool) method
    - Locked: Show grey overlay (0.6 alpha), star_outline.png, desaturated icon
    - Unlocked: Full color, star.png, no overlay
    - _Requirements: 9.2, 9.4_

  - [~] 11.4 Implement progress bar for progressive achievements
    - Use KenneySlider component in read-only mode
    - Show "X/Y" text overlay on progress bar
    - Animate fill when progress updates (0.3s smooth transition)
    - Hide progress bar for one-time achievements
    - _Requirements: 9.3_

  - [~] 11.5 Implement achievement unlock animation
    - In AchievementCard, implement play_unlock_animation() method
    - Card shakes (0.2s)
    - Overlay fades out (0.3s)
    - Icon saturates (0.3s)
    - Star outline morphs to filled with scale pulse (0.4s)
    - Particle burst from card (0.5s)
    - Glow effect fades in and out (1.0s)
    - _Requirements: 9.5_

- [ ] 12. Phase 8: AudioSettingsMenu Overhaul
  - [~] 12.1 Create KenneySlider component
    - Create `scripts/components/kenney_slider.gd` with class_name KenneySlider extending HSlider
    - Add Background (TextureRect with slide_horizontal_grey.png)
    - Add Fill (TextureRect with slide_horizontal_color.png)
    - Add Handle (TextureRect with slide_handle.png)
    - Implement custom drawing to show fill based on value
    - Add @export properties: slider_color, show_value_label, value_suffix
    - _Requirements: 10.1, 10.2_

  - [~] 12.2 Implement KenneySlider animations
    - Implement play_handle_animation() for value changes
    - Handle hover: Scale to 1.1 (0.1s)
    - Handle drag: Scale to 1.15 (0.1s)
    - Value change: Handle bounce (0.15s)
    - Fill bar: Smooth transition (0.2s)
    - _Requirements: 10.3_

  - [~] 12.3 Convert AudioSettingsMenu.tscn to use Kenney components
    - Replace BackButton with KenneyButton (SQUARE_DEPTH_GLOSS, arrow icon)
    - Wrap each volume row in KenneyPanel
    - Add IconPanel with speaker icon for each volume control
    - Replace all HSlider nodes with KenneySlider instances
    - Add ValueLabel showing percentage next to each slider
    - _Requirements: 10.1, 10.5_

  - [~] 12.4 Implement checkbox toggles with Kenney textures
    - Replace checkbox controls with TextureButton
    - Unchecked: check_square_grey.png
    - Checked: check_square_color_checkmark.png (Yellow)
    - Implement toggle animation: Checkmark fades in with scale (0.2s)
    - _Requirements: 10.4_

  - [~] 12.5 Connect sliders to AudioManager
    - Connect each KenneySlider value_changed signal to AudioManager methods
    - Implement real-time feedback: value changes immediately update AudioManager
    - Add TestSoundButton (KenneyButton) that plays click-a.ogg at current SFX volume
    - Ensure settings persist across sessions
    - _Requirements: 10.5_

- [ ] 13. Checkpoint - All Screens Converted
  - Ensure all tests pass, verify all six screens use Kenney components correctly, ask the user if questions arise.

- [ ] 14. Phase 9: Polish and Optimization
  - [~] 14.1 Add particle effects for significant actions
    - Shop purchase: Star burst (already implemented in 6.6)
    - Achievement unlock: Star burst (already implemented in 11.5)
    - High score: Star burst (already implemented in 9.5)
    - Currency earned: Coin particles flying to currency display
    - Level up or milestone: Confetti-style particle effect
    - _Requirements: 15.1_

  - [~] 14.2 Implement screen transition animations
    - Create screen_transition.gd utility script
    - Implement fade_to_scene(scene_path, duration) method
    - Implement slide_to_scene(scene_path, direction, duration) method
    - Apply to all scene changes in main_menu.gd, shop.gd, etc.
    - _Requirements: 15.2_

  - [~] 14.3 Add floating animations to decorative elements
    - Implement subtle floating animation for MainMenu stars
    - Add gentle rotation to decorative arrows
    - Use UIAnimationManager with looping tweens
    - _Requirements: 15.3_

  - [~] 14.4 Implement currency count-up animations
    - Use UIAnimationManager.count_up() for currency changes
    - Add bounce effect when currency increases
    - Apply to MainMenu, Shop, GameOver currency displays
    - _Requirements: 15.4_

  - [~] 14.5 Validate touch target sizes
    - Create editor tool script to scan all scenes for button sizes
    - Ensure all KenneyButton instances meet 44x44px minimum
    - Add warnings in KenneyButton _ready() for violations
    - Fix any buttons below minimum size
    - _Requirements: 14.1, 2.4_

  - [~] 14.6 Optimize texture atlases and draw calls
    - Create texture atlas for Yellow pack button textures
    - Create texture atlas for icon textures
    - Update Theme resource to use atlas textures
    - Measure draw call reduction using Godot profiler
    - _Requirements: 13.2_

  - [~] 14.7 Performance profiling and optimization
    - Profile all six screens with Godot profiler
    - Verify 60 FPS maintained during animations
    - Check memory usage stays under 50MB for UI
    - Optimize any bottlenecks found
    - Document performance metrics
    - _Requirements: 13.1, 13.4, 13.5_

  - [~] 14.8 Accessibility audit
    - Verify all touch targets meet 44x44px minimum (from 14.5)
    - Check text contrast ratios against Kenney backgrounds
    - Ensure all interactive elements have visible focus indicators
    - Test keyboard navigation for all screens
    - Document accessibility compliance
    - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5_

- [ ] 15. Phase 10: Testing and Quality Assurance
  - [ ]* 15.1 Write unit tests for KenneyButton component
    - Test state transitions (normal → hover → pressed)
    - Test texture loading with fallback handling
    - Test animation triggering
    - Test sound playback with cooldown
    - Use GdUnit4 or Gut testing framework

  - [ ]* 15.2 Write unit tests for KenneyPanel component
    - Test transparency settings
    - Test entrance animations
    - Test texture loading

  - [ ]* 15.3 Write unit tests for KenneySlider component
    - Test value changes and signal emissions
    - Test handle animations
    - Test fill bar rendering

  - [ ]* 15.4 Write unit tests for UIAnimationManager
    - Test tween registration and cleanup
    - Test MAX_CONCURRENT_TWEENS limit enforcement
    - Test all juice effect methods (bounce_in, squash, pop_out, wobble)

  - [ ]* 15.5 Write integration tests for screen navigation
    - Test MainMenu → Shop → MainMenu flow
    - Test MainMenu → Achievements → MainMenu flow
    - Test MainMenu → Settings → MainMenu flow
    - Test PauseScreen → MainMenu flow
    - Test GameOver → Restart flow
    - Verify AudioManager state persists across scene changes

  - [ ]* 15.6 Write integration tests for audio system
    - Test UI sounds play at correct volume levels
    - Test volume slider changes affect actual audio output
    - Test sound cooldowns prevent spam
    - Test pitch variation works correctly

  - [ ]* 15.7 Performance testing on target devices
    - Test on Android device (540x960 viewport)
    - Measure FPS during heavy animation sequences
    - Measure memory usage across all screens
    - Measure scene load times
    - Verify performance targets met (60 FPS, <200ms load, <50MB memory)

  - [ ]* 15.8 Visual regression testing
    - Create snapshot tests for all six screens
    - Capture reference images after animations settle
    - Implement image comparison utility
    - Set acceptable diff threshold (5%)

  - [ ]* 15.9 Manual visual QA checklist
    - Verify no blue StyleBoxFlat buttons visible
    - Check hover animations play smoothly at 60 FPS
    - Verify button press animations feel responsive
    - Check idle wobble animations are subtle
    - Verify star ratings display correctly
    - Check achievement locked/unlocked states are clear
    - Verify slider handles move smoothly
    - Check particle effects appear appropriately
    - Verify all text is readable against backgrounds
    - Confirm all touch targets meet 44x44px minimum

  - [ ]* 15.10 User acceptance testing
    - Conduct playtesting with 3-5 users
    - Test first-time user flow (launch → shop → menu → play)
    - Test settings adjustment and persistence
    - Test achievement unlock experience
    - Test game over flow with continue/restart
    - Test rapid interaction for audio/animation glitches
    - Collect feedback on polish and feel
    - Document user feedback and issues

- [ ] 16. Final Checkpoint - Complete UI Overhaul
  - Ensure all tests pass, verify all six screens are fully converted with animations and sounds, confirm performance targets met, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional testing tasks and can be skipped for faster MVP
- Each task references specific requirements for traceability (e.g., _Requirements: 1.1, 1.4_)
- Checkpoints ensure incremental validation at major milestones
- Implementation uses GDScript for Godot 4.6 engine
- All UI components are reusable across the six screens
- Performance target: 60 FPS on 540x960 mobile viewport
- Accessibility target: 44x44px minimum touch targets
- This is a UI/visual redesign - no property-based tests needed, focus on integration and visual testing
