extends StaticBody2D

# Temporary Platform Script
class_name TempPlatform

# Visual elements
@onready var background_panel = $VisualContainer/Background
@onready var fade_timer = $FadeTimer

# Platform properties
var lifetime: float = 3.0
var fade_duration: float = 1.0
var is_fading: bool = false

func _ready():
	# Set up platform appearance
	setup_appearance()
	
	# Start lifetime timer
	fade_timer.wait_time = lifetime
	fade_timer.start()
	
	# Connect timer signal
	fade_timer.timeout.connect(_on_fade_timer_timeout)

func setup_appearance():
	"""Set up the visual appearance of the temporary platform"""
	if background_panel:
		var style_box = StyleBoxFlat.new()
		style_box.bg_color = Color(0.8, 0.6, 1.0, 0.8)  # Light purple with transparency
		style_box.corner_radius_top_left = 4
		style_box.corner_radius_top_right = 4
		style_box.corner_radius_bottom_left = 4
		style_box.corner_radius_bottom_right = 4
		style_box.border_width_left = 2
		style_box.border_width_right = 2
		style_box.border_width_top = 2
		style_box.border_width_bottom = 2
		style_box.border_color = Color(0.6, 0.4, 0.8, 1.0)
		background_panel.add_theme_stylebox_override("panel", style_box)

func _on_fade_timer_timeout():
	"""Start fading out the platform"""
	if not is_fading:
		is_fading = true
		start_fade_out()

func start_fade_out():
	"""Begin the fade out animation"""
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade out visually
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	
	# Scale down slightly
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), fade_duration)
	
	await tween.finished
	
	# Remove from scene
	queue_free()

func extend_lifetime(additional_time: float):
	"""Extend the platform's lifetime"""
	if not is_fading:
		fade_timer.wait_time += additional_time
		fade_timer.start()

func set_lifetime(new_lifetime: float):
	"""Set a new lifetime for the platform"""
	lifetime = new_lifetime
	if not is_fading:
		fade_timer.wait_time = lifetime
		fade_timer.start()

func get_remaining_time() -> float:
	"""Get the remaining time before the platform fades"""
	if is_fading:
		return 0.0
	return fade_timer.time_left
