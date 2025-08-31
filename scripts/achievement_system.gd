extends Node

# Achievement System - Tracks and manages player achievements
signal achievement_unlocked(achievement_id: String, achievement_data: Dictionary)

# Achievement data structure
var achievements: Dictionary = {}
var player_progress: Dictionary = {}
var unlocked_achievements: Array[String] = []

# Achievement categories
enum AchievementType {
	SCORE,
	JUMPS,
	COINS,
	SURVIVAL,
	SPECIAL,
	COMBO
}

func _ready():
	"""Initialize achievement system"""
	# Initialize empty dictionaries first
	achievements = {}
	player_progress = {}
	unlocked_achievements = []
	
	_initialize_achievements()
	_load_progress()
	print("Achievement System initialized with ", achievements.size(), " achievements")

func _initialize_achievements():
	"""Define all available achievements"""
	
	# Score Achievements
	_add_achievement("score_100", {
		"name": "First Steps",
		"description": "Reach a score of 100",
		"type": AchievementType.SCORE,
		"target": 100,
		"reward": 10,
		"icon": "🎯"
	})
	
	_add_achievement("score_500", {
		"name": "Getting Good",
		"description": "Reach a score of 500",
		"type": AchievementType.SCORE,
		"target": 500,
		"reward": 25,
		"icon": "🎯"
	})
	
	_add_achievement("score_1000", {
		"name": "High Flyer",
		"description": "Reach a score of 1,000",
		"type": AchievementType.SCORE,
		"target": 1000,
		"reward": 50,
		"icon": "🚀"
	})
	
	_add_achievement("score_5000", {
		"name": "Sky Master",
		"description": "Reach a score of 5,000",
		"type": AchievementType.SCORE,
		"target": 5000,
		"reward": 100,
		"icon": "⭐"
	})
	
	_add_achievement("score_10000", {
		"name": "Legend",
		"description": "Reach a score of 10,000",
		"type": AchievementType.SCORE,
		"target": 10000,
		"reward": 200,
		"icon": "👑"
	})
	
	# Jump Achievements
	_add_achievement("jumps_10", {
		"name": "Hopper",
		"description": "Complete 10 successful jumps in one game",
		"type": AchievementType.JUMPS,
		"target": 10,
		"reward": 15,
		"icon": "🐸"
	})
	
	_add_achievement("jumps_50", {
		"name": "Leap Master",
		"description": "Complete 50 successful jumps in one game",
		"type": AchievementType.JUMPS,
		"target": 50,
		"reward": 30,
		"icon": "🦘"
	})
	
	_add_achievement("jumps_100", {
		"name": "Jump Champion",
		"description": "Complete 100 successful jumps in one game",
		"type": AchievementType.JUMPS,
		"target": 100,
		"reward": 75,
		"icon": "🏆"
	})
	
	_add_achievement("jumps_500", {
		"name": "Unstoppable",
		"description": "Complete 500 successful jumps in one game",
		"type": AchievementType.JUMPS,
		"target": 500,
		"reward": 150,
		"icon": "💫"
	})
	
	# Coin Achievements
	_add_achievement("coins_50", {
		"name": "Penny Pincher",
		"description": "Collect 50 total coins",
		"type": AchievementType.COINS,
		"target": 50,
		"reward": 20,
		"icon": "🪙"
	})
	
	_add_achievement("coins_200", {
		"name": "Coin Collector",
		"description": "Collect 200 total coins",
		"type": AchievementType.COINS,
		"target": 200,
		"reward": 40,
		"icon": "💰"
	})
	
	_add_achievement("coins_500", {
		"name": "Treasure Hunter",
		"description": "Collect 500 total coins",
		"type": AchievementType.COINS,
		"target": 500,
		"reward": 80,
		"icon": "💎"
	})
	
	_add_achievement("coins_1000", {
		"name": "Rich Alien",
		"description": "Collect 1,000 total coins",
		"type": AchievementType.COINS,
		"target": 1000,
		"reward": 150,
		"icon": "👽"
	})
	
	# Special Achievements
	_add_achievement("first_purchase", {
		"name": "Shopaholic",
		"description": "Make your first shop purchase",
		"type": AchievementType.SPECIAL,
		"target": 1,
		"reward": 25,
		"icon": "🛒"
	})
	
	_add_achievement("ad_continue", {
		"name": "Second Chance",
		"description": "Use an ad continue for the first time",
		"type": AchievementType.SPECIAL,
		"target": 1,
		"reward": 30,
		"icon": "📺"
	})
	
	_add_achievement("perfect_10", {
		"name": "Perfect Landing",
		"description": "Land 10 jumps in a row without missing",
		"type": AchievementType.COMBO,
		"target": 10,
		"reward": 40,
		"icon": "🎪"
	})
	
	_add_achievement("perfect_25", {
		"name": "Flawless",
		"description": "Land 25 jumps in a row without missing",
		"type": AchievementType.COMBO,
		"target": 25,
		"reward": 80,
		"icon": "✨"
	})

func _add_achievement(id: String, data: Dictionary):
	"""Add an achievement to the system"""
	achievements[id] = data
	# Initialize progress tracking
	if not player_progress.has(id):
		player_progress[id] = 0

func update_progress(achievement_type: AchievementType, value: int):
	"""Update progress for achievements of a specific type"""
	for achievement_id in achievements.keys():
		var achievement = achievements[achievement_id]
		
		# Skip if already unlocked
		if unlocked_achievements.has(achievement_id):
			continue
			
		# Check if this achievement matches the type
		if achievement.type == achievement_type:
			_update_achievement_progress(achievement_id, value)

func _update_achievement_progress(achievement_id: String, value: int):
	"""Update progress for a specific achievement"""
	var achievement = achievements[achievement_id]
	
	# Update progress based on achievement type
	match achievement.type:
		AchievementType.SCORE, AchievementType.JUMPS:
			# These track current session values
			player_progress[achievement_id] = value
		AchievementType.COINS:
			# Coins are cumulative
			player_progress[achievement_id] = value
		AchievementType.SPECIAL, AchievementType.COMBO:
			# Special achievements track specific events
			player_progress[achievement_id] = value
	
	# Check if achievement is completed
	if player_progress[achievement_id] >= achievement.target:
		_unlock_achievement(achievement_id)

func _unlock_achievement(achievement_id: String):
	"""Unlock an achievement and grant rewards"""
	if unlocked_achievements.has(achievement_id):
		return  # Already unlocked
	
	var achievement = achievements[achievement_id]
	unlocked_achievements.append(achievement_id)
	
	print("Achievement Unlocked: ", achievement.name)
	
	# Grant coin reward
	if achievement.has("reward") and achievement.reward > 0:
		_grant_achievement_reward(achievement.reward)
	
	# Emit signal for UI notification
	emit_signal("achievement_unlocked", achievement_id, achievement)
	
	# Save progress
	_save_progress()

func _grant_achievement_reward(coins: int):
	"""Grant coin reward for achievement"""
	# Get the main game manager to add coins
	var main_scene = get_tree().get_first_node_in_group("main_game")
	if main_scene and main_scene.has_method("add_achievement_coins"):
		main_scene.add_achievement_coins(coins)
		print("Granted ", coins, " coins for achievement")

func track_score(score: int):
	"""Track score-based achievements"""
	update_progress(AchievementType.SCORE, score)

func track_jumps(jumps: int):
	"""Track jump-based achievements"""
	update_progress(AchievementType.JUMPS, jumps)

func track_coins(total_coins: int):
	"""Track coin-based achievements"""
	update_progress(AchievementType.COINS, total_coins)

func track_special_event(event_name: String):
	"""Track special events"""
	match event_name:
		"first_purchase":
			_update_achievement_progress("first_purchase", 1)
		"ad_continue":
			_update_achievement_progress("ad_continue", 1)

func track_combo(combo_count: int):
	"""Track combo achievements"""
	update_progress(AchievementType.COMBO, combo_count)

func get_achievement_progress(achievement_id: String) -> Dictionary:
	"""Get progress info for an achievement"""
	if not achievements.has(achievement_id):
		return {}
	
	var achievement = achievements[achievement_id]
	var progress = player_progress.get(achievement_id, 0)
	var is_unlocked = unlocked_achievements.has(achievement_id)
	
	return {
		"id": achievement_id,
		"name": achievement.name,
		"description": achievement.description,
		"icon": achievement.icon,
		"progress": progress,
		"target": achievement.target,
		"reward": achievement.get("reward", 0),
		"unlocked": is_unlocked,
		"progress_percent": float(progress) / float(achievement.target) * 100.0 if not is_unlocked else 100.0
	}

func get_all_achievements() -> Array:
	"""Get all achievements with their progress"""
	var result = []
	for achievement_id in achievements.keys():
		result.append(get_achievement_progress(achievement_id))
	return result

func get_unlocked_count() -> int:
	"""Get number of unlocked achievements"""
	return unlocked_achievements.size()

func get_total_count() -> int:
	"""Get total number of achievements"""
	return achievements.size()

func _save_progress():
	"""Save achievement progress to file"""
	var save_file = FileAccess.open("user://achievements.dat", FileAccess.WRITE)
	if save_file:
		var save_data = {
			"progress": player_progress,
			"unlocked": unlocked_achievements
		}
		save_file.store_string(JSON.stringify(save_data))
		save_file.close()

func _load_progress():
	"""Load achievement progress from file"""
	# Ensure dictionaries are initialized before loading
	if player_progress == null:
		player_progress = {}
	if unlocked_achievements == null:
		unlocked_achievements = []
	
	var save_file = FileAccess.open("user://achievements.dat", FileAccess.READ)
	if not save_file:
		print("No achievement save file found, using defaults")
		return
		
	var save_data_text = save_file.get_as_text()
	save_file.close()
	
	# Check if file has content
	if save_data_text.is_empty():
		print("Achievement file is empty, using defaults")
		return
	
	var json = JSON.new()
	var parse_result = json.parse(save_data_text)
	if parse_result == OK and json.data != null:
		var save_data = json.data
		if typeof(save_data) == TYPE_DICTIONARY:
			player_progress = save_data.get("progress", {})
			var loaded_unlocked = save_data.get("unlocked", [])
			unlocked_achievements.clear()
			for item in loaded_unlocked:
				if typeof(item) == TYPE_STRING:
					unlocked_achievements.append(item)
			print("Loaded achievement progress: ", unlocked_achievements.size(), " unlocked")
		else:
			print("Invalid achievement data format, using defaults")
	else:
		print("Failed to parse achievement data, using defaults")

func reset_session_progress():
	"""Reset session-based progress (called on new game)"""
	for achievement_id in achievements.keys():
		var achievement = achievements[achievement_id]
		# Reset session-based achievements
		if achievement.type == AchievementType.JUMPS or achievement.type == AchievementType.COMBO:
			if not unlocked_achievements.has(achievement_id):
				player_progress[achievement_id] = 0
