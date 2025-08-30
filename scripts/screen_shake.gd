extends Node2D

# Screen Shake System for Enhanced Game Feel
class_name ScreenShake

signal shake_finished

var camera: Camera2D
var original_offset: Vector2
var shake_intensity: float = 0.0
var shake_duration: float = 0.0
var shake_timer: float = 0.0
var shake_frequency: float = 30.0

func _ready():
	set_process(false)

func initialize(target_camera: Camera2D):
	"""Initialize with target camera"""
	camera = target_camera
	if camera:
		original_offset = camera.offset

func _process(delta: float):
	if shake_timer > 0:
		shake_timer -= delta
		
		# Calculate shake offset using sine waves for smooth motion
		var shake_offset = Vector2(
			sin(shake_timer * shake_frequency) * shake_intensity,
			cos(shake_timer * shake_frequency * 1.3) * shake_intensity
		)
		
		# Apply diminishing intensity over time
		var intensity_factor = shake_timer / shake_duration
		shake_offset *= intensity_factor
		
		# Apply shake to camera
		if camera:
			camera.offset = original_offset + shake_offset
	else:
		# Shake finished, restore original position
		if camera:
			camera.offset = original_offset
		set_process(false)
		emit_signal("shake_finished")

func shake(intensity: float, duration: float, frequency: float = 30.0):
	"""Start screen shake with specified parameters"""
	shake_intensity = intensity
	shake_duration = duration
	shake_timer = duration
	shake_frequency = frequency
	
	if camera:
		original_offset = camera.offset
	
	set_process(true)

# Preset shake effects
func light_shake():
	"""Light shake for small impacts"""
	shake(3.0, 0.2, 40.0)

func medium_shake():
	"""Medium shake for normal impacts"""
	shake(6.0, 0.4, 35.0)

func heavy_shake():
	"""Heavy shake for big impacts"""
	shake(10.0, 0.6, 30.0)

func landing_shake():
	"""Shake specifically for platform landings"""
	shake(4.0, 0.3, 45.0)

func boost_shake():
	"""Shake for boost activation"""
	shake(5.0, 0.25, 50.0)
