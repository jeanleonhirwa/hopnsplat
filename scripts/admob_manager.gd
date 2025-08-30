extends Node

# AdMob Manager - Centralized ad management for the game
signal admob_initialized
signal rewarded_ad_loaded
signal rewarded_ad_failed_to_load

var is_initialized: bool = false
var rewarded_ad_loader: RewardedAdLoader
var current_rewarded_ad: RewardedAd

# Ad Unit IDs
const APP_ID = "ca-app-pub-4465102717758082~1327328769"
const REWARDED_AD_UNIT_ID = "ca-app-pub-4465102717758082/2931505731"

func _ready():
	"""Initialize AdMob on startup"""
	_initialize_admob()

func _initialize_admob():
	"""Initialize AdMob SDK"""
	print("AdMobManager: Initializing AdMob SDK...")
	
	# Initialize MobileAds
	var initialization_listener = OnInitializationCompleteListener.new()
	initialization_listener.on_initialization_complete = _on_admob_initialization_complete
	MobileAds.initialize(initialization_listener)

func _on_admob_initialization_complete(_initialization_status: InitializationStatus):
	"""Called when AdMob initialization is complete"""
	print("AdMobManager: AdMob initialization complete")
	is_initialized = true
	emit_signal("admob_initialized")
	
	# Start loading rewarded ads
	_initialize_rewarded_ads()

func _initialize_rewarded_ads():
	"""Initialize rewarded ad loader"""
	print("AdMobManager: Initializing rewarded ads...")
	rewarded_ad_loader = RewardedAdLoader.new()
	load_rewarded_ad()

func load_rewarded_ad():
	"""Load a rewarded ad"""
	if not is_initialized:
		print("AdMobManager: AdMob not initialized yet")
		return
		
	if not rewarded_ad_loader:
		print("AdMobManager: Rewarded ad loader not initialized")
		return
	
	var ad_request = AdRequest.new()
	
	var load_callback = RewardedAdLoadCallback.new()
	load_callback.on_ad_loaded = _on_rewarded_ad_loaded
	load_callback.on_ad_failed_to_load = _on_rewarded_ad_failed_to_load
	
	rewarded_ad_loader.load(REWARDED_AD_UNIT_ID, ad_request, load_callback)
	print("AdMobManager: Loading rewarded ad with unit ID: ", REWARDED_AD_UNIT_ID)

func _on_rewarded_ad_loaded(rewarded_ad: RewardedAd):
	"""Called when rewarded ad is loaded"""
	current_rewarded_ad = rewarded_ad
	print("AdMobManager: Rewarded ad loaded successfully")
	emit_signal("rewarded_ad_loaded")

func _on_rewarded_ad_failed_to_load(load_ad_error: LoadAdError):
	"""Called when rewarded ad fails to load"""
	print("AdMobManager: Failed to load rewarded ad: ", load_ad_error.message, " Code: ", load_ad_error.code)
	current_rewarded_ad = null
	emit_signal("rewarded_ad_failed_to_load")
	
	# Retry loading after a delay
	await get_tree().create_timer(10.0).timeout
	load_rewarded_ad()

func show_rewarded_ad(reward_callback: OnUserEarnedRewardListener) -> bool:
	"""Show rewarded ad if available"""
	if not current_rewarded_ad:
		print("AdMobManager: No rewarded ad available")
		return false
	
	# Set up full screen callbacks
	current_rewarded_ad.full_screen_content_callback.on_ad_dismissed_full_screen_content = _on_ad_dismissed
	current_rewarded_ad.full_screen_content_callback.on_ad_failed_to_show_full_screen_content = _on_ad_failed_to_show
	
	current_rewarded_ad.show(reward_callback)
	print("AdMobManager: Showing rewarded ad")
	return true

func _on_ad_dismissed():
	"""Called when ad is dismissed"""
	print("AdMobManager: Rewarded ad dismissed")
	# Load next ad for future use
	load_rewarded_ad()

func _on_ad_failed_to_show(ad_error: AdError):
	"""Called when ad fails to show"""
	print("AdMobManager: Failed to show rewarded ad: ", ad_error.message)
	# Try to load a new ad
	load_rewarded_ad()

func is_rewarded_ad_available() -> bool:
	"""Check if rewarded ad is available"""
	return current_rewarded_ad != null

func get_initialization_status() -> bool:
	"""Get AdMob initialization status"""
	return is_initialized
