# Requirements Document

## Introduction

This document specifies the requirements for overhauling the HopNSplat mobile game UI using the Kenney UI pack assets. The goal is to transform the current basic blue StyleBoxFlat buttons into a playful, engaging, and professional UI that matches the game's pink alien theme and casual/cartoon aesthetic. The overhaul will apply to all six main screens (MainMenu, Shop, PauseScreen, GameOver, Achievements, AudioSettingsMenu) and incorporate visual polish through animations, sound effects, and juice effects.

## Glossary

- **UI_System**: The complete user interface system for HopNSplat, including all screens, buttons, and interactive elements
- **Kenney_Asset**: A texture or sound file from the downloaded Kenney UI pack located in `assets/ui_packs/` or `assets/ui_sounds/`
- **TextureButton**: A Godot Control node that displays button states using texture images instead of StyleBoxFlat
- **Animation_Controller**: A Godot AnimationPlayer or Tween that manages UI animations
- **Sound_Manager**: The AudioManager autoload singleton that handles UI sound playback
- **Touch_Target**: An interactive UI element sized appropriately for mobile touch input (minimum 44x44 pixels)
- **Juice_Effect**: Visual feedback animations like bounce, squash/stretch, wobble, or particle effects
- **Theme_Resource**: A Godot Theme resource file that defines consistent styling across UI elements
- **Color_Palette**: The selected color scheme from Kenney pack (Yellow/Red folders) matching the pink alien theme
- **Screen**: One of the six main UI scenes (MainMenu, Shop, PauseScreen, GameOver, Achievements, AudioSettingsMenu)

## Requirements

### Requirement 1: Asset Integration System

**User Story:** As a developer, I want to integrate Kenney UI pack assets into the Godot project, so that they are available for use in all UI screens.

#### Acceptance Criteria

1. THE UI_System SHALL load Kenney_Asset textures from `assets/ui_packs/` with proper import settings for mobile optimization
2. THE UI_System SHALL load Kenney_Asset sounds from `assets/ui_sounds/` as AudioStream resources
3. THE UI_System SHALL organize assets by type (buttons, sliders, checkboxes, icons, decorative) in the project structure
4. WHEN a Kenney_Asset texture is imported, THE UI_System SHALL configure it with mipmaps disabled and filter enabled for crisp mobile display
5. THE UI_System SHALL create a Theme_Resource that references Kenney_Asset textures for reusable styling

### Requirement 2: Button System Redesign

**User Story:** As a player, I want buttons to look playful and engaging, so that the game feels polished and fun to interact with.

#### Acceptance Criteria

1. THE UI_System SHALL replace all StyleBoxFlat buttons with TextureButton nodes using Kenney_Asset textures
2. THE UI_System SHALL use Yellow or Red Color_Palette button textures to match the pink alien theme
3. WHEN a button is displayed, THE UI_System SHALL show appropriate textures for normal, hover, and pressed states
4. THE UI_System SHALL size all buttons as Touch_Target elements with minimum 44x44 pixel dimensions
5. THE UI_System SHALL apply consistent button styling across all six Screen instances
6. WHERE a button has an icon, THE UI_System SHALL overlay Kenney_Asset icon textures on the button surface

### Requirement 3: Button Animation and Juice Effects

**User Story:** As a player, I want buttons to respond with bouncy animations when I interact with them, so that the game feels alive and responsive.

#### Acceptance Criteria

1. WHEN a button is hovered or focused, THE Animation_Controller SHALL play a bounce-in Juice_Effect scaling the button to 110% over 0.15 seconds
2. WHEN a button is pressed, THE Animation_Controller SHALL play a squash Juice_Effect scaling the button to 95% over 0.1 seconds
3. WHEN a button is released, THE Animation_Controller SHALL play a pop-out Juice_Effect with elastic easing
4. WHERE a button is important (Play, Continue, Purchase), THE Animation_Controller SHALL play an idle wobble Juice_Effect looping every 2 seconds
5. THE Animation_Controller SHALL use Tween.EASE_OUT and Tween.TRANS_ELASTIC for playful motion curves

### Requirement 4: UI Sound Feedback System

**User Story:** As a player, I want to hear satisfying sounds when I interact with UI elements, so that my actions feel impactful and fun.

#### Acceptance Criteria

1. WHEN a button receives hover or focus, THE Sound_Manager SHALL play a Kenney_Asset hover sound (tap-a.ogg or tap-b.ogg)
2. WHEN a button is pressed, THE Sound_Manager SHALL play a Kenney_Asset click sound (click-a.ogg or click-b.ogg)
3. WHEN a toggle or checkbox changes state, THE Sound_Manager SHALL play a Kenney_Asset switch sound (switch-a.ogg or switch-b.ogg)
4. THE Sound_Manager SHALL vary sound playback pitch randomly between 0.95 and 1.05 for variety
5. THE Sound_Manager SHALL respect the user's audio settings volume levels for UI sounds

### Requirement 5: MainMenu Screen Overhaul

**User Story:** As a player, I want the main menu to look inviting and exciting, so that I'm motivated to start playing.

#### Acceptance Criteria

1. THE UI_System SHALL redesign MainMenu.tscn using Kenney_Asset textures for all buttons
2. THE UI_System SHALL add decorative Kenney_Asset elements (stars, arrows, dividers) to enhance visual appeal
3. WHEN MainMenu is displayed, THE Animation_Controller SHALL stagger-animate buttons appearing with bounce effects
4. THE UI_System SHALL display currency and high score using Kenney_Asset panel backgrounds
5. THE UI_System SHALL apply Color_Palette textures (Yellow/Red) to create warm, inviting atmosphere

### Requirement 6: Shop Screen Overhaul

**User Story:** As a player, I want the shop to look appealing and organized, so that I can easily browse and purchase items.

#### Acceptance Criteria

1. THE UI_System SHALL redesign Shop.tscn using Kenney_Asset textures for tabs, buttons, and item cards
2. THE UI_System SHALL use Kenney_Asset panel textures for item display cards with depth or gloss variants
3. WHEN a shop tab is selected, THE Animation_Controller SHALL play a slide-in Juice_Effect for tab content
4. THE UI_System SHALL display currency using Kenney_Asset coin icon and panel background
5. THE UI_System SHALL use Kenney_Asset checkmark icons to indicate purchased or equipped items
6. WHEN an item is purchased, THE Animation_Controller SHALL play a celebration Juice_Effect with scale and rotation

### Requirement 7: PauseScreen Overhaul

**User Story:** As a player, I want the pause screen to be clear and easy to navigate, so that I can quickly resume or adjust settings.

#### Acceptance Criteria

1. THE UI_System SHALL redesign PauseScreen.tscn using Kenney_Asset textures for all buttons and panels
2. THE UI_System SHALL use semi-transparent Kenney_Asset panel backgrounds to maintain game visibility
3. WHEN PauseScreen appears, THE Animation_Controller SHALL play a zoom-in Juice_Effect for the panel
4. THE UI_System SHALL display score and coins using Kenney_Asset label backgrounds
5. THE UI_System SHALL use Kenney_Asset icons (play, settings, restart, home) on buttons for clarity

### Requirement 8: GameOver Screen Overhaul

**User Story:** As a player, I want the game over screen to feel rewarding even when I lose, so that I'm motivated to try again.

#### Acceptance Criteria

1. THE UI_System SHALL redesign GameOver.tscn using Kenney_Asset textures for all buttons and stat displays
2. THE UI_System SHALL use Kenney_Asset star icons to display score ratings or achievements
3. WHEN GameOver appears, THE Animation_Controller SHALL play a dramatic entrance Juice_Effect with bounce
4. WHEN a new high score is achieved, THE Animation_Controller SHALL play a celebration Juice_Effect with particles or flashing
5. THE UI_System SHALL highlight the Continue button (ad reward) using bright Color_Palette textures and idle wobble animation

### Requirement 9: Achievements Screen Overhaul

**User Story:** As a player, I want the achievements screen to showcase my progress clearly, so that I feel proud of my accomplishments.

#### Acceptance Criteria

1. THE UI_System SHALL redesign Achievements.tscn using Kenney_Asset textures for achievement cards and progress bars
2. THE UI_System SHALL use Kenney_Asset star icons (filled/outline) to indicate achievement completion status
3. THE UI_System SHALL use Kenney_Asset slider textures for progress bar displays
4. WHEN an achievement card is displayed, THE UI_System SHALL show locked achievements with greyed or outline variants
5. WHEN an achievement is unlocked, THE Animation_Controller SHALL play an unlock Juice_Effect with glow and scale

### Requirement 10: AudioSettingsMenu Overhaul

**User Story:** As a player, I want the audio settings to be intuitive and visually consistent, so that I can easily adjust sound levels.

#### Acceptance Criteria

1. THE UI_System SHALL redesign AudioSettingsMenu.tscn using Kenney_Asset slider textures for volume controls
2. THE UI_System SHALL use Kenney_Asset slider handle textures (color variants) for interactive dragging
3. WHEN a slider value changes, THE Animation_Controller SHALL play a subtle scale Juice_Effect on the handle
4. THE UI_System SHALL use Kenney_Asset checkbox textures for mute toggles
5. THE UI_System SHALL apply consistent Color_Palette styling matching other Screen instances

### Requirement 11: Responsive Layout System

**User Story:** As a player on different mobile devices, I want the UI to adapt properly to my screen, so that all elements are visible and usable.

#### Acceptance Criteria

1. THE UI_System SHALL maintain 540x960 portrait viewport dimensions as defined in project.godot
2. THE UI_System SHALL use anchor-based positioning for all UI elements to support viewport stretching
3. WHEN the viewport is stretched, THE UI_System SHALL preserve aspect ratio using "keep_width" stretch mode
4. THE UI_System SHALL ensure all Touch_Target elements remain accessible within safe area margins
5. THE UI_System SHALL scale Kenney_Asset textures proportionally to maintain visual quality

### Requirement 12: Theme Resource System

**User Story:** As a developer, I want a centralized theme system, so that UI styling is consistent and easy to maintain.

#### Acceptance Criteria

1. THE UI_System SHALL create a Theme_Resource file that defines default styles for all UI node types
2. THE Theme_Resource SHALL reference Kenney_Asset textures for buttons, panels, sliders, and checkboxes
3. THE Theme_Resource SHALL define font sizes, colors, and spacing constants for consistency
4. THE UI_System SHALL apply the Theme_Resource to all six Screen instances
5. WHEN the Theme_Resource is modified, THE UI_System SHALL reflect changes across all screens without individual scene edits

### Requirement 13: Performance Optimization

**User Story:** As a player on a mobile device, I want the UI to run smoothly, so that my gameplay experience is not interrupted.

#### Acceptance Criteria

1. THE UI_System SHALL limit concurrent Animation_Controller tweens to 10 or fewer to prevent performance degradation
2. THE UI_System SHALL use texture atlases for Kenney_Asset textures to reduce draw calls
3. THE UI_System SHALL cache AudioStream resources for Kenney_Asset sounds to avoid repeated loading
4. WHEN animations are playing, THE Animation_Controller SHALL use Tween nodes instead of per-frame _process updates
5. THE UI_System SHALL maintain 60 FPS performance on target mobile devices during UI interactions

### Requirement 14: Accessibility Enhancements

**User Story:** As a player with accessibility needs, I want the UI to be clear and easy to use, so that I can enjoy the game comfortably.

#### Acceptance Criteria

1. THE UI_System SHALL ensure all Touch_Target elements meet minimum 44x44 pixel size requirements
2. THE UI_System SHALL provide sufficient contrast between text and Kenney_Asset background textures
3. THE UI_System SHALL use Kenney_Asset icon textures alongside text labels for visual clarity
4. THE UI_System SHALL ensure all interactive elements have visible focus indicators using Kenney_Asset textures
5. THE UI_System SHALL support keyboard navigation for testing and accessibility tools

### Requirement 15: Visual Polish and Particle Effects

**User Story:** As a player, I want delightful visual effects throughout the UI, so that the game feels premium and fun.

#### Acceptance Criteria

1. WHERE a significant action occurs (purchase, achievement unlock, high score), THE UI_System SHALL spawn particle effects using Kenney_Asset star or sparkle textures
2. WHEN a Screen transitions in or out, THE Animation_Controller SHALL play fade and slide Juice_Effect animations
3. THE UI_System SHALL add subtle floating animation to decorative Kenney_Asset elements (stars, arrows)
4. WHEN currency is earned or spent, THE Animation_Controller SHALL play a count-up animation with bounce effect
5. THE UI_System SHALL use Kenney_Asset glow or gradient variants to highlight important elements

