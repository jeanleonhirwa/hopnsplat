extends Control

# Signals to communicate with main game
signal restart_requested
signal continue_requested

# UI References
@onready var final_score_label = $FinalScoreLabel
@onready var currency_earned_label = $CurrencyEarnedLabel
@onready var jumps_label = $JumpsLabel
@onready var high_score_label = $HighScoreLabel
@onready var continue_button = $ContinueButton
@onready var restart_button = $RestartButton
@onready var menu_button = $MenuButton

# Continue system variables
var continues_used: int = 0
var max_continues: int = 2
var rewarded_ad_loader: RewardedAdLoader
var current_rewarded_ad: RewardedAd

func _ready():
	# Connect button signals
	continue_button.pressed.connect(_on_continue_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	menu_button.pressed.connect(_on_menu_button_pressed)
	
	# Initialize AdMob rewarded ads
	_initialize_rewarded_ads()

func show_game_over(final_score: int, currency_earned: int, jumps: int, high_score: int, is_new_high_score: bool, continues_used_param: int = 0):
	"""Display the game over screen with stats"""
	
	# Update continues counter
	continues_used = continues_used_param
	
	# Update labels with game stats
	final_score_label.text = "Final Score: " + str(final_score)
	currency_earned_label.text = "Coins Earned: " + str(currency_earned)
	jumps_label.text = "Successful Jumps: " + str(jumps)
	
	# Handle high score display
	if is_new_high_score:
		high_score_label.text = "NEW HIGH SCORE!"
		high_score_label.modulate = Color.GOLD
	else:
		high_score_label.text = "High Score: " + str(high_score)
		high_score_label.modulate = Color.WHITE
	
	# Update continue button state
	_update_continue_button()
	
	# Show the screen
	visible = true
	
	print("Game Over screen displayed - Score: ", final_score, " Currency: ", currency_earned, " Continues used: ", continues_used)

func hide_game_over():
	"""Hide the game over screen"""
	visible = false

func _on_restart_button_pressed():
	"""Handle restart button press"""
	print("Restart button pressed in GameOver scene")
	emit_signal("restart_requested")

func _on_continue_button_pressed():
	"""Handle continue button press - show rewarded ad"""
	print("Continue button pressed - attempting to show rewarded ad")
	
	# Try using AdMob manager first
	var admob_manager = get_node("/root/AdMobManager")
	if admob_manager and admob_manager.is_rewarded_ad_available():
		var reward_callback = OnUserEarnedRewardListener.new()
		reward_callback.on_user_earned_reward = _on_user_earned_reward
		admob_manager.show_rewarded_ad(reward_callback)
	elif current_rewarded_ad:
		_show_rewarded_ad()
	else:
		print("No rewarded ad available")

func _on_menu_button_pressed():
	"""Handle menu button press"""
	print("Menu button pressed in GameOver scene")
	# Go directly to main menu
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _initialize_rewarded_ads():
	"""Initialize AdMob rewarded ads using centralized manager"""
	# Connect to AdMob manager signals
	var admob_manager = get_node("/root/AdMobManager")
	if admob_manager:
		admob_manager.connect("rewarded_ad_loaded", _on_manager_ad_loaded)
		admob_manager.connect("rewarded_ad_failed_to_load", _on_manager_ad_failed)
		_update_continue_button()
	else:
		print("AdMob Manager not found - using fallback")
		# Fallback to direct initialization
		await get_tree().create_timer(1.0).timeout
		rewarded_ad_loader = RewardedAdLoader.new()
		_load_rewarded_ad()

func _load_rewarded_ad():
	"""Load a rewarded ad"""
	if not rewarded_ad_loader:
		print("Rewarded ad loader not initialized")
		return
	
	var ad_request = AdRequest.new()
	var ad_unit_id = "ca-app-pub-4465102717758082/2931505731"  # Production rewarded ad unit ID
	
	var load_callback = RewardedAdLoadCallback.new()
	load_callback.on_ad_loaded = _on_rewarded_ad_loaded
	load_callback.on_ad_failed_to_load = _on_rewarded_ad_failed_to_load
	
	rewarded_ad_loader.load(ad_unit_id, ad_request, load_callback)
	print("Loading rewarded ad with unit ID: ", ad_unit_id)

func _on_rewarded_ad_loaded(rewarded_ad: RewardedAd):
	"""Called when rewarded ad is loaded"""
	current_rewarded_ad = rewarded_ad
	print("Rewarded ad loaded successfully")
	_update_continue_button()

func _on_rewarded_ad_failed_to_load(load_ad_error: LoadAdError):
	"""Called when rewarded ad fails to load"""
	print("Failed to load rewarded ad: ", load_ad_error.message, " Code: ", load_ad_error.code)
	current_rewarded_ad = null
	_update_continue_button()
	
	# Retry loading after a delay
	await get_tree().create_timer(5.0).timeout
	_load_rewarded_ad()

func _show_rewarded_ad():
	"""Show the rewarded ad"""
	if not current_rewarded_ad:
		return
	
	# Set up reward callback
	var reward_callback = OnUserEarnedRewardListener.new()
	reward_callback.on_user_earned_reward = _on_user_earned_reward
	
	# Set up full screen callback
	current_rewarded_ad.full_screen_content_callback.on_ad_dismissed_full_screen_content = _on_ad_dismissed
	current_rewarded_ad.full_screen_content_callback.on_ad_failed_to_show_full_screen_content = _on_ad_failed_to_show
	
	current_rewarded_ad.show(reward_callback)

func _on_user_earned_reward(rewarded_item: RewardedItem):
	"""Called when user earns reward from watching ad"""
	print("User earned reward: ", rewarded_item.amount, " ", rewarded_item.type)
	# Grant continue and emit signal
	continues_used += 1
	
	# Track ad continue achievement
	var achievement_system = get_node("/root/AchievementSystem")
	if achievement_system:
		achievement_system.track_special_event("ad_continue")
	
	emit_signal("continue_requested")
	# Load next ad for future use
	_load_rewarded_ad()

func _on_ad_dismissed():
	"""Called when ad is dismissed"""
	print("Rewarded ad dismissed")

func _on_ad_failed_to_show(ad_error: AdError):
	"""Called when ad fails to show"""
	print("Failed to show rewarded ad: ", ad_error.message)
	# Try to load a new ad
	_load_rewarded_ad()

func _update_continue_button():
	"""Update continue button state based on continues used and ad availability"""
	var continues_remaining = max_continues - continues_used
	
	if continues_remaining <= 0:
		# No continues left
		continue_button.text = "No continues left"
		continue_button.disabled = true
		continue_button.modulate = Color.GRAY
	else:
		# Check ad availability from manager or fallback
		var ad_available = false
		var admob_manager = get_node("/root/AdMobManager")
		if admob_manager:
			ad_available = admob_manager.is_rewarded_ad_available()
		else:
			ad_available = current_rewarded_ad != null
		
		if not ad_available:
			# Ad not loaded
			continue_button.text = "📺 Loading..."
			continue_button.disabled = true
			continue_button.modulate = Color.YELLOW
		else:
			# Continue available
			if continues_remaining == 1:
				continue_button.text = "📺 CONTINUE (1 left)"
			else:
				continue_button.text = "📺 CONTINUE (" + str(continues_remaining) + " left)"
			continue_button.disabled = false
			continue_button.modulate = Color(0.2, 0.8, 0.2, 1)

func _on_manager_ad_loaded():
	"""Called when AdMob manager loads an ad"""
	print("AdMob manager: Rewarded ad loaded")
	_update_continue_button()

func _on_manager_ad_failed():
	"""Called when AdMob manager fails to load ad"""
	print("AdMob manager: Failed to load rewarded ad")
	_update_continue_button()

func reset_continues():
	"""Reset continues counter for new game"""
	continues_used = 0
	_update_continue_button()
