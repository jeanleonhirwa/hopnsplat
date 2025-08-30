extends Control

# Achievements Menu - Display all achievements with progress

@onready var back_button = $VBoxContainer/HeaderContainer/BackButton
@onready var progress_label = $VBoxContainer/HeaderContainer/ProgressLabel
@onready var achievements_list = $VBoxContainer/ScrollContainer/AchievementsList

var achievement_system: Node

func _ready():
	"""Initialize achievements menu"""
	# Connect back button
	back_button.pressed.connect(_on_back_pressed)
	
	# Get achievement system
	achievement_system = get_node("/root/AchievementSystem")
	
	# Load and display achievements
	_load_achievements()

func _load_achievements():
	"""Load and display all achievements"""
	if not achievement_system:
		print("Achievement system not found")
		return
	
	var achievements = achievement_system.get_all_achievements()
	var unlocked_count = achievement_system.get_unlocked_count()
	var total_count = achievement_system.get_total_count()
	
	# Update progress label
	progress_label.text = str(unlocked_count) + "/" + str(total_count)
	
	# Clear existing items
	for child in achievements_list.get_children():
		child.queue_free()
	
	# Create achievement items
	for achievement in achievements:
		_create_achievement_item(achievement)

func _create_achievement_item(achievement: Dictionary):
	"""Create UI item for an achievement"""
	var item_container = HBoxContainer.new()
	item_container.custom_minimum_size = Vector2(0, 80)
	
	# Icon
	var icon_label = Label.new()
	icon_label.text = achievement.icon
	icon_label.custom_minimum_size = Vector2(60, 0)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_label.add_theme_font_size_override("font_size", 32)
	
	# Content container
	var content_container = VBoxContainer.new()
	content_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Name label
	var name_label = Label.new()
	name_label.text = achievement.name
	name_label.add_theme_font_size_override("font_size", 18)
	if achievement.unlocked:
		name_label.add_theme_color_override("font_color", Color.GOLD)
	else:
		name_label.add_theme_color_override("font_color", Color.WHITE)
	
	# Description label
	var desc_label = Label.new()
	desc_label.text = achievement.description
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	# Progress container
	var progress_container = HBoxContainer.new()
	
	# Progress bar
	var progress_bar = ProgressBar.new()
	progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	progress_bar.custom_minimum_size = Vector2(200, 20)
	progress_bar.max_value = 100
	progress_bar.value = achievement.progress_percent
	
	# Progress text
	var progress_text = Label.new()
	if achievement.unlocked:
		progress_text.text = "UNLOCKED!"
		progress_text.add_theme_color_override("font_color", Color.GOLD)
	else:
		progress_text.text = str(achievement.progress) + "/" + str(achievement.target)
		progress_text.add_theme_color_override("font_color", Color.WHITE)
	progress_text.add_theme_font_size_override("font_size", 12)
	
	# Reward label
	var reward_label = Label.new()
	if achievement.reward > 0:
		reward_label.text = "🪙 " + str(achievement.reward)
		reward_label.add_theme_color_override("font_color", Color.YELLOW)
		reward_label.add_theme_font_size_override("font_size", 12)
	
	# Assemble UI
	progress_container.add_child(progress_bar)
	progress_container.add_child(progress_text)
	if achievement.reward > 0:
		progress_container.add_child(reward_label)
	
	content_container.add_child(name_label)
	content_container.add_child(desc_label)
	content_container.add_child(progress_container)
	
	item_container.add_child(icon_label)
	item_container.add_child(content_container)
	
	# Add separator
	var separator = HSeparator.new()
	separator.add_theme_color_override("separator", Color(0.3, 0.3, 0.3, 1.0))
	
	achievements_list.add_child(item_container)
	achievements_list.add_child(separator)
	
	# Gray out if locked
	if not achievement.unlocked:
		item_container.modulate = Color(0.7, 0.7, 0.7, 1.0)

func _on_back_pressed():
	"""Handle back button press"""
	# Return to main menu
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
