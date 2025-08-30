extends Area2D

# Power-Up Item Script
class_name PowerUpItem

signal collected

# Power-up properties
var power_up_type: int = 0
var rarity: String = "common"
var icon: String = "⚡"
var color: Color = Color.WHITE

# Visual elements
@onready var background_panel = $VisualContainer/Background
@onready var icon_label = $VisualContainer/IconLabel
@onready var rarity_glow = $VisualContainer/RarityGlow
@onready var float_animation = $FloatAnimation
@onready var collect_sound = $CollectSound

# Animation properties
var float_speed: float = 2.0
var float_amplitude: float = 10.0
var rotation_speed: float = 1.0
var pulse_speed: float = 3.0

# Collection state
var is_collected: bool = false

func _ready():
	# Set up collision detection
	body_entered.connect(_on_body_entered)
	
	# Start floating animation
	start_floating_animation()
	
	# Set up visual effects based on rarity
	setup_rarity_effects()

func _process(delta):
	# Floating animation
	position.y += sin(Time.get_time_dict_from_system().second * float_speed) * float_amplitude * delta
	
	# Rotation animation
	rotation += rotation_speed * delta
	
	# Pulse animation for rare items
	if rarity != "common":
		var pulse = 1.0 + sin(Time.get_time_dict_from_system().second * pulse_speed) * 0.1
		scale = Vector2(pulse, pulse)

func set_power_up_type(type: int):
	"""Set the power-up type"""
	power_up_type = type

func set_appearance(new_icon: String, new_color: Color):
	"""Set the visual appearance of the power-up"""
	icon = new_icon
	color = new_color
	
	if icon_label:
		icon_label.text = icon
	
	if background_panel:
		var style_box = StyleBoxFlat.new()
		style_box.bg_color = color
		style_box.bg_color.a = 0.8
		style_box.corner_radius_top_left = 8
		style_box.corner_radius_top_right = 8
		style_box.corner_radius_bottom_left = 8
		style_box.corner_radius_bottom_right = 8
		background_panel.add_theme_stylebox_override("panel", style_box)

func set_rarity_effect(new_rarity: String):
	"""Set rarity-based visual effects"""
	rarity = new_rarity
	setup_rarity_effects()

func setup_rarity_effects():
	"""Setup visual effects based on rarity"""
	match rarity:
		"common":
			float_speed = 2.0
			rotation_speed = 1.0
			pulse_speed = 0.0
		"uncommon":
			float_speed = 2.5
			rotation_speed = 1.2
			pulse_speed = 2.0
			add_sparkle_effect()
		"rare":
			float_speed = 3.0
			rotation_speed = 1.5
			pulse_speed = 3.0
			add_glow_effect()
		"epic":
			float_speed = 3.5
			rotation_speed = 2.0
			pulse_speed = 4.0
			add_epic_effect()
		"legendary":
			float_speed = 4.0
			rotation_speed = 2.5
			pulse_speed = 5.0
			add_legendary_effect()

func add_sparkle_effect():
	"""Add sparkle particles for uncommon items"""
	# Create simple sparkle effect
	pass

func add_glow_effect():
	"""Add glow effect for rare items"""
	if rarity_glow:
		var glow_style = StyleBoxFlat.new()
		glow_style.bg_color = color
		glow_style.bg_color.a = 0.3
		glow_style.corner_radius_top_left = 12
		glow_style.corner_radius_top_right = 12
		glow_style.corner_radius_bottom_left = 12
		glow_style.corner_radius_bottom_right = 12
		glow_style.expand_margin_left = 4
		glow_style.expand_margin_right = 4
		glow_style.expand_margin_top = 4
		glow_style.expand_margin_bottom = 4
		
		var glow_panel = Panel.new()
		glow_panel.add_theme_stylebox_override("panel", glow_style)
		glow_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		rarity_glow.add_child(glow_panel)

func add_epic_effect():
	"""Add epic visual effects"""
	add_glow_effect()
	# Add additional epic effects like particle trails
	pass

func add_legendary_effect():
	"""Add legendary visual effects"""
	add_glow_effect()
	# Add screen distortion, rainbow effects, etc.
	pass

func start_floating_animation():
	"""Start the floating animation"""
	# Create floating tween animation
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "position:y", position.y + float_amplitude, 1.0 / float_speed)
	tween.tween_property(self, "position:y", position.y - float_amplitude, 1.0 / float_speed)

func _on_body_entered(body):
	"""Handle collision with player"""
	if is_collected:
		return
	
	# Check if it's the player
	if body.is_in_group("player") or body.name == "Player":
		collect_power_up()

func collect_power_up():
	"""Handle power-up collection"""
	if is_collected:
		return
	
	is_collected = true
	
	# Play collection sound
	if collect_sound:
		collect_sound.play()
	
	# Create collection effect
	create_collection_effect()
	
	# Emit collected signal
	emit_signal("collected")
	
	# Animate collection
	animate_collection()

func create_collection_effect():
	"""Create visual effect when collected"""
	# Create particle burst based on rarity
	match rarity:
		"common":
			create_simple_burst()
		"uncommon":
			create_sparkle_burst()
		"rare":
			create_glow_burst()
		"epic":
			create_epic_burst()
		"legendary":
			create_legendary_burst()

func create_simple_burst():
	"""Create simple particle burst"""
	# Simple particle effect
	pass

func create_sparkle_burst():
	"""Create sparkle particle burst"""
	# Sparkle particles
	pass

func create_glow_burst():
	"""Create glowing particle burst"""
	# Glowing particles with trails
	pass

func create_epic_burst():
	"""Create epic particle burst"""
	# Large particle burst with shockwave
	pass

func create_legendary_burst():
	"""Create legendary particle burst"""
	# Massive effect with screen shake and flash
	pass

func animate_collection():
	"""Animate the power-up being collected"""
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Scale up and fade out
	tween.tween_property(self, "scale", Vector2(2.0, 2.0), 0.3)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	
	# Move upward
	tween.tween_property(self, "position:y", position.y - 50, 0.3)
	
	await tween.finished
	
	# Remove from scene
	queue_free()

func get_power_up_info() -> Dictionary:
	"""Get information about this power-up"""
	return {
		"type": power_up_type,
		"rarity": rarity,
		"icon": icon,
		"color": color
	}
