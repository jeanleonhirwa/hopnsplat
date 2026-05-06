extends GutTest

## Test suite for AchievementCard locked/unlocked visual states
## Validates Requirements 9.2 and 9.4

var achievement_card: AchievementCard


func before_each():
	# Create a new AchievementCard instance for each test
	achievement_card = AchievementCard.new()
	add_child_autofree(achievement_card)
	# Wait for _ready() to complete
	await wait_frames(1)


func test_locked_state_shows_star_outline():
	# Requirement 9.2: Star icons indicate completion status
	achievement_card.set_locked(true)
	await wait_frames(1)
	
	var status_star = achievement_card.get_node("MainContainer/StatusContainer/StatusStar")
	assert_not_null(status_star, "StatusStar node should exist")
	
	var expected_texture_path = "res://assets/ui_packs/Yellow/Default/star_outline.png"
	assert_eq(status_star.texture.resource_path, expected_texture_path, 
		"Locked achievement should show star_outline.png")


func test_unlocked_state_shows_filled_star():
	# Requirement 9.2: Star icons indicate completion status
	achievement_card.set_locked(false)
	await wait_frames(1)
	
	var status_star = achievement_card.get_node("MainContainer/StatusContainer/StatusStar")
	assert_not_null(status_star, "StatusStar node should exist")
	
	var expected_texture_path = "res://assets/ui_packs/Yellow/Default/star.png"
	assert_eq(status_star.texture.resource_path, expected_texture_path, 
		"Unlocked achievement should show star.png")


func test_locked_state_shows_grey_overlay():
	# Requirement 9.4: Locked achievements with greyed variants
	achievement_card.set_locked(true)
	await wait_frames(1)
	
	var locked_overlay = achievement_card.get_node("LockedOverlay")
	assert_not_null(locked_overlay, "LockedOverlay node should exist")
	assert_true(locked_overlay.visible, "Locked overlay should be visible when locked")
	
	# Verify overlay color and alpha (0.6 alpha as per spec)
	assert_almost_eq(locked_overlay.color.a, 0.6, 0.01, 
		"Locked overlay should have 0.6 alpha")


func test_unlocked_state_hides_grey_overlay():
	# Requirement 9.4: Unlocked achievements without overlay
	achievement_card.set_locked(false)
	await wait_frames(1)
	
	var locked_overlay = achievement_card.get_node("LockedOverlay")
	assert_not_null(locked_overlay, "LockedOverlay node should exist")
	assert_false(locked_overlay.visible, "Locked overlay should be hidden when unlocked")


func test_locked_state_desaturates_icon():
	# Requirement 9.4: Locked achievements with desaturated icon
	achievement_card.set_locked(true)
	await wait_frames(1)
	
	var icon = achievement_card.get_node("MainContainer/IconContainer/IconBackground/AchievementIcon")
	assert_not_null(icon, "AchievementIcon node should exist")
	
	# Verify desaturation (0.5 modulate as per spec)
	assert_almost_eq(icon.modulate.r, 0.5, 0.01, "Icon red channel should be 0.5 when locked")
	assert_almost_eq(icon.modulate.g, 0.5, 0.01, "Icon green channel should be 0.5 when locked")
	assert_almost_eq(icon.modulate.b, 0.5, 0.01, "Icon blue channel should be 0.5 when locked")


func test_unlocked_state_full_color_icon():
	# Requirement 9.4: Unlocked achievements with full color
	achievement_card.set_locked(false)
	await wait_frames(1)
	
	var icon = achievement_card.get_node("MainContainer/IconContainer/IconBackground/AchievementIcon")
	assert_not_null(icon, "AchievementIcon node should exist")
	
	# Verify full color (1.0 modulate)
	assert_almost_eq(icon.modulate.r, 1.0, 0.01, "Icon red channel should be 1.0 when unlocked")
	assert_almost_eq(icon.modulate.g, 1.0, 0.01, "Icon green channel should be 1.0 when unlocked")
	assert_almost_eq(icon.modulate.b, 1.0, 0.01, "Icon blue channel should be 1.0 when unlocked")


func test_toggle_locked_state():
	# Test toggling between locked and unlocked states
	achievement_card.set_locked(true)
	await wait_frames(1)
	
	var status_star = achievement_card.get_node("MainContainer/StatusContainer/StatusStar")
	assert_eq(status_star.texture.resource_path, 
		"res://assets/ui_packs/Yellow/Default/star_outline.png",
		"Should show outline when locked")
	
	achievement_card.set_locked(false)
	await wait_frames(1)
	
	assert_eq(status_star.texture.resource_path, 
		"res://assets/ui_packs/Yellow/Default/star.png",
		"Should show filled star when unlocked")
	
	achievement_card.set_locked(true)
	await wait_frames(1)
	
	assert_eq(status_star.texture.resource_path, 
		"res://assets/ui_packs/Yellow/Default/star_outline.png",
		"Should show outline again when re-locked")
