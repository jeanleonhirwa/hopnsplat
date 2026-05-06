extends GutTest

## Test suite for KenneySlider animation implementation
## Validates Task 12.2: Implement KenneySlider animations
## Requirements: 10.3

var slider: KenneySlider
var test_scene: Node


func before_each():
	"""Set up test environment before each test."""
	# Create a test scene to hold the slider
	test_scene = Node2D.new()
	add_child_autofree(test_scene)
	
	# Create and configure slider
	slider = KenneySlider.new()
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.value = 50.0
	slider.slider_color = KenneySlider.ColorPack.YELLOW
	slider.show_value_label = true
	slider.value_suffix = "%"
	
	test_scene.add_child(slider)
	
	# Wait for _ready() to complete
	await wait_frames(2)


func after_each():
	"""Clean up after each test."""
	if slider:
		slider.queue_free()
	slider = null


func test_slider_initialization():
	"""Test that slider initializes correctly with all child nodes."""
	assert_not_null(slider, "Slider should be created")
	assert_not_null(slider.background_rect, "Background rect should exist")
	assert_not_null(slider.fill_rect, "Fill rect should exist")
	assert_not_null(slider.handle_rect, "Handle rect should exist")
	assert_not_null(slider.value_label, "Value label should exist")


func test_animation_properties():
	"""Test that animation properties are set correctly."""
	assert_eq(slider.handle_hover_scale, 1.1, "Handle hover scale should be 1.1")
	assert_eq(slider.handle_drag_scale, 1.15, "Handle drag scale should be 1.15")
	assert_eq(slider.animation_duration, 0.1, "Animation duration should be 0.1s")


func test_handle_hover_animation():
	"""Test handle hover animation: Scale to 1.1 (0.1s)."""
	# Store original scale
	var original_scale = slider.handle_rect.scale
	
	# Simulate mouse enter
	slider._on_mouse_entered()
	
	# Wait for animation to complete
	await wait_seconds(0.15)
	
	# Verify scale changed to hover scale
	var expected_scale = original_scale * slider.handle_hover_scale
	assert_almost_eq(slider.handle_rect.scale.x, expected_scale.x, 0.01, 
		"Handle should scale to 1.1 on hover")
	assert_almost_eq(slider.handle_rect.scale.y, expected_scale.y, 0.01, 
		"Handle should scale to 1.1 on hover")


func test_handle_drag_animation():
	"""Test handle drag animation: Scale to 1.15 (0.1s)."""
	# Store original scale
	var original_scale = slider.handle_rect.scale
	
	# Simulate drag start
	slider._on_drag_started()
	
	# Wait for animation to complete
	await wait_seconds(0.15)
	
	# Verify scale changed to drag scale
	var expected_scale = original_scale * slider.handle_drag_scale
	assert_almost_eq(slider.handle_rect.scale.x, expected_scale.x, 0.01, 
		"Handle should scale to 1.15 on drag")
	assert_almost_eq(slider.handle_rect.scale.y, expected_scale.y, 0.01, 
		"Handle should scale to 1.15 on drag")


func test_handle_drag_end_animation():
	"""Test handle returns to normal scale after drag ends."""
	# Start drag
	slider._on_drag_started()
	await wait_seconds(0.15)
	
	# Store original scale
	var original_scale = slider.original_handle_scale
	
	# End drag
	slider._on_drag_ended(true)
	
	# Wait for animation to complete
	await wait_seconds(0.15)
	
	# Verify scale returned to original
	assert_almost_eq(slider.handle_rect.scale.x, original_scale.x, 0.01, 
		"Handle should return to original scale after drag")
	assert_almost_eq(slider.handle_rect.scale.y, original_scale.y, 0.01, 
		"Handle should return to original scale after drag")


func test_value_change_bounce_animation():
	"""Test value change bounce animation: Handle bounce (0.15s)."""
	# Store original scale
	var original_scale = slider.handle_rect.scale
	
	# Trigger bounce animation
	slider.play_handle_animation()
	
	# Wait a bit for the scale-up part
	await wait_seconds(0.05)
	
	# Handle should be scaled up during bounce
	assert_gt(slider.handle_rect.scale.x, original_scale.x, 
		"Handle should scale up during bounce")
	
	# Wait for full animation to complete
	await wait_seconds(0.15)
	
	# Handle should return to original scale
	assert_almost_eq(slider.handle_rect.scale.x, original_scale.x, 0.01, 
		"Handle should return to original scale after bounce")


func test_fill_bar_smooth_transition():
	"""Test fill bar smooth transition: Fill bar (0.2s)."""
	# Set initial value
	slider.value = 25.0
	await wait_frames(2)
	
	# Store initial fill width
	var initial_fill = slider.fill_rect.anchor_right
	
	# Change value
	slider.value = 75.0
	
	# Immediately check - should still be animating
	await wait_seconds(0.05)
	var mid_fill = slider.fill_rect.anchor_right
	
	# Fill should be between initial and target
	assert_gt(mid_fill, initial_fill, "Fill should be animating")
	assert_lt(mid_fill, 0.75, "Fill should not have reached target yet")
	
	# Wait for animation to complete
	await wait_seconds(0.2)
	
	# Fill should reach target value
	var expected_fill = (75.0 - slider.min_value) / (slider.max_value - slider.min_value)
	assert_almost_eq(slider.fill_rect.anchor_right, expected_fill, 0.01, 
		"Fill bar should smoothly transition to new value")


func test_mouse_exit_returns_to_normal():
	"""Test that mouse exit returns handle to normal scale."""
	# Hover first
	slider._on_mouse_entered()
	await wait_seconds(0.15)
	
	# Store original scale
	var original_scale = slider.original_handle_scale
	
	# Exit hover
	slider._on_mouse_exited()
	
	# Wait for animation to complete
	await wait_seconds(0.15)
	
	# Verify scale returned to original
	assert_almost_eq(slider.handle_rect.scale.x, original_scale.x, 0.01, 
		"Handle should return to original scale on mouse exit")


func test_disabled_slider_no_animation():
	"""Test that disabled slider does not animate."""
	slider.disabled = true
	
	# Store original scale
	var original_scale = slider.handle_rect.scale
	
	# Try to trigger animations
	slider._on_mouse_entered()
	slider._on_drag_started()
	slider.play_handle_animation()
	
	await wait_seconds(0.2)
	
	# Scale should not have changed
	assert_eq(slider.handle_rect.scale, original_scale, 
		"Disabled slider should not animate")


func test_value_change_during_drag_triggers_bounce():
	"""Test that value changes during drag trigger bounce animation."""
	# Start dragging
	slider.is_dragging = true
	
	# Change value (simulates user dragging)
	slider.value = 75.0
	
	# This should trigger _on_value_changed which calls play_handle_animation
	# Wait for bounce animation
	await wait_seconds(0.2)
	
	# Animation should have completed
	assert_not_null(slider.current_tween, "Tween should exist after value change during drag")


func test_animation_uses_tween():
	"""Test that animations use Tween for smooth transitions."""
	# Trigger hover animation
	slider._on_mouse_entered()
	
	# Check that a tween was created
	assert_not_null(slider.current_tween, "Tween should be created for animation")
	assert_true(slider.current_tween.is_running(), "Tween should be running")
	
	# Wait for animation to complete
	await wait_seconds(0.15)
	
	# Tween should have finished
	assert_false(slider.current_tween.is_running(), "Tween should have finished")


func test_concurrent_animations_cancel_previous():
	"""Test that new animations cancel previous ones."""
	# Start hover animation
	slider._on_mouse_entered()
	var first_tween = slider.current_tween
	
	await wait_seconds(0.05)
	
	# Start drag animation (should cancel hover)
	slider._on_drag_started()
	var second_tween = slider.current_tween
	
	# Should be a different tween
	assert_ne(first_tween, second_tween, "New animation should create new tween")
	assert_false(first_tween.is_running(), "Previous tween should be cancelled")
	assert_true(second_tween.is_running(), "New tween should be running")
