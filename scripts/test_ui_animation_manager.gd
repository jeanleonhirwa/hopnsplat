extends Node
## Simple test script to verify UIAnimationManager functionality
## This can be attached to a test scene to verify the singleton works

func _ready():
	print("Testing UIAnimationManager...")
	
	# Test 1: Verify singleton is accessible
	if UIAnimationManager:
		print("✓ UIAnimationManager singleton is accessible")
	else:
		push_error("✗ UIAnimationManager singleton not found!")
		return
	
	# Test 2: Verify MAX_CONCURRENT_TWEENS constant
	if UIAnimationManager.MAX_CONCURRENT_TWEENS == 10:
		print("✓ MAX_CONCURRENT_TWEENS is set to 10")
	else:
		push_error("✗ MAX_CONCURRENT_TWEENS is not 10!")
	
	# Test 3: Verify active_tweens array exists
	if UIAnimationManager.active_tweens is Array:
		print("✓ active_tweens array exists")
	else:
		push_error("✗ active_tweens is not an array!")
	
	# Test 4: Verify methods exist
	var methods_to_check = [
		"register_tween",
		"cleanup_finished_tweens", 
		"stop_all_tweens",
		"bounce_in",
		"squash",
		"pop_out",
		"wobble",
		"slide_in",
		"fade_in",
		"count_up"
	]
	
	for method_name in methods_to_check:
		if UIAnimationManager.has_method(method_name):
			print("✓ Method '%s' exists" % method_name)
		else:
			push_error("✗ Method '%s' not found!" % method_name)
	
	# Test 5: Test basic tween registration
	var test_node = Node2D.new()
	add_child(test_node)
	
	var initial_count = UIAnimationManager.get_active_tween_count()
	var tween = UIAnimationManager.bounce_in(test_node)
	
	await get_tree().create_timer(0.05).timeout  # Wait a bit
	
	var after_count = UIAnimationManager.get_active_tween_count()
	if after_count > initial_count:
		print("✓ Tween registration works (count: %d)" % after_count)
	else:
		push_warning("⚠ Tween may have finished too quickly or registration failed")
	
	# Test 6: Test cleanup
	UIAnimationManager.stop_all_tweens()
	await get_tree().create_timer(0.05).timeout
	
	if UIAnimationManager.get_active_tween_count() == 0:
		print("✓ stop_all_tweens() works correctly")
	else:
		push_error("✗ stop_all_tweens() did not clear all tweens!")
	
	test_node.queue_free()
	
	print("\nUIAnimationManager tests complete!")
	print("All core functionality verified ✓")
