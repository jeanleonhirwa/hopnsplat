extends Control

# Visual touch feedback UI for mobile controls
@onready var touch_indicator: Control = $TouchIndicator
@onready var jump_hint: Label = $JumpHint
@onready var move_hint: Label = $MoveHint

var player: CharacterBody2D
var touch_circle: ColorRect
var is_showing_hints := true
var hint_fade_timer := 0.0
var hint_display_duration := 8.0  # Show hints for 8 seconds

func _ready():
	# Find player reference
	player = get_node("../Player")
	
	# Create touch indicator circle
	create_touch_indicator()
	
	# Set up hint labels
	setup_hint_labels()
	
	# Start hint fade timer
	hint_fade_timer = hint_display_duration

func create_touch_indicator():
	"""Create visual touch feedback circle"""
	touch_circle = ColorRect.new()
	touch_circle.size = Vector2(60, 60)
	touch_circle.color = Color(1, 1, 1, 0.3)  # Semi-transparent white
	touch_circle.visible = false
	
	# Make it circular by setting corner radius
	var style_box = StyleBoxFlat.new()
	style_box.corner_radius_top_left = 30
	style_box.corner_radius_top_right = 30
	style_box.corner_radius_bottom_left = 30
	style_box.corner_radius_bottom_right = 30
	style_box.bg_color = Color(0.2, 0.8, 1.0, 0.4)  # Light blue
	
	# Create a Panel instead for better styling
	var touch_panel = Panel.new()
	touch_panel.size = Vector2(60, 60)
	touch_panel.add_theme_stylebox_override("panel", style_box)
	touch_panel.visible = false
	touch_panel.name = "TouchIndicator"
	
	add_child(touch_panel)
	touch_circle = touch_panel

func setup_hint_labels():
	"""Set up instructional hint labels"""
	# Jump hint
	jump_hint = Label.new()
	jump_hint.text = "TAP to JUMP"
	jump_hint.add_theme_font_size_override("font_size", 24)
	jump_hint.add_theme_color_override("font_color", Color(1, 1, 0, 0.8))  # Yellow
	jump_hint.position = Vector2(get_viewport().size.x / 2 - 60, get_viewport().size.y - 150)
	jump_hint.name = "JumpHint"
	add_child(jump_hint)
	
	# Move hint
	move_hint = Label.new()
	move_hint.text = "TOUCH & DRAG to MOVE"
	move_hint.add_theme_font_size_override("font_size", 20)
	move_hint.add_theme_color_override("font_color", Color(0, 1, 1, 0.8))  # Cyan
	move_hint.position = Vector2(get_viewport().size.x / 2 - 90, get_viewport().size.y - 120)
	move_hint.name = "MoveHint"
	add_child(move_hint)

func _process(delta):
	# Update touch indicator position
	if player and player.is_touching:
		show_touch_indicator(player.touch_current_position)
	else:
		hide_touch_indicator()
	
	# Handle hint fade out
	if is_showing_hints:
		hint_fade_timer -= delta
		if hint_fade_timer <= 0:
			fade_out_hints()
		elif hint_fade_timer <= 2.0:  # Start fading 2 seconds before hiding
			var alpha = hint_fade_timer / 2.0
			jump_hint.modulate.a = alpha
			move_hint.modulate.a = alpha

func show_touch_indicator(touch_pos: Vector2):
	"""Show visual feedback at touch position"""
	if touch_circle:
		touch_circle.visible = true
		touch_circle.position = touch_pos - touch_circle.size / 2
		
		# Add pulse effect
		var scale_factor = 1.0 + sin(Time.get_time_dict_from_system()["unix"] * 8) * 0.1
		touch_circle.scale = Vector2(scale_factor, scale_factor)

func hide_touch_indicator():
	"""Hide touch indicator"""
	if touch_circle:
		touch_circle.visible = false

func fade_out_hints():
	"""Fade out instructional hints"""
	is_showing_hints = false
	var tween = create_tween()
	tween.parallel().tween_property(jump_hint, "modulate:a", 0.0, 1.0)
	tween.parallel().tween_property(move_hint, "modulate:a", 0.0, 1.0)
	tween.tween_callback(func(): 
		jump_hint.visible = false
		move_hint.visible = false
	)

func show_hints_temporarily():
	"""Show hints again temporarily (e.g., after game restart)"""
	is_showing_hints = true
	hint_fade_timer = hint_display_duration
	jump_hint.visible = true
	move_hint.visible = true
	jump_hint.modulate.a = 1.0
	move_hint.modulate.a = 1.0
