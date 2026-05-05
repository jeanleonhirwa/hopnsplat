extends Control
## Test script for ShopItemCard purchase animation
## This script simulates the Shop behavior for testing the purchase animation sequence

var current_currency: int = 500

@onready var currency_label = $VBoxContainer/HeaderContainer/CurrencyPanel/HBoxContainer/CurrencyLabel
@onready var item_card_1 = $VBoxContainer/ItemsContainer/ShopItemCard1
@onready var item_card_2 = $VBoxContainer/ItemsContainer/ShopItemCard2


func _ready() -> void:
	# Connect purchase signals from item cards
	if item_card_1:
		item_card_1.purchase_requested.connect(_on_item_purchase_requested)
	if item_card_2:
		item_card_2.purchase_requested.connect(_on_item_purchase_requested)
	
	update_currency_display()
	print("Test Shop Item Card scene ready - Currency: ", current_currency)


func _on_item_purchase_requested(item_id: String) -> void:
	"""Handle purchase request from an item card."""
	print("Purchase requested for item: ", item_id)
	
	# Find the item card that made the request
	var item_card = null
	if item_card_1 and item_card_1.item_id == item_id:
		item_card = item_card_1
	elif item_card_2 and item_card_2.item_id == item_id:
		item_card = item_card_2
	
	if not item_card:
		print("Item card not found for id: ", item_id)
		return
	
	# Check if player has enough currency
	if current_currency < item_card.item_price:
		print("Not enough currency! Need: ", item_card.item_price, " Have: ", current_currency)
		return
	
	# Deduct the price
	var old_currency = current_currency
	current_currency -= item_card.item_price
	
	print("Purchase successful! Old currency: ", old_currency, " New currency: ", current_currency)
	
	# The animation will be triggered by the item card itself
	# We just need to update the currency display after the coin flies
	# Wait a bit for the coin to reach the currency display
	await get_tree().create_timer(0.5).timeout
	
	# Animate the currency count-up
	animate_currency_update(old_currency, current_currency)


func animate_currency_update(old_value: int, new_value: int) -> void:
	"""Animate the currency count-up when a purchase is made."""
	# Use UIAnimationManager to count up from old to new value
	UIAnimationManager.count_up(currency_label, old_value, new_value, 0.3)
	
	# Add a bounce effect to the currency panel
	var currency_panel = $VBoxContainer/HeaderContainer/CurrencyPanel
	if currency_panel:
		UIAnimationManager.bounce_in(currency_panel, 0.2, 1.05)


func update_currency_display() -> void:
	"""Update the currency label text."""
	if currency_label:
		currency_label.text = "Coins: " + str(current_currency)
