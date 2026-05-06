extends Control

# Signals to communicate with main game
signal restart_requested
signal continue_requested

# UI References
@onready var final_score_label = $GameOverPanel/VBoxContainer/StatsContainer/FinalScorePanel/HBoxContainer/FinalScoreLabel
@onready var currency_earned_label = $GameOverPanel/VBoxContainer/StatsContainer/CurrencyPanel/HBoxContainer/CurrencyEarnedLabel
@onready var jumps_label = $GameOverPanel/VBoxContainer/StatsContainer/JumpsPanel/HBoxContainer/JumpsLabel
@onready var high_score_label = $GameOverPanel/VBoxContainer/StatsContainer/HighScorePanel/HBoxContainer/HighScoreLabel
@onready var continue_button = $GameOverPanel/VBoxContainer/ButtonContainer/ContinueButton
@onready var restart_button = $GameOverPanel/VBoxContainer/ButtonContainer/RestartButton
@onready var menu_button = $GameOverPanel/VBoxContainer/ButtonContainer/MenuButton
@onready var game_over_title = $GameOverPanel/VBoxContainer/GameOverLabel

# Star rating references
@onready var star1 = $GameOverPanel/VBoxContainer/StarRating/Star1
@onready var star2 = $GameOverPanel/VBoxContainer/StarRating/Star2
@onready var star3 = $GameOverPanel/VBoxContainer/StarRating/Star3

# Stat panel references for celebration animation
@onready var final_score_panel = $GameOverPanel/VBoxContainer/StatsContainer/FinalScorePanel
@onready var currency_panel = $GameOverPanel/VBoxContainer/StatsContainer/CurrencyPanel
@onready var jumps_panel = $GameOverPanel/VBoxContainer/StatsContainer/JumpsPanel
@onready var high_score_panel = $GameOverPanel/VBoxContainer/StatsContainer/HighScorePanel

# Star textures
var star_filled: Texture2D
var star_outline: Texture2D

# Continue system variables
var continues_used: int = 0
var max_continues: int = 2
var rewarded_ad_loader: RewardedAdLoader
var current_rewarded_ad: RewardedAd

func _ready():
	# Load star textures
	star_filled = preload("res://assets/ui_packs/Yellow/Default/star.png")
	star_outline = preload("res://assets/ui_packs/Yellow/Default/star_outline.png")
	
	# Initialize all stars as outline
	star1.texture = star_outline
	star2.texture = star_outline
	star3.texture = star_outline
	
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
		# Trigger celebration animation for new high score
		_play_high_score_celebration()
	else:
		high_score_label.text = "High Score: " + str(high_score)
		high_score_label.modulate = Color.WHITE
	
	# Update continue button state
	_update_continue_button()
	
	# Calculate and animate star rating
	_animate_star_rating(final_score)
	
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
		continue_button.set_button_text("No continues left")
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
			continue_button.set_button_text("Loading...")
			continue_button.disabled = true
			continue_button.modulate = Color.YELLOW
		else:
			# Continue available
			if continues_remaining == 1:
				continue_button.set_button_text("CONTINUE (1 left)")
			else:
				continue_button.set_button_text("CONTINUE (" + str(continues_remaining) + " left)")
			continue_button.disabled = false
			continue_button.modulate = Color.WHITE

func _on_manager_ad_loaded():
	"""Called when AdMob manager loads an ad"""
	print("AdMob manager: Rewarded ad loaded")
	_update_continue_button()

func _on_manager_ad_failed():
	"""Called when AdMob manager fails to load ad"""
	print("AdMob manager: Failed to load rewarded ad")
	_update_continue_button()

func _animate_star_rating(score: int):
	"""Animate star rating based on score
	Star rating logic:
	- 1 star: score > 0
	- 2 stars: score > 50
	- 3 stars: score > 100
	"""
	# Calculate number of stars to fill
	var stars_to_fill = 0
	if score > 0:
		stars_to_fill = 1
	if score > 50:
		stars_to_fill = 2
	if score > 100:
		stars_to_fill = 3
	
	# Reset all stars to outline
	star1.texture = star_outline
	star2.texture = star_outline
	star3.texture = star_outline
	star1.scale = Vector2.ONE
	star2.scale = Vector2.ONE
	star3.scale = Vector2.ONE
	
	# Animate stars filling in sequence
	var stars = [star1, star2, star3]
	for i in range(stars_to_fill):
		var star = stars[i]
		var delay = i * 0.1  # 0.1s delay between each star
		
		# Wait for delay, then fill and animate
		await get_tree().create_timer(delay).timeout
		star.texture = star_filled
		
		# Pop animation using UIAnimationManager
		var ui_anim = get_node("/root/UIAnimationManager")
		if ui_anim:
			ui_anim.pop_out(star, 0.2)

func reset_continues():
	"""Reset continues counter for new game"""
	continues_used = 0
	_update_continue_button()


func _play_high_score_celebration():
	"""Play celebration animation for new high score
	Requirements: 8.4
	- Title flashes between colors (0.5s loop, 3 times)
	- Spawn particle burst from title using star textures
	- All stat panels bounce in sequence
	- Play celebration sound effect
	"""
	print("Playing high score celebration animation")
	
	# 1. Title flashes between colors (0.5s loop, 3 times)
	_animate_title_flash()
	
	# 2. Spawn particle burst from title
	await get_tree().create_timer(0.3).timeout  # Small delay before particles
	_spawn_celebration_particles()
	
	# 3. All stat panels bounce in sequence
	await get_tree().create_timer(0.2).timeout  # Small delay before bounces
	_animate_stat_panels_bounce()
	
	# 4. Play celebration sound effect
	var audio_manager = get_node("/root/AudioManager")
	if audio_manager:
		audio_manager.play_ui_click()  # Using click sound as celebration sound


func _animate_title_flash():
	"""Animate title flashing between colors"""
	if not game_over_title:
		return
	
	var ui_anim = get_node("/root/UIAnimationManager")
	if not ui_anim:
		return
	
	# Flash colors: Gold, Yellow, White, Gold (3 cycles)
	var flash_colors = [Color.GOLD, Color.YELLOW, Color.WHITE]
	var flash_duration = 0.5
	var flash_count = 3
	
	for i in range(flash_count):
		for color in flash_colors:
			var tween = create_tween()
			ui_anim.register_tween(tween)
			tween.tween_property(game_over_title, "modulate", color, flash_duration / flash_colors.size())
			await tween.finished
	
	# Return to gold at the end
	var final_tween = create_tween()
	ui_anim.register_tween(final_tween)
	final_tween.tween_property(game_over_title, "modulate", Color.GOLD, 0.2)


func _spawn_celebration_particles():
	"""Spawn particle burst from title using star textures"""
	if not game_over_title:
		return
	
	# Create particle system
	var particles = CPUParticles2D.new()
	particles.name = "CelebrationParticles"
	
	# Position at title center
	game_over_title.add_child(particles)
	particles.position = Vector2(game_over_title.size.x / 2, game_over_title.size.y / 2)
	
	# Configure particle properties
	particles.emitting = false
	particles.amount = 30
	particles.lifetime = 1.0
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.randomness = 0.5
	
	# Set star texture
	particles.texture = preload("res://assets/ui_packs/Yellow/Default/star.png")
	
	# Emission shape - circle
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 10.0
	
	# Direction and spread
	particles.direction = Vector2(0, -1)
	particles.spread = 180.0
	
	# Velocity
	particles.initial_velocity_min = 100.0
	particles.initial_velocity_max = 200.0
	
	# Gravity
	particles.gravity = Vector2(0, 300)
	
	# Scale
	particles.scale_amount_min = 0.5
	particles.scale_amount_max = 1.0
	
	# Color modulation for variety
	particles.color = Color.YELLOW
	
	# Start emitting
	particles.emitting = true
	
	# Auto-cleanup after lifetime
	await get_tree().create_timer(particles.lifetime + 0.2).timeout
	particles.queue_free()
	
	print("Celebration particles spawned")


func _animate_stat_panels_bounce():
	"""Animate all stat panels bouncing in sequence"""
	var ui_anim = get_node("/root/UIAnimationManager")
	if not ui_anim:
		return
	
	var panels = [final_score_panel, currency_panel, jumps_panel, high_score_panel]
	var delay_between_bounces = 0.1
	
	for i in range(panels.size()):
		if panels[i]:
			# Wait for delay
			await get_tree().create_timer(delay_between_bounces).timeout
			# Bounce animation
			ui_anim.bounce_in(panels[i], 0.2, 1.15)
	
	print("Stat panels bounce animation complete")
