class_name ShopItemCard
extends KenneyPanel

## ShopItemCard Component
## A reusable card component for displaying shop items with icon, name, description, price, and purchase button.
## Supports showing equipped state with a checkmark icon.

# Item data properties
@export var item_id: String = ""
@export var item_name: String = "Item Name"
@export var item_description: String = "Item description goes here"
@export var item_price: int = 100
@export var item_icon: Texture2D
@export var is_purchased: bool = false
@export var is_equipped: bool = false

# Child node references
var item_icon_node: TextureRect
var item_name_label: Label
var item_description_label: Label
var price_panel: KenneyPanel
var coin_icon_node: TextureRect
var price_label: Label
var purchase_button: KenneyButton
var equipped_checkmark: TextureRect

# Signals
signal purchase_requested(item_id: String)
signal equip_requested(item_id: String)


func _ready() -> void:
	super._ready()
	
	# Set up the card panel style
	panel_style = PanelStyle.RECTANGLE_DEPTH
	color_pack = ColorPack.YELLOW
	
	# Build the card UI
	_setup_card_ui()
	
	# Update UI based on initial state
	_update_ui_state()


func _setup_card_ui() -> void:
	"""Build the shop item card UI structure."""
	# Create main container
	var main_container = VBoxContainer.new()
	main_container.name = "MainContainer"
	main_container.anchor_left = 0.0
	main_container.anchor_top = 0.0
	main_container.anchor_right = 1.0
	main_container.anchor_bottom = 1.0
	main_container.offset_left = 10
	main_container.offset_top = 10
	main_container.offset_right = -10
	main_container.offset_bottom = -10
	add_child(main_container)
	
	# Create top section (icon + info)
	var top_section = HBoxContainer.new()
	top_section.name = "TopSection"
	top_section.custom_minimum_size = Vector2(0, 80)
	main_container.add_child(top_section)
	
	# Item icon
	item_icon_node = TextureRect.new()
	item_icon_node.name = "ItemIcon"
	item_icon_node.custom_minimum_size = Vector2(64, 64)
	item_icon_node.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	item_icon_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if item_icon:
		item_icon_node.texture = item_icon
	top_section.add_child(item_icon_node)
	
	# Add spacer
	var spacer1 = Control.new()
	spacer1.custom_minimum_size = Vector2(10, 0)
	top_section.add_child(spacer1)
	
	# Info container (name + description)
	var info_container = VBoxContainer.new()
	info_container.name = "InfoContainer"
	info_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_section.add_child(info_container)
	
	# Item name
	item_name_label = Label.new()
	item_name_label.name = "ItemName"
	item_name_label.text = item_name
	item_name_label.add_theme_font_size_override("font_size", 18)
	item_name_label.add_theme_color_override("font_color", Color.WHITE)
	info_container.add_child(item_name_label)
	
	# Item description
	item_description_label = Label.new()
	item_description_label.name = "ItemDescription"
	item_description_label.text = item_description
	item_description_label.add_theme_font_size_override("font_size", 12)
	item_description_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))
	item_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_container.add_child(item_description_label)
	
	# Add spacer
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 5)
	main_container.add_child(spacer2)
	
	# Bottom section (price + button)
	var bottom_section = HBoxContainer.new()
	bottom_section.name = "BottomSection"
	main_container.add_child(bottom_section)
	
	# Price panel
	price_panel = KenneyPanel.new()
	price_panel.name = "PricePanel"
	price_panel.panel_style = KenneyPanel.PanelStyle.RECTANGLE
	price_panel.color_pack = KenneyPanel.ColorPack.YELLOW
	price_panel.custom_minimum_size = Vector2(100, 40)
	bottom_section.add_child(price_panel)
	
	# Price container inside panel
	var price_container = HBoxContainer.new()
	price_container.name = "PriceContainer"
	price_container.anchor_left = 0.0
	price_container.anchor_top = 0.5
	price_container.anchor_right = 1.0
	price_container.anchor_bottom = 0.5
	price_container.offset_top = -15
	price_container.offset_bottom = 15
	price_container.offset_left = 5
	price_container.offset_right = -5
	price_container.alignment = BoxContainer.ALIGNMENT_CENTER
	price_panel.add_child(price_container)
	
	# Coin icon (using star icon as placeholder since there's no coin icon)
	coin_icon_node = TextureRect.new()
	coin_icon_node.name = "CoinIcon"
	coin_icon_node.custom_minimum_size = Vector2(24, 24)
	coin_icon_node.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	coin_icon_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	coin_icon_node.texture = load("res://assets/ui_packs/Yellow/Default/star.png")
	price_container.add_child(coin_icon_node)
	
	# Price label
	price_label = Label.new()
	price_label.name = "PriceLabel"
	price_label.text = str(item_price)
	price_label.add_theme_font_size_override("font_size", 16)
	price_label.add_theme_color_override("font_color", Color.WHITE)
	price_container.add_child(price_label)
	
	# Add spacer
	var spacer3 = Control.new()
	spacer3.custom_minimum_size = Vector2(10, 0)
	spacer3.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_section.add_child(spacer3)
	
	# Purchase button
	purchase_button = KenneyButton.new()
	purchase_button.name = "PurchaseButton"
	purchase_button.button_style = KenneyButton.ButtonStyle.RECTANGLE_DEPTH_GLOSS
	purchase_button.color_pack = KenneyButton.ColorPack.YELLOW
	purchase_button.button_text = "Buy"
	purchase_button.custom_minimum_size = Vector2(100, 44)
	purchase_button.pressed.connect(_on_purchase_button_pressed)
	bottom_section.add_child(purchase_button)
	
	# Equipped checkmark (hidden by default)
	equipped_checkmark = TextureRect.new()
	equipped_checkmark.name = "EquippedCheckmark"
	equipped_checkmark.texture = load("res://assets/ui_packs/Yellow/Default/icon_checkmark.png")
	equipped_checkmark.custom_minimum_size = Vector2(32, 32)
	equipped_checkmark.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	equipped_checkmark.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	equipped_checkmark.anchor_left = 1.0
	equipped_checkmark.anchor_top = 0.0
	equipped_checkmark.anchor_right = 1.0
	equipped_checkmark.anchor_bottom = 0.0
	equipped_checkmark.offset_left = -42
	equipped_checkmark.offset_top = 10
	equipped_checkmark.offset_right = -10
	equipped_checkmark.offset_bottom = 42
	equipped_checkmark.visible = false
	add_child(equipped_checkmark)


func _update_ui_state() -> void:
	"""Update the UI based on purchase and equipped state."""
	if is_purchased:
		# Change button to "Equip" or "Equipped"
		if is_equipped:
			purchase_button.button_text = "Equipped"
			purchase_button.disabled = true
			equipped_checkmark.visible = true
		else:
			purchase_button.button_text = "Equip"
			purchase_button.disabled = false
			equipped_checkmark.visible = false
		
		# Hide price panel when purchased
		price_panel.visible = false
	else:
		# Show "Buy" button and price
		purchase_button.button_text = "Buy"
		purchase_button.disabled = false
		price_panel.visible = true
		equipped_checkmark.visible = false


func _on_purchase_button_pressed() -> void:
	"""Handle purchase or equip button press."""
	if is_purchased:
		# Emit equip signal
		equip_requested.emit(item_id)
	else:
		# Play purchase animation sequence before emitting signal
		await play_purchase_animation()
		# Emit purchase signal after animation
		purchase_requested.emit(item_id)


# Public API methods

func set_item_data(id: String, item_name_text: String, description: String, price: int, icon: Texture2D) -> void:
	"""Set the item data for this card."""
	item_id = id
	item_name = item_name_text
	item_description = description
	item_price = price
	item_icon = icon
	
	# Update UI if nodes exist
	if item_name_label:
		item_name_label.text = item_name
	if item_description_label:
		item_description_label.text = item_description
	if price_label:
		price_label.text = str(item_price)
	if item_icon_node:
		item_icon_node.texture = item_icon


func set_purchased(purchased: bool) -> void:
	"""Set the purchased state of this item."""
	is_purchased = purchased
	_update_ui_state()


func set_equipped(equipped: bool) -> void:
	"""Set the equipped state of this item."""
	is_equipped = equipped
	_update_ui_state()


func play_purchase_animation() -> void:
	"""Play the purchase celebration animation sequence."""
	# Task 6.5: Purchase animation sequence
	# 1. Button press animation (0.1s)
	# 2. Coin icon flies from item to header currency display (0.5s with arc motion)
	# 3. Currency count-up animation (0.3s)
	# 4. Checkmark appears with pop-out animation (0.2s)
	# 5. Spawn particle burst at item location using star textures
	
	# 1. Button press animation (0.1s)
	UIAnimationManager.squash(purchase_button, 0.1)
	await get_tree().create_timer(0.1).timeout
	
	# Play purchase sound
	AudioManager.play_ui_click()
	
	# 2. Coin icon flies from item to header currency display (0.5s with arc motion)
	await _animate_coin_fly()
	
	# 3. Currency count-up animation (0.3s) - handled by Shop script
	# The Shop script will handle updating the currency display
	
	# 4. Checkmark appears with pop-out animation (0.2s)
	equipped_checkmark.visible = true
	equipped_checkmark.scale = Vector2.ZERO
	UIAnimationManager.pop_out(equipped_checkmark, 0.2)
	
	# 5. Spawn particle burst at item location using star textures
	_spawn_purchase_particles()
	
	# Update the card state to purchased
	set_purchased(true)


func _animate_coin_fly() -> void:
	"""Animate a coin flying from the item to the currency display in the header."""
	# Create a temporary coin icon for the animation
	var flying_coin = TextureRect.new()
	flying_coin.texture = load("res://assets/ui_packs/Yellow/Default/star.png")
	flying_coin.custom_minimum_size = Vector2(32, 32)
	flying_coin.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	flying_coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# Find the Shop node (traverse up the tree)
	var shop_node = get_tree().current_scene
	if shop_node and shop_node.name == "Shop":
		shop_node.add_child(flying_coin)
		
		# Get the global position of the coin icon in the price panel
		var start_pos = coin_icon_node.global_position
		
		# Get the global position of the currency display in the header
		var currency_icon = shop_node.get_node_or_null("VBoxContainer/HeaderContainer/CurrencyPanel/HBoxContainer/CoinIcon")
		var end_pos = currency_icon.global_position if currency_icon else start_pos + Vector2(0, -200)
		
		# Set initial position
		flying_coin.global_position = start_pos
		
		# Create arc motion using a tween with custom interpolation
		var tween = create_tween()
		tween.set_parallel(true)
		
		# Animate X position linearly
		tween.tween_property(flying_coin, "global_position:x", end_pos.x, 0.5).set_ease(Tween.EASE_IN_OUT)
		
		# Animate Y position with arc (ease out then ease in for parabolic motion)
		var mid_y = min(start_pos.y, end_pos.y) - 100  # Arc peak 100 pixels above
		tween.tween_method(
			func(t: float):
				# Quadratic bezier curve for arc motion
				var p0 = start_pos.y
				var p1 = mid_y
				var p2 = end_pos.y
				var y = (1-t)*(1-t)*p0 + 2*(1-t)*t*p1 + t*t*p2
				flying_coin.global_position.y = y,
			0.0, 1.0, 0.5
		).set_ease(Tween.EASE_IN_OUT)
		
		# Add a slight rotation during flight
		tween.tween_property(flying_coin, "rotation_degrees", 360, 0.5).set_ease(Tween.EASE_IN_OUT)
		
		# Scale down slightly during flight
		tween.tween_property(flying_coin, "scale", Vector2(0.7, 0.7), 0.25).set_ease(Tween.EASE_OUT)
		tween.tween_property(flying_coin, "scale", Vector2(1.2, 1.2), 0.25).set_ease(Tween.EASE_IN).set_delay(0.25)
		
		# Wait for animation to complete
		await tween.finished
		
		# Trigger currency count-up animation in Shop
		if shop_node.has_method("animate_currency_update"):
			var old_currency = shop_node.current_currency + item_price  # Before purchase
			var new_currency = shop_node.current_currency  # After purchase
			shop_node.animate_currency_update(old_currency, new_currency)
		
		# Cleanup the flying coin
		flying_coin.queue_free()
	else:
		# If we can't find the shop node, just wait for the duration
		await get_tree().create_timer(0.5).timeout


func _spawn_purchase_particles() -> void:
	"""Spawn a particle burst at the item location using star textures."""
	# Create particle system
	var particles = CPUParticles2D.new()
	
	# Add to the card
	add_child(particles)
	
	# Position at center of card
	particles.position = size / 2
	
	# Configure particle properties
	particles.emitting = false
	particles.amount = 25
	particles.lifetime = 0.8
	particles.one_shot = true
	particles.explosiveness = 1.0
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
	
	# Auto-cleanup after lifetime
	await get_tree().create_timer(particles.lifetime + 0.1).timeout
	particles.queue_free()
