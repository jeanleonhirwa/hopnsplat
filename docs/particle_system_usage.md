# Particle System Usage Guide

## Overview

The shop particle system provides celebration effects for various events in the shop screen. There are two ways to spawn particles:

### 1. ShopItemCard Particle System (Task 6.5)

The `ShopItemCard` component has a built-in `_spawn_purchase_particles()` method that is automatically called during the purchase animation sequence. This is used specifically for item purchases.

**Location**: `scripts/components/shop_item_card.gd`

**Usage**: Automatically triggered when `play_purchase_animation()` is called.

**Configuration**:
- 25 particles
- 0.8s lifetime
- Explosiveness: 1.0
- Texture: star.png
- Auto-cleanup after lifetime

### 2. Global Shop Celebration Particles (Task 6.6)

The `Shop` script now has a global `spawn_celebration_particles(global_pos: Vector2)` method that can be used for other celebration events beyond item purchases.

**Location**: `scripts/shop.gd`

**Usage Examples**:

```gdscript
# Example 1: Celebrate first purchase milestone
func _on_first_purchase():
    var header_pos = $VBoxContainer/HeaderContainer.global_position
    spawn_celebration_particles(header_pos)

# Example 2: Celebrate unlocking all items in a category
func _on_category_completed():
    var tab_pos = $VBoxContainer/TabContainer.global_position
    spawn_celebration_particles(tab_pos)

# Example 3: Celebrate reaching a currency milestone
func _on_currency_milestone(milestone: int):
    var currency_panel = $VBoxContainer/HeaderContainer/CurrencyPanel
    spawn_celebration_particles(currency_panel.global_position)
```

**Configuration**:
- 25 particles (within 20-30 range as specified)
- 0.8s lifetime
- Explosiveness: 1.0
- Texture: star.png (Yellow pack)
- Auto-cleanup after lifetime

## Technical Details

Both particle systems use `CPUParticles2D` with the following shared properties:

- **Emission Shape**: Sphere with 20px radius
- **Direction**: Upward (-1 on Y axis)
- **Spread**: 180 degrees
- **Velocity**: 100-200 pixels/second
- **Gravity**: 300 pixels/second² downward
- **Scale**: 0.3-0.6
- **Color**: Yellow/gold tint (1.0, 0.9, 0.3)
- **Fade**: Gradient from opaque to transparent over lifetime

## Performance Considerations

- Particles are one-shot (single burst)
- Auto-cleanup prevents memory leaks
- CPUParticles2D is used for compatibility
- Consider using GPUParticles2D for better performance on high-end devices

## Future Enhancements

Potential use cases for the global particle system:
1. First purchase celebration
2. Category completion (all items purchased)
3. Currency milestones (100, 500, 1000 coins)
4. Special event unlocks
5. Daily reward claims
6. Achievement unlocks in shop context
