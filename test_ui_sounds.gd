extends Node

## Simple test script to verify UI sound integration
## Run this in the Godot editor to test the UI sounds

func _ready():
	print("=== UI Sound System Test ===")
	
	# Test 1: Verify AudioManager has UI sounds cached
	print("\nTest 1: Checking UI sounds cache...")
	if AudioManager.ui_sounds_cache.size() == 6:
		print("✓ All 6 UI sounds cached successfully")
		for sound_name in AudioManager.ui_sounds_cache.keys():
			print("  - ", sound_name, ": ", AudioManager.ui_sounds_cache[sound_name])
	else:
		print("✗ Expected 6 sounds, found: ", AudioManager.ui_sounds_cache.size())
	
	# Test 2: Test hover sounds
	print("\nTest 2: Testing hover sounds...")
	AudioManager.play_ui_hover()
	await get_tree().create_timer(0.3).timeout
	AudioManager.play_ui_hover()
	print("✓ Hover sounds played (should hear tap-a or tap-b)")
	
	# Test 3: Test click sounds
	print("\nTest 3: Testing click sounds...")
	await get_tree().create_timer(0.5).timeout
	AudioManager.play_ui_click()
	await get_tree().create_timer(0.3).timeout
	AudioManager.play_ui_click()
	print("✓ Click sounds played (should hear click-a or click-b)")
	
	# Test 4: Test switch sounds
	print("\nTest 4: Testing switch sounds...")
	await get_tree().create_timer(0.5).timeout
	AudioManager.play_ui_switch()
	await get_tree().create_timer(0.3).timeout
	AudioManager.play_ui_switch()
	print("✓ Switch sounds played (should hear switch-a or switch-b)")
	
	# Test 5: Test pitch variation
	print("\nTest 5: Testing pitch variation...")
	await get_tree().create_timer(0.5).timeout
	for i in range(5):
		AudioManager.play_ui_click()
		await get_tree().create_timer(0.2).timeout
	print("✓ Pitch variation test complete (should hear slight pitch differences)")
	
	print("\n=== All Tests Complete ===")
	print("If you heard sounds with slight pitch variations, the implementation is working correctly!")
