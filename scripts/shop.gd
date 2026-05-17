extends Control

# Shop System for Hop n' Splat
signal purchase_made(item_type: String, item_id: String)

# UI References
@onready var currency_label = $VBoxContainer/HeaderContainer/CurrencyPanel/HBoxContainer/CurrencyLabel
@onready var currency_panel = $VBoxContainer/HeaderContainer/CurrencyPanel
@onready var tab_container = $VBoxContainer/TabContainer
@onready var skins_grid = $"VBoxContainer/TabContainer/Player Skins/SkinsGrid"
@onready var upgrades_grid = $"VBoxContainer/TabContainer/Boost Upgrades/UpgradesGrid"
@onready var powerups_grid = $"VBoxContainer/TabContainer/Power-ups/PowerupsGrid"
@onready var insufficient_funds_label = $InsufficientFundsLabel
@onready var confirm_dialog = $ConfirmDialog
@onready var confirm_title_label = $ConfirmDialog/DialogPanel/DialogVBox/TitleLabel
@onready var confirm_desc_label = $ConfirmDialog/DialogPanel/DialogVBox/DescriptionLabel

# ShopItemCard scene
var shop_item_card_scene = preload("res://scenes/components/ShopItemCard.tscn")

# Shop Data
var current_currency: int = 0
var purchased_items: Dictionary = {}

# Pending purchase (for confirmation dialog)
var _pending_item: Dictionary = {}
var _pending_category: String = ""
var _pending_card: ShopItemCard = null

# Insufficient funds tween reference
var _insufficient_funds_tween: Tween

# Item definitions
var shop_items = {
	"skins": [
		{"id": "alien_blue", "name": "Blue Alien", "price": 50, "description": "Cool blue variant", "icon": "res://assets/player/alienPink_stand.png", "color": Color(0.2, 0.5, 1.0)},
		{"id": "alien_green", "name": "Green Alien", "price": 75, "description": "Nature-loving alien", "icon": "res://assets/player/alienPink_stand.png", "color": Color(0.4, 0.9, 0.4)},
		{"id": "alien_red", "name": "Red Alien", "price": 100, "description": "Fiery red alien", "icon": "res://assets/player/alienPink_stand.png", "color": Color(1.0, 0.3, 0.3)},
		{"id": "alien_gold", "name": "Golden Alien", "price": 200, "description": "Legendary golden skin", "icon": "res://assets/player/alienPink_stand.png", "color": Color(1.0, 0.8, 0.1)}
	],
	"upgrades": [
		{"id": "jump_duration", "name": "Jump Boost+", "price": 150, "description": "Jump boost lasts 2x longer", "icon": "res://assets/ui_packs/Yellow/Default/arrow_decorative_n.png"},
		{"id": "speed_duration", "name": "Speed Boost+", "price": 120, "description": "Speed boost lasts 2x longer", "icon": "res://assets/ui_packs/Yellow/Default/arrow_decorative_e.png"},
		{"id": "shield_extra", "name": "Double Shield", "price": 180, "description": "Shield blocks 2 hits instead of 1", "icon": "res://assets/ui_packs/Yellow/Default/button_round_depth_border.png"},
		{"id": "magnet_range", "name": "Super Magnet", "price": 100, "description": "Coin magnet has 2x range", "icon": "res://assets/ui_packs/Yellow/Default/icon_circle.png"}
	],
	"powerups": [
		{"id": "start_jump", "name": "Jump Start", "price": 80, "description": "Start each game with jump boost", "icon": "res://assets/ui_packs/Yellow/Default/arrow_basic_n.png"},
		{"id": "start_shield", "name": "Shield Start", "price": 120, "description": "Start each game with shield", "icon": "res://assets/ui_packs/Yellow/Default/icon_outline_square.png"},
		{"id": "coin_multiplier", "name": "Coin Luck", "price": 250, "description": "Earn 2x coins from jumps", "icon": "res://assets/ui_packs/Yellow/Default/star.png"}
	]
}

func _ready():
	load_shop_data()
	update_currency_display()
	populate_shop_items()
	
	# Connect tab_changed signal for slide-in animation
	tab_container.tab_changed.connect(_on_tab_changed)
	
	# Style the tab container to match Kenney UI
	_style_tab_container()

func _style_tab_container():
	"""Style the tab container to match the Kenney UI design system."""
	# Create active tab style
	var tab_active = StyleBoxFlat.new()
	tab_active.bg_color = Color(0.98, 0.85, 0.37, 1.0)  # Kenney yellow
	tab_active.corner_radius_top_left = 8
	tab_active.corner_radius_top_right = 8
	tab_active.corner_radius_bottom_left = 0
	tab_active.corner_radius_bottom_right = 0
	tab_active.content_margin_left = 12
	tab_active.content_margin_right = 12
	tab_active.content_margin_top = 8
	tab_active.content_margin_bottom = 8
	
	# Create inactive tab style
	var tab_inactive = StyleBoxFlat.new()
	tab_inactive.bg_color = Color(0.85, 0.85, 0.85, 0.6)
	tab_inactive.corner_radius_top_left = 8
	tab_inactive.corner_radius_top_right = 8
	tab_inactive.corner_radius_bottom_left = 0
	tab_inactive.corner_radius_bottom_right = 0
	tab_inactive.content_margin_left = 12
	tab_inactive.content_margin_right = 12
	tab_inactive.content_margin_top = 8
	tab_inactive.content_margin_bottom = 8
	
	# Create disabled tab style (same as inactive)
	var tab_disabled = tab_inactive.duplicate()
	tab_disabled.bg_color = Color(0.7, 0.7, 0.7, 0.4)
	
	# Create hover tab style
	var tab_hover = tab_inactive.duplicate()
	tab_hover.bg_color = Color(0.92, 0.8, 0.35, 0.7)
	
	# Create panel style for the tab content area
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(1, 1, 1, 0.15)
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel_style.content_margin_left = 8
	panel_style.content_margin_right = 8
	panel_style.content_margin_top = 10
	panel_style.content_margin_bottom = 10
	
	tab_container.add_theme_stylebox_override("tab_selected", tab_active)
	tab_container.add_theme_stylebox_override("tab_unselected", tab_inactive)
	tab_container.add_theme_stylebox_override("tab_disabled", tab_disabled)
	tab_container.add_theme_stylebox_override("tab_hovered", tab_hover)
	tab_container.add_theme_stylebox_override("panel", panel_style)

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
	
	# Add pulse effect when currency changes
	if current_currency > 0:
		await get_tree().create_timer(0.5).timeout
		UIAnimationManager.pulse(currency_label, 0.2, 1.15)


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
	"""Create shop item cards for each category using ShopItemCard component"""
	_create_category_items("skins", skins_grid)
	_create_category_items("upgrades", upgrades_grid)
	_create_category_items("powerups", powerups_grid)

func _create_category_items(category: String, grid: Control):
	"""Create ShopItemCard instances for a category and add to grid."""
	for item in shop_items[category]:
		var card = shop_item_card_scene.instantiate() as ShopItemCard
		
		# Set properties BEFORE add_child so _ready() uses correct data
		card.item_id = item["id"]
		card.item_name = item["name"]
		card.item_description = item["description"]
		card.item_price = item["price"]
		card.custom_minimum_size = Vector2(0, 130)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		# Check if already purchased
		var item_key = category + "_" + item["id"]
		if purchased_items.has(item_key):
			card.is_purchased = true
		
		# Add to tree — _ready() fires here with default data
		grid.add_child(card)
		
		# Load icon and set item data to force UI update with correct text and images
		var icon_tex = null
		if item.has("icon") and item["icon"] != "":
			icon_tex = load(item["icon"])
			
		var icon_color = Color.WHITE
		if item.has("color"):
			icon_color = item["color"]
			
		card.set_item_data(item["id"], item["name"], item["description"], item["price"], icon_tex, icon_color)
		
		# Override the card's internal button handler with our confirmation flow
		if card.purchase_button:
			if card.purchase_button.pressed.is_connected(card._on_purchase_button_pressed):
				card.purchase_button.pressed.disconnect(card._on_purchase_button_pressed)
			card.purchase_button.pressed.connect(_on_card_button_pressed.bind(card, item, category))

func _on_card_button_pressed(card: ShopItemCard, item: Dictionary, category: String):
	"""Handle direct button press on a shop card — routes to confirm or equip."""
	if card.is_purchased:
		# Already owned — equip it
		emit_signal("purchase_made", category, item["id"])
		return
	
	var price = item["price"]
	
	# Check if player has enough currency
	if current_currency < price:
		_show_insufficient_funds()
		return
	
	# Store pending purchase and show confirmation dialog
	_pending_item = item
	_pending_category = category
	_pending_card = card
	_show_confirm_dialog(item["name"], price)



func _show_confirm_dialog(item_name: String, price: int):
	"""Show the purchase confirmation dialog."""
	confirm_desc_label.text = "Buy " + item_name + " for " + str(price) + " coins?"
	confirm_dialog.visible = true
	
	# Animate dialog in
	var dialog_panel = confirm_dialog.get_node("DialogPanel")
	if dialog_panel:
		dialog_panel.scale = Vector2(0.8, 0.8)
		dialog_panel.modulate.a = 0.0
		var tween = create_tween().set_parallel(true)
		tween.tween_property(dialog_panel, "scale", Vector2(1.0, 1.0), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(dialog_panel, "modulate:a", 1.0, 0.15)

func _on_confirm_cancel():
	"""Cancel the pending purchase."""
	_pending_item = {}
	_pending_category = ""
	_pending_card = null
	_hide_confirm_dialog()

func _on_confirm_buy():
	"""Confirm and execute the pending purchase."""
	if _pending_item.is_empty():
		_hide_confirm_dialog()
		return
	
	var item = _pending_item
	var category = _pending_category
	var card = _pending_card
	var item_key = category + "_" + item["id"]
	var price = item["price"]
	
	# Double-check affordability
	if current_currency < price:
		_pending_item = {}
		_pending_category = ""
		_pending_card = null
		_hide_confirm_dialog()
		_show_insufficient_funds()
		return
	
	# Execute purchase
	if _purchase_item(item_key, price):
		print("Purchased: ", item["name"], " for ", price, " coins")
		
		# Update the card to show purchased state
		if card and is_instance_valid(card):
			card.set_purchased(true)
		
		# Track first purchase achievement
		var achievement_system = get_node_or_null("/root/AchievementSystem")
		if achievement_system:
			achievement_system.track_special_event("first_purchase")
		
		# Emit signal for game to handle
		emit_signal("purchase_made", category, item["id"])
	
	# Clear pending and hide dialog
	_pending_item = {}
	_pending_category = ""
	_pending_card = null
	_hide_confirm_dialog()

func _hide_confirm_dialog():
	"""Hide the confirmation dialog with animation."""
	var dialog_panel = confirm_dialog.get_node("DialogPanel")
	if dialog_panel:
		var tween = create_tween().set_parallel(true)
		tween.tween_property(dialog_panel, "scale", Vector2(0.8, 0.8), 0.15).set_ease(Tween.EASE_IN)
		tween.tween_property(dialog_panel, "modulate:a", 0.0, 0.15)
		await tween.finished
	confirm_dialog.visible = false

func _show_insufficient_funds():
	"""Show 'Not enough coins!' feedback with shake and fade."""
	# Shake the currency panel
	if currency_panel:
		var original_pos = currency_panel.position
		var shake_tween = create_tween()
		shake_tween.tween_property(currency_panel, "position:x", original_pos.x + 8, 0.05)
		shake_tween.tween_property(currency_panel, "position:x", original_pos.x - 8, 0.05)
		shake_tween.tween_property(currency_panel, "position:x", original_pos.x + 5, 0.05)
		shake_tween.tween_property(currency_panel, "position:x", original_pos.x - 5, 0.05)
		shake_tween.tween_property(currency_panel, "position:x", original_pos.x, 0.05)
	
	# Show and animate the insufficient funds label
	if insufficient_funds_label:
		# Kill existing tween if running
		if _insufficient_funds_tween and _insufficient_funds_tween.is_valid():
			_insufficient_funds_tween.kill()
		
		insufficient_funds_label.visible = true
		insufficient_funds_label.modulate.a = 1.0
		
		# Pop in
		insufficient_funds_label.scale = Vector2(0.5, 0.5)
		_insufficient_funds_tween = create_tween()
		_insufficient_funds_tween.tween_property(insufficient_funds_label, "scale", Vector2(1.0, 1.0), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		_insufficient_funds_tween.tween_interval(1.5)
		_insufficient_funds_tween.tween_property(insufficient_funds_label, "modulate:a", 0.0, 0.4)
		await _insufficient_funds_tween.finished
		insufficient_funds_label.visible = false

func animate_currency_update(old_value: int, new_value: int) -> void:
	"""Animate the currency count-up when a purchase is made."""
	if not currency_label or not is_instance_valid(currency_label):
		return
	
	# Simple count-up animation using our own tween
	_count_up_with_prefix(currency_label, "Coins: ", old_value, new_value, 0.3)
	
	# Add a pulse effect to the currency panel
	if currency_panel and is_instance_valid(currency_panel):
		# Flash red and shake slightly
		UIAnimationManager.pulse(currency_panel, 0.2, 1.05)

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
	"""Handle tab switching with fade-in animation"""
	# Get the current tab content
	var current_tab = tab_container.get_child(tab_index)
	
	if current_tab:
		# Reset modulate alpha and animate fade-in
		current_tab.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(current_tab, "modulate:a", 1.0, 0.25).set_ease(Tween.EASE_OUT)

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
