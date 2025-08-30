extends Control

# Achievement Notification UI - Shows popup when achievements are unlocked

@onready var notification_panel = $NotificationPanel
@onready var achievement_icon = $NotificationPanel/HBoxContainer/Icon
@onready var achievement_name = $NotificationPanel/HBoxContainer/VBoxContainer/NameLabel
@onready var achievement_description = $NotificationPanel/HBoxContainer/VBoxContainer/DescriptionLabel
@onready var reward_label = $NotificationPanel/HBoxContainer/VBoxContainer/RewardLabel

var notification_queue: Array = []
var is_showing: bool = false

func _ready():
	"""Initialize notification system"""
	# Start hidden
	visible = false
	modulate.a = 0.0
	
	# Connect to achievement system
	var achievement_system = get_node("/root/AchievementSystem")
	if achievement_system:
		achievement_system.connect("achievement_unlocked", _on_achievement_unlocked)

func _on_achievement_unlocked(_achievement_id: String, achievement_data: Dictionary):
	"""Handle achievement unlock notification"""
	print("Showing notification for achievement: ", achievement_data.name)
	
	# Add to queue
	notification_queue.append(achievement_data)
	
	# Show if not already showing
	if not is_showing:
		_show_next_notification()

func _show_next_notification():
	"""Show the next notification in queue"""
	if notification_queue.is_empty():
		is_showing = false
		return
	
	is_showing = true
	var achievement = notification_queue.pop_front()
	
	# Update UI elements
	achievement_icon.text = achievement.get("icon", "🏆")
	achievement_name.text = achievement.get("name", "Achievement")
	achievement_description.text = achievement.get("description", "")
	
	var reward = achievement.get("reward", 0)
	if reward > 0:
		reward_label.text = "+" + str(reward) + " coins"
		reward_label.visible = true
	else:
		reward_label.visible = false
	
	# Show notification with animation
	_animate_show()

func _animate_show():
	"""Animate notification appearance"""
	visible = true
	
	# Slide in from top
	notification_panel.position.y = -100
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade in
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	# Slide down
	tween.tween_property(notification_panel, "position:y", 20, 0.4)
	
	# Wait then hide
	tween.tween_delay(2.5)
	tween.tween_callback(_animate_hide)

func _animate_hide():
	"""Animate notification disappearance"""
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade out
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	# Slide up
	tween.tween_property(notification_panel, "position:y", -100, 0.3)
	
	tween.tween_callback(func():
		visible = false
		# Show next notification if any
		_show_next_notification()
	)
