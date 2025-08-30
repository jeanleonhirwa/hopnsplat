extends Node

# Shop System for Hop n' Splat
# Manages purchasable items, player inventory, and shop UI

signal item_purchased(item_id: String, cost: int)
signal currency_updated(new_amount: int)

# Shop item categories
enum ItemCategory {
	SKINS,
	UPGRADES,
	BOOSTS
}

# Shop item data structure
class ShopItem:
	var id: String
	var name: String
	var description: String
	var cost: int
	var category: ItemCategory
	var icon_path: String
	var is_purchased: bool = false
	var is_equipped: bool = false
	
	func _init(item_id: String, item_name: String, item_desc: String, item_cost: int, item_category: ItemCategory, item_icon: String = ""):
		id = item_id
		name = item_name
		description = item_desc
		cost = item_cost
		category = item_category
		icon_path = item_icon

# Available shop items
var shop_items: Dictionary = {}
var player_inventory: Array[String] = []
var equipped_items: Dictionary = {}

# Save file path
const SHOP_SAVE_FILE = "user://shop_data.save"

func _ready():
	initialize_shop_items()
	load_shop_data()

func initialize_shop_items():
	"""Initialize all available shop items"""
	
	# PLAYER SKINS
	shop_items["skin_blue"] = ShopItem.new(
		"skin_blue", "Blue Alien", "Cool blue alien skin", 50, ItemCategory.SKINS, "res://assets/player/alienBlue.png"
	)
	shop_items["skin_green"] = ShopItem.new(
		"skin_green", "Green Alien", "Fresh green alien skin", 75, ItemCategory.SKINS, "res://assets/player/alienGreen.png"
	)
	shop_items["skin_yellow"] = ShopItem.new(
		"skin_yellow", "Yellow Alien", "Bright yellow alien skin", 100, ItemCategory.SKINS, "res://assets/player/alienYellow.png"
	)
	
	# BOOST UPGRADES
	shop_items["jump_boost_upgrade"] = ShopItem.new(
		"jump_boost_upgrade", "Jump Boost+", "Increases jump boost duration by 2 seconds", 150, ItemCategory.UPGRADES
	)
	shop_items["speed_boost_upgrade"] = ShopItem.new(
		"speed_boost_upgrade", "Speed Boost+", "Increases speed boost duration by 2 seconds", 150, ItemCategory.UPGRADES
	)
	shop_items["shield_upgrade"] = ShopItem.new(
		"shield_upgrade", "Shield+", "Shield blocks 2 hits instead of 1", 200, ItemCategory.UPGRADES
	)
	shop_items["magnet_upgrade"] = ShopItem.new(
		"magnet_upgrade", "Magnet+", "Increases coin magnet radius by 50%", 175, ItemCategory.UPGRADES
	)
	
	# BOOST PACKS (consumable)
	shop_items["boost_pack_small"] = ShopItem.new(
		"boost_pack_small", "Small Boost Pack", "Start with 1 random boost", 25, ItemCategory.BOOSTS
	)
	shop_items["boost_pack_large"] = ShopItem.new(
		"boost_pack_large", "Large Boost Pack", "Start with 2 random boosts", 75, ItemCategory.BOOSTS
	)

func get_items_by_category(category: ItemCategory) -> Array[ShopItem]:
	"""Get all items in a specific category"""
	var items: Array[ShopItem] = []
	for item_id in shop_items:
		var item = shop_items[item_id]
		if item.category == category:
			items.append(item)
	return items

func can_purchase_item(item_id: String, player_currency: int) -> bool:
	"""Check if player can purchase an item"""
	if not shop_items.has(item_id):
		return false
	
	var item = shop_items[item_id]
	return not item.is_purchased and player_currency >= item.cost

func purchase_item(item_id: String, player_currency: int) -> bool:
	"""Purchase an item if possible"""
	if not can_purchase_item(item_id, player_currency):
		return false
	
	var item = shop_items[item_id]
	item.is_purchased = true
	player_inventory.append(item_id)
	
	# Auto-equip first skin purchased
	if item.category == ItemCategory.SKINS and not equipped_items.has("skin"):
		equip_item(item_id)
	
	save_shop_data()
	emit_signal("item_purchased", item_id, item.cost)
	return true

func equip_item(item_id: String) -> bool:
	"""Equip a purchased item"""
	if not shop_items.has(item_id) or not shop_items[item_id].is_purchased:
		return false
	
	var item = shop_items[item_id]
	
	# Unequip previous item of same category
	match item.category:
		ItemCategory.SKINS:
			# Unequip current skin
			if equipped_items.has("skin"):
				var old_skin = shop_items[equipped_items["skin"]]
				old_skin.is_equipped = false
			equipped_items["skin"] = item_id
			item.is_equipped = true
	
	save_shop_data()
	return true

func get_equipped_skin() -> String:
	"""Get currently equipped skin ID"""
	return equipped_items.get("skin", "default")

func has_upgrade(upgrade_id: String) -> bool:
	"""Check if player has purchased an upgrade"""
	return shop_items.has(upgrade_id) and shop_items[upgrade_id].is_purchased

func save_shop_data():
	"""Save shop data to file"""
	var save_data = {
		"inventory": player_inventory,
		"equipped": equipped_items,
		"purchased_items": {}
	}
	
	# Save purchase status for all items
	for item_id in shop_items:
		var item = shop_items[item_id]
		save_data.purchased_items[item_id] = {
			"is_purchased": item.is_purchased,
			"is_equipped": item.is_equipped
		}
	
	var save_file = FileAccess.open(SHOP_SAVE_FILE, FileAccess.WRITE)
	if save_file:
		save_file.store_string(JSON.stringify(save_data))
		save_file.close()
		print("Shop data saved successfully")

func load_shop_data():
	"""Load shop data from file"""
	if not FileAccess.file_exists(SHOP_SAVE_FILE):
		print("No shop save file found, using defaults")
		return
	
	var save_file = FileAccess.open(SHOP_SAVE_FILE, FileAccess.READ)
	if not save_file:
		print("Failed to open shop save file")
		return
	
	var save_data_text = save_file.get_as_text()
	save_file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(save_data_text)
	if parse_result != OK:
		print("Failed to parse shop save data")
		return
	
	var save_data = json.data
	
	# Restore inventory and equipped items
	player_inventory = save_data.get("inventory", [])
	equipped_items = save_data.get("equipped", {})
	
	# Restore purchase status
	var purchased_items = save_data.get("purchased_items", {})
	for item_id in purchased_items:
		if shop_items.has(item_id):
			var item_data = purchased_items[item_id]
			shop_items[item_id].is_purchased = item_data.get("is_purchased", false)
			shop_items[item_id].is_equipped = item_data.get("is_equipped", false)
	
	print("Shop data loaded successfully")
