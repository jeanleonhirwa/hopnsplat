extends Control

# Achievements Menu - Display all achievements with progress

@onready var back_button = $VBoxContainer/HeaderContainer/BackButton
@onready var progress_label = $VBoxContainer/HeaderContainer/ProgressPanel/HBoxContainer/ProgressLabel
@onready var achievements_list = $VBoxContainer/ScrollContainer/AchievementsList

var achievement_system: Node

# Preload AchievementCard scene
const AchievementCardScene = preload("res://scenes/components/AchievementCard.tscn")

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
	
	# Create achievement cards
	for achievement in achievements:
		_create_achievement_card(achievement)

func _create_achievement_card(achievement: Dictionary):
	"""Create AchievementCard for an achievement"""
	var card = AchievementCardScene.instantiate()
	
	# Set achievement data
	var icon_texture = _get_achievement_icon(achievement.icon)
	var is_progressive = achievement.has("target") and achievement.target > 1
	var max_progress = achievement.target if is_progressive else 1
	
	card.set_achievement_data(
		achievement.id,
		achievement.name,
		achievement.description,
		icon_texture,
		is_progressive,
		max_progress
	)
	
	# Set locked/unlocked state
	card.set_locked(not achievement.unlocked)
	
	# Set progress for progressive achievements
	if is_progressive:
		card.set_progress(achievement.progress)
	
	# Connect unlock signal
	card.achievement_unlocked.connect(_on_achievement_unlocked)
	
	# Add to list
	achievements_list.add_child(card)

func _get_achievement_icon(icon_emoji: String) -> Texture2D:
	"""Convert emoji icon to texture (placeholder implementation)"""
	# For now, use star icon as default
	# In a full implementation, you would map emojis to specific textures
	return load("res://assets/ui_packs/Yellow/Default/star.png")

func _on_achievement_unlocked(achievement_id: String):
	"""Handle achievement unlock event"""
	print("Achievement unlocked: ", achievement_id)
	# Refresh the display
	_load_achievements()

func _on_back_pressed():
	"""Handle back button press"""
	# Return to main menu
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
