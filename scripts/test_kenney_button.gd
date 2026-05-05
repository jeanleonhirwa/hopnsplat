extends Control
## Test script for KenneyButton animation integration
## Verifies that animations work correctly with UIAnimationManager

func _ready():
	print("=== KenneyButton Animation Test ===")
	print("Testing animation integration...")
	
	# Get button references
	var normal_button = $VBoxContainer/NormalButton
	var wobble_button = $VBoxContainer/WobbleButton
	var red_button = $VBoxContainer/RedButton
	
	# Test 1: Verify buttons are initialized
	if normal_button and wobble_button and red_button:
		print("✓ All test buttons created successfully")
	else:
		push_error("✗ Failed to create test buttons")
		return
	
	# Test 2: Verify wobble button has idle animation
	await get_tree().create_timer(0.5).timeout
	if wobble_button.idle_wobble_tween and wobble_button.idle_wobble_tween.is_running():
		print("✓ Wobble button idle animation is running")
	else:
		push_warning("⚠ Wobble button idle animation not detected")
	
	# Test 3: Connect button signals to verify animations trigger
	normal_button.pressed.connect(func(): print("✓ Normal button pressed - animation should have played"))
	wobble_button.pressed.connect(func(): print("✓ Wobble button pressed - animation should have played"))
	red_button.pressed.connect(func(): print("✓ Red button pressed - animation should have played"))
	
	# Test 4: Verify UIAnimationManager is tracking tweens
	await get_tree().create_timer(1.0).timeout
	var active_count = UIAnimationManager.get_active_tween_count()
	print("UIAnimationManager active tweens: %d" % active_count)
	
	if active_count > 0:
		print("✓ UIAnimationManager is tracking animations")
	else:
		print("⚠ No active tweens detected (this is normal if no interactions yet)")
	
	print("\n=== Test Instructions ===")
	print("1. Hover over buttons to see bounce-in animation")
	print("2. Click buttons to see squash animation")
	print("3. Watch the wobble button rotate subtly")
	print("4. Move mouse away to see return-to-normal animation")
	print("\nAll animations should be smooth and responsive!")
