extends Control

# Shop System for Hop n' Splat
signal purchase_made(item_type: String, item_id: String)

# UI References
@onready var currency_label = $VBoxContainer/HeaderContainer/CurrencyLabel
@onready var skins_grid = $VBoxContainer/TabContainer/PlayerSkins/SkinsGrid
@onready var upgrades_grid = $VBoxContainer/TabContainer/BoostUpgrades/UpgradesGrid
@onready var powerups_grid = $VBoxContainer/TabContainer/PowerUps/PowerupsGrid

# Shop Data
var current_currency: int = 0
var purchased_items: Dictionary = {}

# Item definitions
var shop_items = {
	"skins": [
		{"id": "alien_blue", "name": "Blue Alien", "price": 50, "description": "Cool blue variant"},
		{"id": "alien_green", "name": "Green Alien", "price": 75, "description": "Nature-loving alien"},
		{"id": "alien_red", "name": "Red Alien", "price": 100, "description": "Fiery red alien"},
		{"id": "alien_gold", "name": "Golden Alien", "price": 200, "description": "Legendary golden skin"}
	],
	"upgrades": [
		{"id": "jump_duration", "name": "Jump Boost+", "price": 150, "description": "Jump boost lasts 2x longer"},
		{"id": "speed_duration", "name": "Speed Boost+", "price": 120, "description": "Speed boost lasts 2x longer"},
		{"id": "shield_extra", "name": "Double Shield", "price": 180, "description": "Shield blocks 2 hits instead of 1"},
		{"id": "magnet_range", "name": "Super Magnet", "price": 100, "description": "Coin magnet has 2x range"}
	],
	"powerups": [
		{"id": "start_jump", "name": "Jump Start", "price": 80, "description": "Start each game with jump boost"},
		{"id": "start_shield", "name": "Shield Start", "price": 120, "description": "Start each game with shield"},
		{"id": "coin_multiplier", "name": "Coin Luck", "price": 250, "description": "Earn 2x coins from jumps"}
	]
}

func _ready():
	load_shop_data()
	update_currency_display()
	populate_shop_items()

func load_shop_data():
	"""Load currency and purchased items from save file"""
	var save_file = FileAccess.open("user://hopnsplat_save.dat", FileAccess.READ)
	if save_file:
		var save_data = save_file.get_as_text()
		save_file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(save_data)
		if parse_result == OK:
			var data = json.data
			current_currency = data.get("total_currency", 0)
			purchased_items = data.get("purchased_items", {})

func save_shop_data():
	"""Save currency and purchased items to file"""
	var save_file = FileAccess.open("user://hopnsplat_save.dat", FileAccess.READ)
	var save_data = {}
	
	if save_file:
		var existing_data = save_file.get_as_text()
		save_file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(existing_data)
		if parse_result == OK:
			save_data = json.data
	
	# Update with current shop data
	save_data["total_currency"] = current_currency
	save_data["purchased_items"] = purchased_items
	
	# Save back to file
	save_file = FileAccess.open("user://hopnsplat_save.dat", FileAccess.WRITE)
	if save_file:
		save_file.store_string(JSON.stringify(save_data))
		save_file.close()

func update_currency_display():
	"""Update the currency label"""
	currency_label.text = "💰 Coins: " + str(current_currency)

func populate_shop_items():
	"""Create shop item buttons for each category"""
	create_skin_items()
	create_upgrade_items()
	create_powerup_items()

func create_skin_items():
	"""Create player skin shop items"""
	for item in shop_items["skins"]:
		var item_button = create_shop_item_button(item, "skins")
		skins_grid.add_child(item_button)

func create_upgrade_items():
	"""Create boost upgrade shop items"""
	for item in shop_items["upgrades"]:
		var item_button = create_shop_item_button(item, "upgrades")
		upgrades_grid.add_child(item_button)

func create_powerup_items():
	"""Create power-up shop items"""
	for item in shop_items["powerups"]:
		var item_button = create_shop_item_button(item, "powerups")
		powerups_grid.add_child(item_button)

func create_shop_item_button(item: Dictionary, category: String) -> Control:
	"""Create a shop item button with purchase functionality"""
	var item_container = VBoxContainer.new()
	item_container.custom_minimum_size = Vector2(240, 120)
	
	# Item panel
	var item_panel = Panel.new()
	item_panel.custom_minimum_size = Vector2(240, 120)
	
	# Item info container
	var info_container = VBoxContainer.new()
	info_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	info_container.add_theme_constant_override("separation", 5)
	
	# Item name
	var name_label = Label.new()
	name_label.text = item["name"]
	name_label.theme_override_font_sizes["font_size"] = 18
	name_label.theme_override_colors["font_color"] = Color.WHITE
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Item description
	var desc_label = Label.new()
	desc_label.text = item["description"]
	desc_label.theme_override_font_sizes["font_size"] = 12
	desc_label.theme_override_colors["font_color"] = Color(0.8, 0.8, 0.8)
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	# Purchase button
	var purchase_button = Button.new()
	purchase_button.custom_minimum_size = Vector2(0, 30)
	
	# Check if already purchased
	var item_key = category + "_" + item["id"]
	if purchased_items.has(item_key):
		purchase_button.text = "✓ OWNED"
		purchase_button.disabled = true
		purchase_button.theme_override_colors["font_color"] = Color.GREEN
	else:
		purchase_button.text = "💰 " + str(item["price"])
		purchase_button.disabled = current_currency < item["price"]
		if purchase_button.disabled:
			purchase_button.theme_override_colors["font_color"] = Color.RED
		else:
			purchase_button.theme_override_colors["font_color"] = Color.WHITE
	
	# Connect purchase signal
	purchase_button.pressed.connect(_on_item_purchased.bind(item, category))
	
	# Add to containers
	info_container.add_child(name_label)
	info_container.add_child(desc_label)
	info_container.add_child(purchase_button)
	item_panel.add_child(info_container)
	item_container.add_child(item_panel)
	
	return item_container

func _on_item_purchased(item: Dictionary, category: String):
	"""Handle item purchase"""
	var item_key = category + "_" + item["id"]
	var price = item["price"]
	
	if current_currency >= price and not purchased_items.has(item_key):
		# Deduct currency
		current_currency -= price
		
		# Mark as purchased
		purchased_items[item_key] = true
		
		# Save data
		save_shop_data()
		
		# Update UI
		update_currency_display()
		refresh_shop_items()
		
		# Emit signal for game to handle
		emit_signal("purchase_made", category, item["id"])
		
		print("Purchased: ", item["name"], " for ", price, " coins")

func refresh_shop_items():
	"""Refresh all shop item displays"""
	# Clear existing items
	for child in skins_grid.get_children():
		child.queue_free()
	for child in upgrades_grid.get_children():
		child.queue_free()
	for child in powerups_grid.get_children():
		child.queue_free()
	
	# Repopulate
	call_deferred("populate_shop_items")

func _on_back_button_pressed():
	"""Return to main menu"""
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func set_currency(amount: int):
	"""Set current currency amount (called from main menu)"""
	current_currency = amount
	update_currency_display()
