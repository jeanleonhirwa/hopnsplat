# ShopItemCard Component

## Overview

The `ShopItemCard` is a reusable UI component for displaying shop items in the HopNSplat game. It extends `KenneyPanel` and provides a complete card layout with item icon, name, description, price display, purchase button, and equipped state indicator.

## Features

- **Item Display**: Shows item icon, name, and description
- **Price Panel**: Displays item price with a coin/star icon
- **Purchase Button**: Interactive button that changes based on item state
- **Equipped Indicator**: Checkmark icon shown when item is equipped
- **State Management**: Handles purchased and equipped states automatically
- **Responsive Layout**: Uses anchors and containers for proper scaling

## File Locations

- **Script**: `scripts/components/shop_item_card.gd`
- **Scene**: `scenes/components/ShopItemCard.tscn`
- **Test Scene**: `scenes/test_shop_item_card.tscn`

## Usage

### In Scene Editor

1. Add a `ShopItemCard` node to your scene
2. Configure the exported properties:
   - `item_id`: Unique identifier for the item
   - `item_name`: Display name of the item
   - `item_description`: Short description text
   - `item_price`: Cost in game currency
   - `item_icon`: Texture2D for the item icon
   - `is_purchased`: Whether the item has been purchased
   - `is_equipped`: Whether the item is currently equipped

### In Code

```gdscript
# Create a new shop item card
var card = ShopItemCard.new()
add_child(card)

# Set item data
card.set_item_data(
	"skin_blue",
	"Blue Alien Skin",
	"A cool blue variant of the alien",
	200,
	preload("res://assets/icons/blue_alien.png")
)

# Connect signals
card.purchase_requested.connect(_on_item_purchase_requested)
card.equip_requested.connect(_on_item_equip_requested)

# Update state
card.set_purchased(true)
card.set_equipped(false)
```

## Properties

### Exported Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `item_id` | String | "" | Unique identifier for the item |
| `item_name` | String | "Item Name" | Display name shown on the card |
| `item_description` | String | "Item description goes here" | Short description text |
| `item_price` | int | 100 | Cost in game currency |
| `item_icon` | Texture2D | null | Icon texture displayed on the card |
| `is_purchased` | bool | false | Whether the item has been purchased |
| `is_equipped` | bool | false | Whether the item is currently equipped |

## Signals

### `purchase_requested(item_id: String)`

Emitted when the user clicks the "Buy" button on an unpurchased item.

**Parameters:**
- `item_id`: The unique identifier of the item to purchase

**Example:**
```gdscript
func _on_item_purchase_requested(item_id: String) -> void:
	if player_currency >= item_price:
		player_currency -= item_price
		card.set_purchased(true)
		card.play_purchase_animation()
```

### `equip_requested(item_id: String)`

Emitted when the user clicks the "Equip" button on a purchased but not equipped item.

**Parameters:**
- `item_id`: The unique identifier of the item to equip

**Example:**
```gdscript
func _on_item_equip_requested(item_id: String) -> void:
	# Unequip current item
	current_equipped_card.set_equipped(false)
	# Equip new item
	card.set_equipped(true)
	apply_item_effects(item_id)
```

## Public Methods

### `set_item_data(id: String, item_name_text: String, description: String, price: int, icon: Texture2D) -> void`

Sets all item data at once and updates the UI.

**Parameters:**
- `id`: Unique identifier
- `item_name_text`: Display name
- `description`: Description text
- `price`: Cost in currency
- `icon`: Item icon texture

### `set_purchased(purchased: bool) -> void`

Updates the purchased state and refreshes the UI accordingly.

**Parameters:**
- `purchased`: True if item is purchased, false otherwise

**Behavior:**
- When purchased: Hides price panel, changes button to "Equip"
- When not purchased: Shows price panel, button shows "Buy"

### `set_equipped(equipped: bool) -> void`

Updates the equipped state and refreshes the UI accordingly.

**Parameters:**
- `equipped`: True if item is equipped, false otherwise

**Behavior:**
- When equipped: Shows checkmark icon, button shows "Equipped" (disabled)
- When not equipped: Hides checkmark, button shows "Equip" (enabled)

### `play_purchase_animation() -> void`

Plays the purchase celebration animation sequence. (To be implemented in Task 6.5)

## UI Structure

```
ShopItemCard (KenneyPanel)
├── MainContainer (VBoxContainer)
│   ├── TopSection (HBoxContainer)
│   │   ├── ItemIcon (TextureRect)
│   │   ├── Spacer
│   │   └── InfoContainer (VBoxContainer)
│   │       ├── ItemName (Label)
│   │       └── ItemDescription (Label)
│   ├── Spacer
│   └── BottomSection (HBoxContainer)
│       ├── PricePanel (KenneyPanel)
│       │   └── PriceContainer (HBoxContainer)
│       │       ├── CoinIcon (TextureRect)
│       │       └── PriceLabel (Label)
│       ├── Spacer
│       └── PurchaseButton (KenneyButton)
└── EquippedCheckmark (TextureRect)
```

## Visual States

### Unpurchased State
- Price panel visible with coin icon and price
- Button shows "Buy"
- Button is enabled
- Checkmark is hidden

### Purchased (Not Equipped) State
- Price panel hidden
- Button shows "Equip"
- Button is enabled
- Checkmark is hidden

### Purchased and Equipped State
- Price panel hidden
- Button shows "Equipped"
- Button is disabled
- Checkmark is visible in top-right corner

## Styling

The component uses the Kenney UI pack assets:

- **Card Background**: Yellow pack, Rectangle Depth style
- **Price Panel**: Yellow pack, Rectangle style
- **Purchase Button**: Yellow pack, Rectangle Depth Gloss style
- **Coin Icon**: `star.png` (placeholder, can be replaced with actual coin icon)
- **Checkmark Icon**: `icon_checkmark.png` from Yellow pack

## Customization

### Changing Colors

To use a different color pack, modify the component initialization:

```gdscript
# In _ready() or after instantiation
card.color_pack = KenneyPanel.ColorPack.RED
card.price_panel.color_pack = KenneyPanel.ColorPack.RED
card.purchase_button.color_pack = KenneyButton.ColorPack.RED
```

### Adjusting Size

The card has a default minimum size of 300x150 pixels. To change:

```gdscript
card.custom_minimum_size = Vector2(350, 180)
```

### Custom Icons

Replace the coin icon with a custom texture:

```gdscript
card.coin_icon_node.texture = preload("res://assets/icons/custom_coin.png")
```

## Integration with Shop System

Example integration in `Shop.tscn`:

```gdscript
# In shop.gd
extends Control

var shop_items: Array[Dictionary] = [
	{
		"id": "skin_blue",
		"name": "Blue Alien",
		"description": "A cool blue variant",
		"price": 200,
		"icon": preload("res://assets/icons/blue_alien.png"),
		"type": "skin"
	},
	# ... more items
]

func _ready():
	_populate_shop_items()

func _populate_shop_items():
	var grid = $TabContainer/SkinsTab/GridContainer
	
	for item_data in shop_items:
		var card = preload("res://scenes/components/ShopItemCard.tscn").instantiate()
		grid.add_child(card)
		
		card.set_item_data(
			item_data["id"],
			item_data["name"],
			item_data["description"],
			item_data["price"],
			item_data["icon"]
		)
		
		# Set state from save data
		card.set_purchased(SaveManager.is_item_purchased(item_data["id"]))
		card.set_equipped(SaveManager.is_item_equipped(item_data["id"]))
		
		# Connect signals
		card.purchase_requested.connect(_on_purchase_requested)
		card.equip_requested.connect(_on_equip_requested)

func _on_purchase_requested(item_id: String):
	var item = _get_item_by_id(item_id)
	if PlayerData.currency >= item["price"]:
		PlayerData.currency -= item["price"]
		SaveManager.set_item_purchased(item_id, true)
		# Find and update the card
		var card = _find_card_by_id(item_id)
		card.set_purchased(true)
		card.play_purchase_animation()

func _on_equip_requested(item_id: String):
	# Unequip current item of same type
	var item = _get_item_by_id(item_id)
	_unequip_items_of_type(item["type"])
	
	# Equip new item
	SaveManager.set_item_equipped(item_id, true)
	var card = _find_card_by_id(item_id)
	card.set_equipped(true)
```

## Testing

Run the test scene to see the component in different states:

```
res://scenes/test_shop_item_card.tscn
```

The test scene shows three cards:
1. Unpurchased item (shows price and "Buy" button)
2. Purchased but not equipped (shows "Equip" button)
3. Purchased and equipped (shows "Equipped" button and checkmark)

## Future Enhancements (Task 6.5)

The `play_purchase_animation()` method will be implemented with:
- Button press animation (0.1s)
- Coin icon flies from item to currency display (0.5s with arc motion)
- Currency count-up animation (0.3s)
- Checkmark appears with pop-out animation (0.2s)
- Particle burst at item location (star textures)

## Requirements Satisfied

This component satisfies **Requirement 6.2** from the design document:
- ✅ KenneyPanel root with Rectangle Depth style
- ✅ ItemIcon (TextureRect) for item display
- ✅ ItemName (Label) for item name
- ✅ ItemDescription (Label) for item description
- ✅ PricePanel (KenneyPanel) with CoinIcon and PriceLabel
- ✅ PurchaseButton (KenneyButton, RECTANGLE_DEPTH_GLOSS)
- ✅ EquippedCheckmark (TextureRect with icon_checkmark.png, hidden by default)
- ✅ Script with item data properties

## Related Components

- `KenneyButton` - Used for the purchase/equip button
- `KenneyPanel` - Base class and used for price panel
- `UIAnimationManager` - Will be used for purchase animations (Task 6.5)

## Notes

- The coin icon currently uses `star.png` as a placeholder since the Kenney UI pack doesn't include a coin icon. This can be replaced with a custom coin icon if available.
- The component is designed to work with the existing shop system and save manager.
- All text labels use white color for visibility against the yellow panel background.
- The component follows the 44x44px minimum touch target size for accessibility (purchase button).
