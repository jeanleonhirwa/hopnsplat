extends Control

## Test script for AchievementCard component
## Demonstrates locked, unlocked, and progressive achievement states

@onready var locked_card = $VBoxContainer/LockedCard
@onready var unlocked_card = $VBoxContainer/UnlockedCard
@onready var progressive_card = $VBoxContainer/ProgressiveCard
@onready var unlock_button = $VBoxContainer/ButtonContainer/UnlockButton
@onready var progress_button = $VBoxContainer/ButtonContainer/ProgressButton


func _ready() -> void:
	# Connect button signals
	unlock_button.pressed.connect(_on_unlock_button_pressed)
	progress_button.pressed.connect(_on_progress_button_pressed)
	
	# Connect achievement unlocked signals
	locked_card.achievement_unlocked.connect(_on_achievement_unlocked)
	progressive_card.achievement_unlocked.connect(_on_achievement_unlocked)
	
	print("AchievementCard test scene loaded")
	print("- Locked card: ", locked_card.achievement_title)
	print("- Unlocked card: ", unlocked_card.achievement_title)
	print("- Progressive card: ", progressive_card.achievement_title, " (", progressive_card.current_progress, "/", progressive_card.max_progress, ")")


func _on_unlock_button_pressed() -> void:
	"""Unlock the first locked achievement."""
	if locked_card.is_locked:
		print("Unlocking: ", locked_card.achievement_title)
		locked_card.unlock_achievement()
	else:
		print("Achievement already unlocked!")


func _on_progress_button_pressed() -> void:
	"""Add progress to the progressive achievement."""
	var new_progress = progressive_card.current_progress + 100
	print("Adding progress to: ", progressive_card.achievement_title, " (", new_progress, "/", progressive_card.max_progress, ")")
	progressive_card.set_progress(new_progress)


func _on_achievement_unlocked(achievement_id: String) -> void:
	"""Handle achievement unlock event."""
	print("Achievement unlocked: ", achievement_id)
