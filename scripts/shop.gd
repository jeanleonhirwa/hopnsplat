extends Control

# Shop System for Hop n' Splat
signal purchase_made(item_type: String, item_id: String)

# UI References
@onready var currency_label = $VBoxContainer/HeaderContainer/CurrencyPanel/HBoxContainer/CurrencyLabel
@onready var tab_container = $VBoxContainer/TabContainer
@onready var skins_grid = $"VBoxContainer/TabContainer/Player Skins/SkinsGrid"
@onready var upgrades_grid = $"VBoxContainer/TabContainer/Boost Upgrades/UpgradesGrid"
@onready var powerups_grid = $"VBoxContainer/TabContainer/Power-ups/PowerupsGrid"

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
	
	# Connect tab_changed signal for slide-in animation
	tab_container.tab_changed.connect(_on_tab_changed)

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
	"""Update the currency label with count-up animation"""
	# Store old value for animation
	var old_value = 0
	if currency_label.text.begins_with("Coins: "):
		var old_text = currency_label.text.replace("Coins: ", "")
		old_value = int(old_text) if old_text.is_valid_int() else 0
	
	# Animate count-up
	_count_up_with_prefix(currency_label, "Coins: ", old_value, current_currency, 0.5)
	
	# Add bounce effect when currency changes
	if current_currency != old_value:
		await get_tree().create_timer(0.3).timeout
		UIAnimationManager.bounce_in(currency_label, 0.2, 1.15)


func _count_up_with_prefix(label: Label, prefix: String, from: int, to: int, duration: float):
	"""Helper function to count up a label value while preserving a prefix"""
	var tween = create_tween()
	
	# Use tween_method to interpolate and update the label
	tween.tween_method(
		func(value: float):
			label.text = prefix + str(int(value)),
		float(from),
		float(to),
		duration
	).set_ease(Tween.EASE_OUT)

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
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Item description
	var desc_label = Label.new()
	desc_label.text = item["description"]
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
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
		purchase_button.add_theme_color_override("font_color", Color.GREEN)
	else:
		purchase_button.text = "💰 " + str(item["price"])
		purchase_button.disabled = current_currency < item["price"]
		if purchase_button.disabled:
			purchase_button.add_theme_color_override("font_color", Color.RED)
		else:
			purchase_button.add_theme_color_override("font_color", Color.WHITE)
	
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
	
	# Check if player has enough currency
	if current_currency < price:
		print("Not enough currency for ", item["name"])
		return
	
	# Check if already purchased
	if purchased_items.has(item_key):
		print("Item already purchased: ", item["name"])
		return
	
	# Purchase the item
	if _purchase_item(item_key, price):
		print("Purchased: ", item["name"], " for ", price, " coins")
		
		# Track first purchase achievement
		var achievement_system = get_node("/root/AchievementSystem")
		if achievement_system:
			achievement_system.track_special_event("first_purchase")
		
		# Refresh the UI to show the purchase
		refresh_shop_items()
		
		# Emit signal for game to handle
		emit_signal("purchase_made", category, item["id"])


func animate_currency_update(old_value: int, new_value: int) -> void:
	"""Animate the currency count-up when a purchase is made."""
	# Use UIAnimationManager to count up from old to new value
	UIAnimationManager.count_up(currency_label, old_value, new_value, 0.3)
	
	# Add a bounce effect to the currency panel
	var currency_panel = $VBoxContainer/HeaderContainer/CurrencyPanel
	if currency_panel:
		UIAnimationManager.bounce_in(currency_panel, 0.2, 1.05)

func _purchase_item(item_key: String, price: int) -> bool:
	"""Purchase an item if player has enough currency"""
	if current_currency >= price:
		current_currency -= price
		purchased_items[item_key] = true
		update_currency_display()
		save_shop_data()
		return true
	return false

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


func _on_tab_changed(tab_index: int):
	"""Handle tab switching with slide-in animation"""
	# Get the current tab content
	var current_tab = tab_container.get_child(tab_index)
	
	if current_tab:
		# Apply slide-in animation from the right
		UIAnimationManager.slide_in(current_tab, Vector2.RIGHT, 0.3)

func set_currency(amount: int):
	"""Set current currency amount (called from main menu)"""
	current_currency = amount
	update_currency_display()


func spawn_celebration_particles(global_pos: Vector2) -> void:
	"""Spawn a particle burst at the specified global position for celebration events.
	
	This is a global method that can be used for various celebration events in the shop,
	such as first purchase, milestone achievements, or special unlocks.
	
	Args:
		global_pos: The global position where particles should spawn
	"""
	# Create particle system
	var particles = CPUParticles2D.new()
	
	# Add to the shop scene
	add_child(particles)
	
	# Position at the specified location
	particles.global_position = global_pos
	
	# Configure particle properties (matching Task 6.5 specifications)
	particles.emitting = false
	particles.amount = 25  # 20-30 particles as specified
	particles.lifetime = 0.8  # 0.8s lifetime as specified
	particles.one_shot = true
	particles.explosiveness = 1.0  # Explosiveness 1.0 as specified
	particles.randomness = 0.5
	
	# Set texture
	particles.texture = load("res://assets/ui_packs/Yellow/Default/star.png")
	
	# Emission shape (circle)
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 20.0
	
	# Direction and spread
	particles.direction = Vector2(0, -1)
	particles.spread = 180.0
	
	# Velocity
	particles.initial_velocity_min = 100.0
	particles.initial_velocity_max = 200.0
	
	# Gravity
	particles.gravity = Vector2(0, 300)
	
	# Scale
	particles.scale_amount_min = 0.3
	particles.scale_amount_max = 0.6
	
	# Color (yellow/gold tint)
	particles.color = Color(1.0, 0.9, 0.3, 1.0)
	
	# Fade out over lifetime
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 1, 1, 1))
	gradient.add_point(1.0, Color(1, 1, 1, 0))
	particles.color_ramp = gradient
	
	# Start emitting
	particles.emitting = true
	
	# Auto-cleanup after lifetime (as specified in task)
	await get_tree().create_timer(particles.lifetime + 0.1).timeout
	particles.queue_free()
